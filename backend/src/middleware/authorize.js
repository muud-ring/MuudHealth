// Muud Health — Role-Based Access Control (RBAC) Middleware
// © Muud Health — Armin Hoes, MD

const logger = require('../utils/logger');

const ROLES = Object.freeze({
  USER: 'user',
  MODERATOR: 'moderator',
  CLINICIAN: 'clinician',
  ADMIN: 'admin',
});

const ROLE_HIERARCHY = Object.freeze({
  [ROLES.USER]: 0,
  [ROLES.MODERATOR]: 1,
  [ROLES.CLINICIAN]: 2,
  [ROLES.ADMIN]: 3,
});

/**
 * Authorization middleware factory.
 * Checks that the authenticated user has one of the required roles.
 *
 * @param  {...string} allowedRoles - Roles permitted to access the route
 * @returns {Function} Express middleware
 *
 * Usage:
 *   router.get('/admin/users', requireAuth, authorize('admin'), handler);
 *   router.get('/clinical', requireAuth, authorize('clinician', 'admin'), handler);
 */
function authorize(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const userRole = req.user.role || ROLES.USER;

    if (!allowedRoles.includes(userRole)) {
      logger.warn({
        sub: req.user.sub,
        role: userRole,
        required: allowedRoles,
        path: req.originalUrl,
      }, 'Authorization denied — insufficient role');

      return res.status(403).json({
        error: 'Forbidden',
        message: 'You do not have permission to access this resource',
      });
    }

    return next();
  };
}

/**
 * Minimum role level middleware.
 * Allows access if user role is at or above the specified level.
 *
 * @param {string} minimumRole - Minimum role required
 * @returns {Function} Express middleware
 */
function requireMinimumRole(minimumRole) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const userRole = req.user.role || ROLES.USER;
    const userLevel = ROLE_HIERARCHY[userRole] ?? 0;
    const requiredLevel = ROLE_HIERARCHY[minimumRole] ?? 0;

    if (userLevel < requiredLevel) {
      logger.warn({
        sub: req.user.sub,
        role: userRole,
        minimumRequired: minimumRole,
        path: req.originalUrl,
      }, 'Authorization denied — role level insufficient');

      return res.status(403).json({
        error: 'Forbidden',
        message: 'You do not have permission to access this resource',
      });
    }

    return next();
  };
}

module.exports = { authorize, requireMinimumRole, ROLES, ROLE_HIERARCHY };
