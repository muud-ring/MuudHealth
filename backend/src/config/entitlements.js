// Muud Health — Entitlements Engine (Tier-Based Feature Gating)
// © Muud Health — Armin Hoes, MD
//
// Central entitlement matrix: maps (accountType, tier, platform) → feature access.
// Enforced via entitlementsMiddleware on every authenticated request.
//
// Design principle:
//   Lower tier number = higher privilege.
//   S accounts inherit I + O entitlements scoped by their privilege %.
//   Platform access is gated independently from feature access.

const { ACCOUNT_TYPES, PLATFORM_TYPES } = require('../models/Account');

// ── Feature Registry ─────────────────────────────────────────────
// Every gatable feature in the Muud ecosystem.

const FEATURES = Object.freeze({
  // ── Content ────────────────────────────────────────────────
  CONTENT_FREE: 'content:free',
  CONTENT_PREMIUM: 'content:premium',
  CONTENT_AI: 'content:ai',

  // ── Ring / Biometrics ──────────────────────────────────────
  RING_PAIR: 'ring:pair',
  RING_BIOMETRICS: 'ring:biometrics',
  RING_LIVE_METRICS: 'ring:live_metrics',

  // ── App features ───────────────────────────────────────────
  APP_JOURNAL: 'app:journal',
  APP_VAULT: 'app:vault',
  APP_VAULT_SHARED: 'app:vault_shared',
  APP_TRENDS: 'app:trends',
  APP_TRENDS_ADVANCED: 'app:trends_advanced',
  APP_PEOPLE: 'app:people',
  APP_CHAT: 'app:chat',
  APP_EXPLORE: 'app:explore',
  APP_NOTIFICATIONS: 'app:notifications',

  // ── Portal features ────────────────────────────────────────
  PORTAL_DASHBOARD: 'portal:dashboard',
  PORTAL_ANALYTICS: 'portal:analytics',
  PORTAL_REPORTS: 'portal:reports',
  PORTAL_MEMBER_MGMT: 'portal:member_management',
  PORTAL_ORG_SETTINGS: 'portal:org_settings',

  // ── Clinic services ────────────────────────────────────────
  CLINIC_BOOKING: 'clinic:booking',
  CLINIC_SESSIONS: 'clinic:sessions',
  CLINIC_RECORDS: 'clinic:records',

  // ── Academy ────────────────────────────────────────────────
  ACADEMY_ENROLL: 'academy:enroll',
  ACADEMY_PROGRESS: 'academy:progress',
  ACADEMY_CERTIFICATE: 'academy:certificate',

  // ── Coaching ───────────────────────────────────────────────
  COACHING_BOOKING: 'coaching:booking',
  COACHING_SESSIONS: 'coaching:sessions',

  // ── AI / Intelligence ──────────────────────────────────────
  AI_INSIGHTS: 'ai:insights',
  AI_PREDICTIONS: 'ai:predictions',
  AI_RECOMMENDATIONS: 'ai:recommendations',

  // ── Admin / Superadmin ─────────────────────────────────────
  ADMIN_USER_MGMT: 'admin:user_management',
  ADMIN_COMPLIANCE: 'admin:compliance',
  ADMIN_BILLING: 'admin:billing',
  ADMIN_PLATFORM_CONFIG: 'admin:platform_config',
});

// ── Individual Tier Entitlements ─────────────────────────────────

const INDIVIDUAL_ENTITLEMENTS = Object.freeze({
  // Tier 1: CMF weekly/biweekly — full access to everything
  1: new Set([
    FEATURES.CONTENT_FREE, FEATURES.CONTENT_PREMIUM, FEATURES.CONTENT_AI,
    FEATURES.RING_PAIR, FEATURES.RING_BIOMETRICS, FEATURES.RING_LIVE_METRICS,
    FEATURES.APP_JOURNAL, FEATURES.APP_VAULT, FEATURES.APP_VAULT_SHARED,
    FEATURES.APP_TRENDS, FEATURES.APP_TRENDS_ADVANCED, FEATURES.APP_PEOPLE,
    FEATURES.APP_CHAT, FEATURES.APP_EXPLORE, FEATURES.APP_NOTIFICATIONS,
    FEATURES.CLINIC_BOOKING, FEATURES.CLINIC_SESSIONS, FEATURES.CLINIC_RECORDS,
    FEATURES.ACADEMY_ENROLL, FEATURES.ACADEMY_PROGRESS, FEATURES.ACADEMY_CERTIFICATE,
    FEATURES.COACHING_BOOKING, FEATURES.COACHING_SESSIONS,
    FEATURES.AI_INSIGHTS, FEATURES.AI_PREDICTIONS, FEATURES.AI_RECOMMENDATIONS,
  ]),

  // Tier 2: PMF/TMF weekly/biweekly — all except combined clinic records
  2: new Set([
    FEATURES.CONTENT_FREE, FEATURES.CONTENT_PREMIUM, FEATURES.CONTENT_AI,
    FEATURES.RING_PAIR, FEATURES.RING_BIOMETRICS, FEATURES.RING_LIVE_METRICS,
    FEATURES.APP_JOURNAL, FEATURES.APP_VAULT, FEATURES.APP_VAULT_SHARED,
    FEATURES.APP_TRENDS, FEATURES.APP_TRENDS_ADVANCED, FEATURES.APP_PEOPLE,
    FEATURES.APP_CHAT, FEATURES.APP_EXPLORE, FEATURES.APP_NOTIFICATIONS,
    FEATURES.CLINIC_BOOKING, FEATURES.CLINIC_SESSIONS, FEATURES.CLINIC_RECORDS,
    FEATURES.ACADEMY_ENROLL, FEATURES.ACADEMY_PROGRESS,
    FEATURES.COACHING_BOOKING, FEATURES.COACHING_SESSIONS,
    FEATURES.AI_INSIGHTS, FEATURES.AI_PREDICTIONS,
  ]),

  // Tier 3: Monthly clinic | Academy | Coaching
  3: new Set([
    FEATURES.CONTENT_FREE, FEATURES.CONTENT_PREMIUM,
    FEATURES.RING_PAIR, FEATURES.RING_BIOMETRICS,
    FEATURES.APP_JOURNAL, FEATURES.APP_VAULT, FEATURES.APP_VAULT_SHARED,
    FEATURES.APP_TRENDS, FEATURES.APP_TRENDS_ADVANCED, FEATURES.APP_PEOPLE,
    FEATURES.APP_CHAT, FEATURES.APP_EXPLORE, FEATURES.APP_NOTIFICATIONS,
    FEATURES.CLINIC_BOOKING, FEATURES.CLINIC_SESSIONS,
    FEATURES.ACADEMY_ENROLL, FEATURES.ACADEMY_PROGRESS,
    FEATURES.COACHING_BOOKING, FEATURES.COACHING_SESSIONS,
    FEATURES.AI_INSIGHTS,
  ]),

  // Tier 4: Paid content / ring user — premium content, no clinic/academy/coaching
  4: new Set([
    FEATURES.CONTENT_FREE, FEATURES.CONTENT_PREMIUM,
    FEATURES.RING_PAIR, FEATURES.RING_BIOMETRICS,
    FEATURES.APP_JOURNAL, FEATURES.APP_VAULT,
    FEATURES.APP_TRENDS, FEATURES.APP_PEOPLE,
    FEATURES.APP_CHAT, FEATURES.APP_EXPLORE, FEATURES.APP_NOTIFICATIONS,
    FEATURES.AI_INSIGHTS,
  ]),

  // Tier 5: Freemium — basic app, no premium/AI/ring
  5: new Set([
    FEATURES.CONTENT_FREE,
    FEATURES.APP_JOURNAL, FEATURES.APP_VAULT,
    FEATURES.APP_TRENDS, FEATURES.APP_PEOPLE,
    FEATURES.APP_CHAT, FEATURES.APP_EXPLORE, FEATURES.APP_NOTIFICATIONS,
  ]),
});

// ── Organizational Tier Entitlements ─────────────────────────────
// Organizational features are additive to individual features.

const ORGANIZATIONAL_ENTITLEMENTS = Object.freeze({
  // Tier 1: Large Triad — full platform suite
  1: new Set([
    FEATURES.PORTAL_DASHBOARD, FEATURES.PORTAL_ANALYTICS, FEATURES.PORTAL_REPORTS,
    FEATURES.PORTAL_MEMBER_MGMT, FEATURES.PORTAL_ORG_SETTINGS,
    FEATURES.ADMIN_USER_MGMT, FEATURES.ADMIN_BILLING,
    FEATURES.AI_INSIGHTS, FEATURES.AI_PREDICTIONS, FEATURES.AI_RECOMMENDATIONS,
  ]),

  // Tier 2: Large Dual / Mid Triad
  2: new Set([
    FEATURES.PORTAL_DASHBOARD, FEATURES.PORTAL_ANALYTICS, FEATURES.PORTAL_REPORTS,
    FEATURES.PORTAL_MEMBER_MGMT, FEATURES.PORTAL_ORG_SETTINGS,
    FEATURES.ADMIN_USER_MGMT, FEATURES.ADMIN_BILLING,
    FEATURES.AI_INSIGHTS, FEATURES.AI_PREDICTIONS,
  ]),

  // Tier 3: Large Solo / Mid Dual / Small+Starter Triad
  3: new Set([
    FEATURES.PORTAL_DASHBOARD, FEATURES.PORTAL_ANALYTICS, FEATURES.PORTAL_REPORTS,
    FEATURES.PORTAL_MEMBER_MGMT,
    FEATURES.ADMIN_USER_MGMT,
    FEATURES.AI_INSIGHTS,
  ]),

  // Tier 4: Mid Solo / Small+Starter Dual
  4: new Set([
    FEATURES.PORTAL_DASHBOARD, FEATURES.PORTAL_ANALYTICS,
    FEATURES.PORTAL_MEMBER_MGMT,
    FEATURES.ADMIN_USER_MGMT,
  ]),

  // Tier 5: Small/Starter Solo
  5: new Set([
    FEATURES.PORTAL_DASHBOARD,
    FEATURES.PORTAL_MEMBER_MGMT,
  ]),
});

// ── Superadmin Entitlements ──────────────────────────────────────

const SUPERADMIN_ENTITLEMENTS = Object.freeze({
  // S1: Muud Health Superadmin — 100% privileges
  1: new Set([
    ...Object.values(FEATURES),
  ]),

  // S2: Muud Health Staff/Provider — 90% (no platform config)
  2: new Set([
    ...Object.values(FEATURES).filter((f) => f !== FEATURES.ADMIN_PLATFORM_CONFIG),
  ]),

  // S3: Org Account Superadmin — 75% (org-scoped)
  3: new Set([
    FEATURES.CONTENT_FREE, FEATURES.CONTENT_PREMIUM,
    FEATURES.PORTAL_DASHBOARD, FEATURES.PORTAL_ANALYTICS, FEATURES.PORTAL_REPORTS,
    FEATURES.PORTAL_MEMBER_MGMT, FEATURES.PORTAL_ORG_SETTINGS,
    FEATURES.ADMIN_USER_MGMT, FEATURES.ADMIN_BILLING,
    FEATURES.APP_JOURNAL, FEATURES.APP_VAULT, FEATURES.APP_VAULT_SHARED,
    FEATURES.APP_TRENDS, FEATURES.APP_TRENDS_ADVANCED, FEATURES.APP_PEOPLE,
    FEATURES.APP_CHAT, FEATURES.APP_EXPLORE, FEATURES.APP_NOTIFICATIONS,
    FEATURES.AI_INSIGHTS, FEATURES.AI_PREDICTIONS,
  ]),
});

// ── Entitlement Resolution ───────────────────────────────────────

/**
 * Resolve the full feature set for an account.
 *
 * @param {Object} account - Account document (from Account model)
 * @returns {Set<string>} The set of feature keys this account may access.
 */
function resolveEntitlements(account) {
  if (!account) return new Set();

  const { accountType, tier } = account;

  switch (accountType) {
    case ACCOUNT_TYPES.INDIVIDUAL:
      return new Set(INDIVIDUAL_ENTITLEMENTS[tier] || INDIVIDUAL_ENTITLEMENTS[5]);

    case ACCOUNT_TYPES.ORGANIZATIONAL: {
      // O accounts get individual T4 base + org entitlements at their tier
      const base = new Set(INDIVIDUAL_ENTITLEMENTS[4]);
      const orgFeatures = ORGANIZATIONAL_ENTITLEMENTS[tier] || ORGANIZATIONAL_ENTITLEMENTS[5];
      for (const f of orgFeatures) base.add(f);
      return base;
    }

    case ACCOUNT_TYPES.SUPERADMIN:
      return new Set(SUPERADMIN_ENTITLEMENTS[tier] || SUPERADMIN_ENTITLEMENTS[3]);

    default:
      return new Set(INDIVIDUAL_ENTITLEMENTS[5]);
  }
}

/**
 * Check if an account is entitled to a specific feature.
 */
function isEntitled(account, feature) {
  const entitlements = resolveEntitlements(account);
  return entitlements.has(feature);
}

/**
 * Check if an account has platform access (ring/app/portal).
 */
function hasPlatformAccess(account, platform) {
  if (!account) return false;
  // Superadmins always have all platform access
  if (account.accountType === ACCOUNT_TYPES.SUPERADMIN) return true;
  return account.platforms?.[platform] === true;
}

// ── Express Middleware ────────────────────────────────────────────

/**
 * Entitlements middleware — attaches `req.entitlements` with helper methods.
 * Requires `req.account` to be populated (by accountMiddleware).
 */
function entitlementsMiddleware(req, res, next) {
  const account = req.account;

  req.entitlements = {
    all: () => resolveEntitlements(account),
    has: (feature) => isEntitled(account, feature),
    hasPlatform: (platform) => hasPlatformAccess(account, platform),
    tier: account?.tier ?? 5,
    accountType: account?.accountType ?? ACCOUNT_TYPES.INDIVIDUAL,
  };

  return next();
}

/**
 * Route-level entitlement guard factory.
 * Usage: router.get('/ai/insights', requireEntitlement(FEATURES.AI_INSIGHTS), handler);
 */
function requireEntitlement(...requiredFeatures) {
  return (req, res, next) => {
    if (!req.entitlements) {
      return res.status(500).json({ error: 'Entitlements not initialized' });
    }

    for (const feature of requiredFeatures) {
      if (!req.entitlements.has(feature)) {
        return res.status(403).json({
          error: 'Insufficient entitlement',
          feature,
          message: 'Your account tier does not include access to this feature',
          upgrade: 'Contact Muud Health to upgrade your plan',
        });
      }
    }

    return next();
  };
}

/**
 * Platform access guard.
 * Usage: router.get('/portal/analytics', requirePlatform('portal'), handler);
 */
function requirePlatform(platform) {
  return (req, res, next) => {
    if (!req.entitlements?.hasPlatform(platform)) {
      return res.status(403).json({
        error: 'Platform access denied',
        platform,
        message: `Your account does not include ${platform} access`,
      });
    }
    return next();
  };
}

module.exports = {
  FEATURES,
  INDIVIDUAL_ENTITLEMENTS,
  ORGANIZATIONAL_ENTITLEMENTS,
  SUPERADMIN_ENTITLEMENTS,
  resolveEntitlements,
  isEntitled,
  hasPlatformAccess,
  entitlementsMiddleware,
  requireEntitlement,
  requirePlatform,
};
