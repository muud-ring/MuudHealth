// Muud Health — Account Management Routes
// © Muud Health — Armin Hoes, MD

const express = require('express');
const router = express.Router();
const requireAuth = require('../middleware/requireAuth');
const { fullAccountContext } = require('../middleware/platformAuth');
const { authorize } = require('../middleware/authorize');
const Account = require('../models/Account');
const ServicePlan = require('../models/ServicePlan');
const { resolveEntitlements } = require('../config/entitlements');
const logger = require('../utils/logger');

// ── GET /account — Get current user's account ────────────────────
router.get('/', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const account = req.account;
    if (!account) {
      return res.status(404).json({ error: 'Account not found' });
    }

    const entitlements = [...resolveEntitlements(account)];

    res.json({
      account: account.toObject(),
      entitlements,
      platform: req.platform,
      privilegeLevel: account.getPrivilegeLevel(),
    });
  } catch (err) {
    next(err);
  }
});

// ── GET /account/tier — Get tier details with explanation ────────
router.get('/tier', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const account = req.account;
    if (!account) return res.status(404).json({ error: 'Account not found' });

    // Fetch active service plan for context
    let activePlan = null;
    if (account.individual?.activeServicePlanId) {
      activePlan = await ServicePlan.findById(account.individual.activeServicePlanId);
    }

    res.json({
      accountType: account.accountType,
      tier: account.tier,
      privilegeLevel: account.getPrivilegeLevel(),
      activePlan: activePlan ? activePlan.getSummary() : null,
      platforms: account.platforms,
      dataOwnership: account.dataOwnership,
    });
  } catch (err) {
    next(err);
  }
});

// ── POST /account/recalculate-tier — Force tier recalculation ────
router.post('/recalculate-tier', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const account = req.account;
    if (!account) return res.status(404).json({ error: 'Account not found' });

    let newTier = account.tier;

    if (account.accountType === 'I') {
      // Fetch highest-priority active service plan
      const activePlan = await ServicePlan.findOne({
        ownerSub: account.ownerSub,
        status: 'active',
      }).sort({ impliedTier: 1 }); // Lowest tier number = highest priority

      newTier = Account.computeIndividualTier(activePlan, account);
    }

    // O and S tiers are set externally (org config / admin action)

    account.tier = newTier;
    account.lastTierRecalculation = new Date();
    await account.save();

    logger.info({ sub: account.ownerSub, newTier }, 'Tier recalculated');

    res.json({
      tier: newTier,
      privilegeLevel: account.getPrivilegeLevel(),
      recalculatedAt: account.lastTierRecalculation,
    });
  } catch (err) {
    next(err);
  }
});

// ── PATCH /account/platforms — Update platform access ────────────
// Admin/Superadmin only
router.patch('/platforms', requireAuth, fullAccountContext, authorize('admin'), async (req, res, next) => {
  try {
    const { targetSub, platforms } = req.body;
    if (!targetSub || !platforms) {
      return res.status(400).json({ error: 'targetSub and platforms required' });
    }

    const targetAccount = await Account.findOne({ ownerSub: targetSub });
    if (!targetAccount) return res.status(404).json({ error: 'Target account not found' });

    if (platforms.app !== undefined) targetAccount.platforms.app = Boolean(platforms.app);
    if (platforms.portal !== undefined) targetAccount.platforms.portal = Boolean(platforms.portal);
    if (platforms.ring !== undefined) targetAccount.platforms.ring = Boolean(platforms.ring);

    await targetAccount.save();

    res.json({ message: 'Platform access updated', platforms: targetAccount.platforms });
  } catch (err) {
    next(err);
  }
});

// ── GET /account/data-export — GDPR/CCPA data export manifest ───
router.get('/data-export', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    if (!req.dataOwnership) {
      return res.status(500).json({ error: 'Data ownership not initialized' });
    }
    const manifest = req.dataOwnership.exportManifest();
    res.json(manifest);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
