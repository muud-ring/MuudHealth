// Muud Health — Feature Flag Service
// © Muud Health — Armin Hoes, MD

const logger = require('../utils/logger');

/**
 * Default feature flags with their enabled states.
 * Override via FEATURE_FLAGS env var (JSON string) or per-user overrides.
 */
const DEFAULT_FLAGS = {
  ring_integration: { enabled: false, description: 'Smart ring BLE pairing and data sync' },
  ai_insights: { enabled: false, description: 'AI-powered health insights and predictions' },
  video_journal: { enabled: false, description: 'Video recording in journal entries' },
  clinic_tab: { enabled: true, description: 'Clinical sessions tab in navigation' },
  academy_tab: { enabled: true, description: 'Academy/learning tab in navigation' },
  vault_sharing: { enabled: false, description: 'Share vault items with inner circle' },
  biometric_dashboard: { enabled: true, description: 'Biometric trends dashboard' },
  push_notifications: { enabled: true, description: 'Firebase push notification delivery' },
  dark_mode: { enabled: false, description: 'Dark mode theme support' },
  hipaa_audit_log: { enabled: true, description: 'HIPAA audit logging for PHI access' },
};

// In-memory flag store (loaded from env/config on startup)
let _flags = {};
let _userOverrides = {};

/**
 * Initialize feature flags from environment or defaults.
 */
function initialize() {
  _flags = { ...DEFAULT_FLAGS };

  // Override from environment variable
  const envFlags = process.env.FEATURE_FLAGS;
  if (envFlags) {
    try {
      const parsed = JSON.parse(envFlags);
      for (const [key, value] of Object.entries(parsed)) {
        if (_flags[key]) {
          _flags[key].enabled = Boolean(value);
        } else {
          _flags[key] = { enabled: Boolean(value), description: 'Custom flag' };
        }
      }
      logger.info({ flagCount: Object.keys(parsed).length }, 'Feature flags loaded from environment');
    } catch (err) {
      logger.error({ err }, 'Failed to parse FEATURE_FLAGS env var');
    }
  }

  logger.info({
    total: Object.keys(_flags).length,
    enabled: Object.values(_flags).filter(f => f.enabled).length,
  }, 'Feature flags initialized');
}

/**
 * Check if a feature flag is enabled.
 *
 * @param {string} flagName - Flag identifier
 * @param {string} [userId] - Optional user ID for per-user overrides
 * @returns {boolean} Whether the feature is enabled
 */
function isEnabled(flagName, userId = null) {
  // Check user-level override first
  if (userId && _userOverrides[userId]?.[flagName] !== undefined) {
    return Boolean(_userOverrides[userId][flagName]);
  }

  const flag = _flags[flagName];
  if (!flag) {
    logger.debug({ flagName }, 'Unknown feature flag requested — defaulting to false');
    return false;
  }

  return flag.enabled;
}

/**
 * Get all feature flags with their current states.
 *
 * @param {string} [userId] - Optional user ID to include per-user overrides
 * @returns {Object} Map of flag name to { enabled, description }
 */
function getAllFlags(userId = null) {
  const result = {};
  for (const [key, value] of Object.entries(_flags)) {
    const userOverride = userId ? _userOverrides[userId]?.[key] : undefined;
    result[key] = {
      enabled: userOverride !== undefined ? Boolean(userOverride) : value.enabled,
      description: value.description,
      overridden: userOverride !== undefined,
    };
  }
  return result;
}

/**
 * Set a per-user flag override.
 */
function setUserOverride(userId, flagName, enabled) {
  if (!_userOverrides[userId]) _userOverrides[userId] = {};
  _userOverrides[userId][flagName] = enabled;
  logger.info({ userId, flagName, enabled }, 'User feature flag override set');
}

/**
 * Remove a per-user flag override.
 */
function clearUserOverride(userId, flagName) {
  if (_userOverrides[userId]) {
    delete _userOverrides[userId][flagName];
  }
}

/**
 * Update a global flag state.
 */
function setFlag(flagName, enabled) {
  if (!_flags[flagName]) {
    _flags[flagName] = { enabled, description: 'Dynamically added flag' };
  } else {
    _flags[flagName].enabled = enabled;
  }
  logger.info({ flagName, enabled }, 'Feature flag updated');
}

/**
 * Express middleware that attaches feature flags to the request.
 */
function featureFlagMiddleware(req, res, next) {
  req.features = {
    isEnabled: (flag) => isEnabled(flag, req.user?.sub),
    getAll: () => getAllFlags(req.user?.sub),
  };
  next();
}

// Auto-initialize on require
initialize();

module.exports = {
  initialize,
  isEnabled,
  getAllFlags,
  setFlag,
  setUserOverride,
  clearUserOverride,
  featureFlagMiddleware,
};
