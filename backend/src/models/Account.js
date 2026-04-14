// Muud Health — Unified Account Model (I/O/S Types + Tier System)
// © Muud Health — Armin Hoes, MD
//
// One-Account architecture: every user has exactly one Account document that
// determines their account type (Individual / Organizational / Superadmin),
// tier level, platform entitlements, and data-ownership boundaries.
//
// Account types:
//   I = Individual   (Tiers 1–5)
//   O = Organizational/Enterprise   (Tiers 1–5)
//   S = Superadmin   (Tiers 1–3)

const mongoose = require('mongoose');

// ── Constants ────────────────────────────────────────────────────

const ACCOUNT_TYPES = Object.freeze({
  INDIVIDUAL: 'I',
  ORGANIZATIONAL: 'O',
  SUPERADMIN: 'S',
});

// Individual tier criteria:
//   T1 = CMF weekly/biweekly
//   T2 = PMF or TMF weekly/biweekly
//   T3 = Any clinic monthly | Academy | Coaching weekly/biweekly
//   T4 = Paid content subscription (premium SAAS) — auto for ring users
//   T5 = Freemium
const INDIVIDUAL_TIERS = Object.freeze({
  TIER_1: 1, // CMF weekly or biweekly
  TIER_2: 2, // PMF or TMF weekly or biweekly
  TIER_3: 3, // Any clinic monthly | Academy | Coaching
  TIER_4: 4, // Paid content subscription / ring user
  TIER_5: 5, // Freemium
});

// Organizational tier criteria (size × need matrix):
//   T1 = Large Triad
//   T2 = Large Dual | Mid Triad
//   T3 = Large Solo | Mid Dual | Small/Starter Triad
//   T4 = Mid Solo | Small/Starter Dual
//   T5 = Small/Starter Solo
const ORGANIZATIONAL_TIERS = Object.freeze({
  TIER_1: 1,
  TIER_2: 2,
  TIER_3: 3,
  TIER_4: 4,
  TIER_5: 5,
});

// Superadmin tiers:
//   S1 = Muud Health Superadmin (100% privileges)
//   S2 = Muud Health Staff/Provider (90% privileges)
//   S3 = Organizational Account Superadmin (75% privileges)
const SUPERADMIN_TIERS = Object.freeze({
  S1: 1,
  S2: 2,
  S3: 3,
});

const ORG_SIZES = Object.freeze({
  LARGE: 'large',       // 100+
  MID: 'mid',           // 51–100
  SMALL: 'small',       // 11–50
  STARTER: 'starter',   // 1–10
});

const ORG_NEEDS = Object.freeze({
  TRIAD: 'triad',             // ring + app + portal
  DUAL_MOBILE: 'dual_mobile', // ring + app
  DUAL_WEB: 'dual_web',       // ring + portal
  SOLO: 'solo',               // app or portal only
});

const PLATFORM_TYPES = Object.freeze({
  APP: 'app',
  PORTAL: 'portal',
  RING: 'ring',
});

// ── Schema ───────────────────────────────────────────────────────

const AccountSchema = new mongoose.Schema(
  {
    // Link to user identity (Cognito sub)
    ownerSub: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },

    // Account classification
    accountType: {
      type: String,
      enum: Object.values(ACCOUNT_TYPES),
      required: true,
      default: ACCOUNT_TYPES.INDIVIDUAL,
      index: true,
    },

    // Tier within account type (1 = highest, 5 = lowest for I/O; 1–3 for S)
    tier: {
      type: Number,
      required: true,
      default: 5,
      min: 1,
      max: 5,
      index: true,
    },

    // ── Individual-specific fields ─────────────────────────────
    individual: {
      // Active service plan reference
      activeServicePlanId: { type: mongoose.Schema.Types.ObjectId, ref: 'ServicePlan' },
      // Whether user has an active ring device
      hasRingDevice: { type: Boolean, default: false },
      // Content subscription status
      subscriptionStatus: {
        type: String,
        enum: ['active', 'trial', 'expired', 'none'],
        default: 'none',
      },
      subscriptionExpiresAt: { type: Date },
    },

    // ── Organizational-specific fields ─────────────────────────
    organizational: {
      organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization' },
      // Role within the organization
      orgRole: {
        type: String,
        enum: ['member', 'manager', 'admin', 'owner'],
        default: 'member',
      },
    },

    // ── Superadmin-specific fields ─────────────────────────────
    superadmin: {
      // Which orgs this superadmin manages (S3 only)
      managedOrganizations: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Organization' }],
      // Privilege percentage (100% for S1, 90% for S2, 75% for S3)
      privilegeLevel: { type: Number, default: 75, min: 0, max: 100 },
    },

    // ── Platform access ────────────────────────────────────────
    platforms: {
      app: { type: Boolean, default: true },
      portal: { type: Boolean, default: false },
      ring: { type: Boolean, default: false },
    },

    // ── Data ownership ─────────────────────────────────────────
    dataOwnership: {
      // For I accounts: 'individual' — user owns all data
      // For O accounts: 'organizational' — org owns usage data, user owns PHI
      // For S accounts: 'administrative' — access-only, no ownership of user data
      type: {
        type: String,
        enum: ['individual', 'organizational', 'administrative'],
        default: 'individual',
      },
      // If organizational, which org owns the non-PHI data
      owningOrganizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization' },
    },

    // ── Metadata ───────────────────────────────────────────────
    status: {
      type: String,
      enum: ['active', 'suspended', 'deactivated', 'pending'],
      default: 'active',
      index: true,
    },

    activatedAt: { type: Date, default: Date.now },
    lastTierRecalculation: { type: Date },
  },
  { timestamps: true }
);

// ── Indexes ──────────────────────────────────────────────────────

AccountSchema.index({ accountType: 1, tier: 1 });
AccountSchema.index({ 'organizational.organizationId': 1 });
AccountSchema.index({ status: 1, accountType: 1 });

// ── Instance methods ─────────────────────────────────────────────

/**
 * Returns true if account has access to the specified platform.
 */
AccountSchema.methods.hasPlatformAccess = function (platform) {
  return this.platforms[platform] === true;
};

/**
 * Returns true if account tier meets or exceeds the required tier.
 * Lower number = higher tier, so tier 1 > tier 5.
 */
AccountSchema.methods.meetsTierRequirement = function (requiredTier) {
  return this.tier <= requiredTier;
};

/**
 * Returns the effective privilege level (0–100) for access control.
 */
AccountSchema.methods.getPrivilegeLevel = function () {
  if (this.accountType === ACCOUNT_TYPES.SUPERADMIN) {
    return this.superadmin?.privilegeLevel ?? 75;
  }
  // I and O accounts: tier-based scaling (T1=100, T2=80, T3=60, T4=40, T5=20)
  return Math.max(20, 100 - (this.tier - 1) * 20);
};

/**
 * Returns true if this account owns (or has legitimate access to) a given user's data.
 */
AccountSchema.methods.canAccessUserData = function (targetSub, targetAccount) {
  // Self access
  if (this.ownerSub === targetSub) return true;

  // S1 can access all
  if (this.accountType === ACCOUNT_TYPES.SUPERADMIN && this.tier === 1) return true;

  // S2 can access all non-S1
  if (
    this.accountType === ACCOUNT_TYPES.SUPERADMIN &&
    this.tier === 2 &&
    !(targetAccount?.accountType === ACCOUNT_TYPES.SUPERADMIN && targetAccount?.tier === 1)
  ) {
    return true;
  }

  // S3 can access users in managed orgs
  if (this.accountType === ACCOUNT_TYPES.SUPERADMIN && this.tier === 3) {
    const managedIds = (this.superadmin?.managedOrganizations || []).map((id) => id.toString());
    const targetOrgId = targetAccount?.organizational?.organizationId?.toString();
    return targetOrgId && managedIds.includes(targetOrgId);
  }

  // O account admin/owner can access members of same org (non-PHI only)
  if (
    this.accountType === ACCOUNT_TYPES.ORGANIZATIONAL &&
    ['admin', 'owner'].includes(this.organizational?.orgRole)
  ) {
    return (
      targetAccount?.organizational?.organizationId?.toString() ===
      this.organizational?.organizationId?.toString()
    );
  }

  return false;
};

// ── Statics ──────────────────────────────────────────────────────

/**
 * Compute the correct tier for an Individual account based on their service plan.
 */
AccountSchema.statics.computeIndividualTier = function (servicePlan, account) {
  if (!servicePlan) {
    // No service plan — check subscription / ring
    if (account?.individual?.hasRingDevice || account?.individual?.subscriptionStatus === 'active') {
      return INDIVIDUAL_TIERS.TIER_4;
    }
    return INDIVIDUAL_TIERS.TIER_5;
  }

  const { planType, frequency, category } = servicePlan;

  // Clinic services
  if (category === 'clinic') {
    if (planType === 'CMF' && ['weekly', 'biweekly'].includes(frequency)) {
      return INDIVIDUAL_TIERS.TIER_1;
    }
    if (['PMF', 'TMF'].includes(planType) && ['weekly', 'biweekly'].includes(frequency)) {
      return INDIVIDUAL_TIERS.TIER_2;
    }
    // Any clinic plan monthly
    if (frequency === 'monthly') {
      return INDIVIDUAL_TIERS.TIER_3;
    }
  }

  // Academy (instructional)
  if (category === 'academy') {
    return INDIVIDUAL_TIERS.TIER_3;
  }

  // Coaching (interventional) weekly/biweekly
  if (category === 'coaching' && ['weekly', 'biweekly'].includes(frequency)) {
    return INDIVIDUAL_TIERS.TIER_3;
  }

  // Paid subscription fallback
  if (account?.individual?.subscriptionStatus === 'active' || account?.individual?.hasRingDevice) {
    return INDIVIDUAL_TIERS.TIER_4;
  }

  return INDIVIDUAL_TIERS.TIER_5;
};

/**
 * Compute the correct tier for an Organizational account based on size × need.
 *
 * Matrix:
 *          | Triad | Dual Mobile | Dual Web | Solo |
 *  Large   |   1   |      2      |    2     |   3  |
 *  Mid     |   2   |      3      |    3     |   4  |
 *  Small   |   3   |      4      |    4     |   5  |
 *  Starter |   3   |      4      |    4     |   5  |
 */
AccountSchema.statics.computeOrganizationalTier = function (orgSize, orgNeed) {
  const TIER_MATRIX = {
    [ORG_SIZES.LARGE]: {
      [ORG_NEEDS.TRIAD]: 1,
      [ORG_NEEDS.DUAL_MOBILE]: 2,
      [ORG_NEEDS.DUAL_WEB]: 2,
      [ORG_NEEDS.SOLO]: 3,
    },
    [ORG_SIZES.MID]: {
      [ORG_NEEDS.TRIAD]: 2,
      [ORG_NEEDS.DUAL_MOBILE]: 3,
      [ORG_NEEDS.DUAL_WEB]: 3,
      [ORG_NEEDS.SOLO]: 4,
    },
    [ORG_SIZES.SMALL]: {
      [ORG_NEEDS.TRIAD]: 3,
      [ORG_NEEDS.DUAL_MOBILE]: 4,
      [ORG_NEEDS.DUAL_WEB]: 4,
      [ORG_NEEDS.SOLO]: 5,
    },
    [ORG_SIZES.STARTER]: {
      [ORG_NEEDS.TRIAD]: 3,
      [ORG_NEEDS.DUAL_MOBILE]: 4,
      [ORG_NEEDS.DUAL_WEB]: 4,
      [ORG_NEEDS.SOLO]: 5,
    },
  };

  return TIER_MATRIX[orgSize]?.[orgNeed] ?? 5;
};

module.exports = mongoose.model('Account', AccountSchema);
module.exports.ACCOUNT_TYPES = ACCOUNT_TYPES;
module.exports.INDIVIDUAL_TIERS = INDIVIDUAL_TIERS;
module.exports.ORGANIZATIONAL_TIERS = ORGANIZATIONAL_TIERS;
module.exports.SUPERADMIN_TIERS = SUPERADMIN_TIERS;
module.exports.ORG_SIZES = ORG_SIZES;
module.exports.ORG_NEEDS = ORG_NEEDS;
module.exports.PLATFORM_TYPES = PLATFORM_TYPES;
