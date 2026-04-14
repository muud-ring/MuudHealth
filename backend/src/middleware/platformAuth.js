// Muud Health — Platform-Aware Authentication Middleware
// © Muud Health — Armin Hoes, MD
//
// Identifies which platform (ring, app, portal) is making the request
// and attaches account + entitlement context to the request object.
//
// Platform identification sources (in priority order):
//   1. X-Muud-Platform header (explicit)
//   2. User-Agent pattern matching (implicit)
//   3. API key prefix (for ring device API)
//   4. Referer/Origin header (for portal web requests)

const Account = require('../models/Account');
const { ACCOUNT_TYPES, PLATFORM_TYPES } = require('../models/Account');
const { entitlementsMiddleware } = require('../config/entitlements');
const { dataOwnershipMiddleware } = require('../services/dataOwnershipService');
const logger = require('../utils/logger');

// ── Platform Detection ───────────────────────────────────────────

/**
 * Detect the requesting platform from request headers and context.
 */
function detectPlatform(req) {
  // 1. Explicit header (most reliable)
  const explicit = req.headers['x-muud-platform'];
  if (explicit && Object.values(PLATFORM_TYPES).includes(explicit)) {
    return explicit;
  }

  // 2. API key prefix for ring devices
  const apiKey = req.headers['x-muud-device-key'];
  if (apiKey && apiKey.startsWith('ring_')) {
    return PLATFORM_TYPES.RING;
  }

  // 3. User-Agent patterns
  const ua = (req.headers['user-agent'] || '').toLowerCase();
  if (ua.includes('muud-ring') || ua.includes('muudsdk')) {
    return PLATFORM_TYPES.RING;
  }
  if (ua.includes('muud-portal') || ua.includes('mozilla') || ua.includes('chrome')) {
    // Web browsers likely = portal
    // But if Flutter, likely = app
    if (ua.includes('dart') || ua.includes('flutter') || ua.includes('muud-app')) {
      return PLATFORM_TYPES.APP;
    }
    return PLATFORM_TYPES.PORTAL;
  }

  // 4. Referer/Origin for portal
  const origin = req.headers.origin || req.headers.referer || '';
  if (origin.includes('portal.muudhealth.com') || origin.includes('portal.muud')) {
    return PLATFORM_TYPES.PORTAL;
  }

  // 5. Default to app
  return PLATFORM_TYPES.APP;
}

// ── Account Hydration Middleware ──────────────────────────────────

/**
 * Hydrate the full Account document for the authenticated user.
 * Must run AFTER requireAuth (which sets req.user.sub).
 *
 * Attaches:
 *   req.platform  — detected platform ('app' | 'portal' | 'ring')
 *   req.account   — full Account document (or a default guest account)
 */
async function accountMiddleware(req, res, next) {
  try {
    // Detect platform
    req.platform = detectPlatform(req);

    // Skip if no authenticated user
    if (!req.user?.sub) {
      req.account = null;
      return next();
    }

    // Look up or create account
    let account = await Account.findOne({ ownerSub: req.user.sub });

    if (!account) {
      // Auto-create Individual T5 (freemium) account on first auth
      account = new Account({
        ownerSub: req.user.sub,
        accountType: ACCOUNT_TYPES.INDIVIDUAL,
        tier: 5,
        platforms: {
          app: true,
          portal: false,
          ring: false,
        },
        dataOwnership: { type: 'individual' },
        status: 'active',
      });

      await account.save();
      logger.info({ sub: req.user.sub, platform: req.platform }, 'Auto-created Individual T5 account');
    }

    req.account = account;

    // Also enrich req.user with account context
    req.user.accountType = account.accountType;
    req.user.tier = account.tier;
    req.user.platforms = account.platforms;

    return next();
  } catch (err) {
    logger.error({ err, sub: req.user?.sub }, 'Account hydration failed');
    // Don't block the request — degrade gracefully
    req.account = null;
    return next();
  }
}

/**
 * Composite middleware that chains: accountMiddleware → entitlements → dataOwnership.
 * Use this as a single middleware for routes that need full account context.
 *
 * Usage:
 *   router.get('/protected', requireAuth, fullAccountContext, handler);
 */
function fullAccountContext(req, res, next) {
  accountMiddleware(req, res, (err) => {
    if (err) return next(err);
    entitlementsMiddleware(req, res, (err2) => {
      if (err2) return next(err2);
      dataOwnershipMiddleware(req, res, next);
    });
  });
}

/**
 * Route guard: require a specific platform.
 * Usage: router.get('/ring-only', requireAuth, fullAccountContext, requireSourcePlatform('ring'), handler);
 */
function requireSourcePlatform(...platforms) {
  return (req, res, next) => {
    if (!platforms.includes(req.platform)) {
      return res.status(403).json({
        error: 'Platform access denied',
        detectedPlatform: req.platform,
        requiredPlatforms: platforms,
        message: `This endpoint is only accessible from: ${platforms.join(', ')}`,
      });
    }
    return next();
  };
}

/**
 * Route guard: require the user's account to have access to the detected platform.
 */
function requirePlatformEntitlement(req, res, next) {
  if (!req.account) {
    return res.status(401).json({ error: 'Account required' });
  }

  if (!req.account.hasPlatformAccess(req.platform)) {
    return res.status(403).json({
      error: 'Platform not enabled',
      platform: req.platform,
      message: `Your account does not include ${req.platform} access. Contact Muud Health to upgrade.`,
    });
  }

  return next();
}

module.exports = {
  detectPlatform,
  accountMiddleware,
  fullAccountContext,
  requireSourcePlatform,
  requirePlatformEntitlement,
};
