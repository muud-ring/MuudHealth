// Muud Health — Organization Management Routes
// © Muud Health — Armin Hoes, MD

const express = require('express');
const router = express.Router();
const requireAuth = require('../middleware/requireAuth');
const { fullAccountContext } = require('../middleware/platformAuth');
const { authorize } = require('../middleware/authorize');
const Organization = require('../models/Organization');
const Account = require('../models/Account');
const { ACCOUNT_TYPES } = require('../models/Account');
const logger = require('../utils/logger');

// ── GET /organizations — List orgs the user belongs to ───────────
router.get('/', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const sub = req.user.sub;
    const account = req.account;

    // S1/S2 see all orgs; S3 sees managed orgs; O users see their org
    let orgs;
    if (account?.accountType === ACCOUNT_TYPES.SUPERADMIN) {
      if (account.tier <= 2) {
        orgs = await Organization.find({ status: { $ne: 'deactivated' } }).sort({ name: 1 });
      } else {
        orgs = await Organization.find({
          _id: { $in: account.superadmin?.managedOrganizations || [] },
        }).sort({ name: 1 });
      }
    } else {
      orgs = await Organization.find({ 'members.sub': sub }).sort({ name: 1 });
    }

    res.json({ organizations: orgs });
  } catch (err) {
    next(err);
  }
});

// ── GET /organizations/:id — Get org details ─────────────────────
router.get('/:id', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const org = await Organization.findById(req.params.id);
    if (!org) return res.status(404).json({ error: 'Organization not found' });

    // Verify access
    const sub = req.user.sub;
    const account = req.account;
    const isMember = org.members.some((m) => m.sub === sub);
    const isSuperadmin = account?.accountType === ACCOUNT_TYPES.SUPERADMIN;
    const isManaging = isSuperadmin && (
      account.tier <= 2 ||
      (account.superadmin?.managedOrganizations || []).map(String).includes(org._id.toString())
    );

    if (!isMember && !isManaging) {
      return res.status(403).json({ error: 'Not authorized to view this organization' });
    }

    res.json({
      organization: org.toObject(),
      memberCount: org.members.length,
      remainingLicenses: org.remainingLicenses(),
      membersByRole: org.memberCountByRole(),
    });
  } catch (err) {
    next(err);
  }
});

// ── POST /organizations — Create new org (admin/superadmin only) ─
router.post('/', requireAuth, fullAccountContext, authorize('admin'), async (req, res, next) => {
  try {
    const { name, slug, size, need, licenses, primaryContact, billingEmail } = req.body;

    if (!name || !slug || !size || !need) {
      return res.status(400).json({ error: 'name, slug, size, and need are required' });
    }

    // Compute tier from size × need matrix
    const tier = Account.computeOrganizationalTier(size, need);

    const org = new Organization({
      name,
      slug,
      size,
      need,
      tier,
      licenses: { total: licenses || 10, used: 0 },
      primaryContact,
      billingEmail,
      status: 'active',
    });

    await org.save();

    logger.info({ orgId: org._id, name, size, need, tier }, 'Organization created');
    res.status(201).json({ organization: org.toObject() });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({ error: 'Organization slug already exists' });
    }
    next(err);
  }
});

// ── POST /organizations/:id/members — Add member ─────────────────
router.post('/:id/members', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const org = await Organization.findById(req.params.id);
    if (!org) return res.status(404).json({ error: 'Organization not found' });

    // Only org admin/owner or superadmin can add members
    const requestorMember = org.members.find((m) => m.sub === req.user.sub);
    const isSuperadmin = req.account?.accountType === ACCOUNT_TYPES.SUPERADMIN;

    if (!isSuperadmin && (!requestorMember || !['admin', 'owner'].includes(requestorMember.role))) {
      return res.status(403).json({ error: 'Only org admins can add members' });
    }

    if (!org.hasAvailableLicenses()) {
      return res.status(409).json({ error: 'No available licenses', remaining: 0 });
    }

    const { memberSub, role = 'member' } = req.body;
    if (!memberSub) return res.status(400).json({ error: 'memberSub required' });

    // Check if already a member
    if (org.members.some((m) => m.sub === memberSub)) {
      return res.status(409).json({ error: 'User is already a member of this organization' });
    }

    org.members.push({ sub: memberSub, role });
    org.licenses.used += 1;
    await org.save();

    // Update the member's Account to reflect org membership
    await Account.findOneAndUpdate(
      { ownerSub: memberSub },
      {
        $set: {
          accountType: ACCOUNT_TYPES.ORGANIZATIONAL,
          tier: org.tier,
          'organizational.organizationId': org._id,
          'organizational.orgRole': role,
          platforms: org.platforms,
          'dataOwnership.type': 'organizational',
          'dataOwnership.owningOrganizationId': org._id,
        },
      },
      { upsert: true, new: true }
    );

    logger.info({ orgId: org._id, memberSub, role }, 'Member added to organization');
    res.json({ message: 'Member added', memberCount: org.members.length, remainingLicenses: org.remainingLicenses() });
  } catch (err) {
    next(err);
  }
});

// ── DELETE /organizations/:id/members/:sub — Remove member ───────
router.delete('/:id/members/:sub', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const org = await Organization.findById(req.params.id);
    if (!org) return res.status(404).json({ error: 'Organization not found' });

    const requestorMember = org.members.find((m) => m.sub === req.user.sub);
    const isSuperadmin = req.account?.accountType === ACCOUNT_TYPES.SUPERADMIN;

    if (!isSuperadmin && (!requestorMember || !['admin', 'owner'].includes(requestorMember.role))) {
      return res.status(403).json({ error: 'Only org admins can remove members' });
    }

    const targetSub = req.params.sub;
    const memberIndex = org.members.findIndex((m) => m.sub === targetSub);
    if (memberIndex === -1) return res.status(404).json({ error: 'Member not found in org' });

    org.members.splice(memberIndex, 1);
    org.licenses.used = Math.max(0, org.licenses.used - 1);
    await org.save();

    // Revert the removed member's Account to Individual T5
    await Account.findOneAndUpdate(
      { ownerSub: targetSub },
      {
        $set: {
          accountType: ACCOUNT_TYPES.INDIVIDUAL,
          tier: 5,
          'organizational.organizationId': null,
          'organizational.orgRole': 'member',
          'dataOwnership.type': 'individual',
          'dataOwnership.owningOrganizationId': null,
        },
      }
    );

    logger.info({ orgId: org._id, removedSub: targetSub }, 'Member removed from organization');
    res.json({ message: 'Member removed' });
  } catch (err) {
    next(err);
  }
});

// ── GET /organizations/:id/analytics — Org-level analytics ───────
router.get('/:id/analytics', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const org = await Organization.findById(req.params.id);
    if (!org) return res.status(404).json({ error: 'Organization not found' });

    // Only admins/owners and superadmins
    const requestorMember = org.members.find((m) => m.sub === req.user.sub);
    const isSuperadmin = req.account?.accountType === ACCOUNT_TYPES.SUPERADMIN;

    if (!isSuperadmin && (!requestorMember || !['admin', 'owner'].includes(requestorMember.role))) {
      return res.status(403).json({ error: 'Only org admins can view analytics' });
    }

    // Aggregate de-identified member data
    const memberSubs = org.members.map((m) => m.sub);

    res.json({
      organizationId: org._id,
      memberCount: org.members.length,
      tierBreakdown: org.memberCountByRole(),
      platforms: org.platforms,
      licenses: org.licenses,
      dataGovernance: org.dataGovernance,
      // Placeholder for aggregated wellness metrics (populated by crossPlatformSync)
      aggregateWellness: {
        note: 'De-identified aggregate wellness data — requires TrendSnapshot aggregation',
        memberCount: memberSubs.length,
      },
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
