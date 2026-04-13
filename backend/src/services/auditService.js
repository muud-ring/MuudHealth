// Muud Health — HIPAA/SOC 2 Audit Logging Service
// © Muud Health — Armin Hoes, MD

const mongoose = require('mongoose');
const logger = require('../utils/logger');

/* ── Audit Log Schema ──────────────────────────────────────────────── */

const auditLogSchema = new mongoose.Schema(
  {
    timestamp: { type: Date, default: Date.now, index: true },
    actor: { type: String, required: true, index: true },
    action: { type: String, required: true, index: true },
    resource: { type: String, required: true },
    resourceId: { type: String, default: null },
    metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
    ip: { type: String, default: null },
    userAgent: { type: String, default: null },
    outcome: {
      type: String,
      enum: ['success', 'failure'],
      required: true,
      index: true,
    },
    sessionId: { type: String, default: null },
  },
  {
    timestamps: false,
    collection: 'audit_logs',
  }
);

// Compound index for common queries
auditLogSchema.index({ actor: 1, timestamp: -1 });
auditLogSchema.index({ resource: 1, action: 1, timestamp: -1 });

// TTL index: 7-year retention (HIPAA minimum)
auditLogSchema.index(
  { timestamp: 1 },
  { expireAfterSeconds: 7 * 365.25 * 24 * 60 * 60 }
);

const AuditLog = mongoose.model('AuditLog', auditLogSchema);

/* ── Service Functions ─────────────────────────────────────────────── */

/**
 * Record an audit event.
 *
 * @param {Object}  req        - Express request (for IP, user-agent, user)
 * @param {string}  action     - Action performed (e.g., 'user.login', 'phi.access', 'record.update')
 * @param {string}  resource   - Resource type (e.g., 'UserProfile', 'JournalEntry')
 * @param {string}  resourceId - ID of the specific resource
 * @param {Object}  metadata   - Additional context (will be PHI-masked in logs)
 * @param {string}  outcome    - 'success' or 'failure'
 */
async function log(req, action, resource, resourceId = null, metadata = {}, outcome = 'success') {
  try {
    const entry = {
      actor: req?.user?.sub || 'system',
      action,
      resource,
      resourceId,
      metadata,
      ip: req?.ip || req?.headers?.['x-forwarded-for'] || null,
      userAgent: req?.headers?.['user-agent'] || null,
      outcome,
      sessionId: req?.headers?.['x-session-id'] || null,
    };

    await AuditLog.create(entry);

    logger.debug({ action, resource, resourceId, outcome }, 'Audit event recorded');
  } catch (err) {
    // Audit failures must never crash the application
    logger.error({ err, action, resource }, 'Failed to write audit log');
  }
}

/**
 * Query audit logs with filters and pagination.
 *
 * @param {Object} filters - MongoDB query filters
 * @param {Object} options - { page, limit, sort }
 * @returns {Object} { logs, total, page, pages }
 */
async function query(filters = {}, options = {}) {
  const page = Math.max(1, options.page || 1);
  const limit = Math.min(100, Math.max(1, options.limit || 50));
  const sort = options.sort || { timestamp: -1 };

  const [logs, total] = await Promise.all([
    AuditLog.find(filters)
      .sort(sort)
      .skip((page - 1) * limit)
      .limit(limit)
      .lean(),
    AuditLog.countDocuments(filters),
  ]);

  return {
    logs,
    total,
    page,
    pages: Math.ceil(total / limit),
  };
}

/**
 * Get audit trail for a specific user.
 */
async function getUserAuditTrail(sub, options = {}) {
  return query({ actor: sub }, options);
}

/**
 * Get audit trail for a specific resource.
 */
async function getResourceAuditTrail(resource, resourceId, options = {}) {
  return query({ resource, resourceId }, options);
}

/**
 * Generate compliance report for a date range.
 */
async function generateComplianceReport(startDate, endDate) {
  const match = {
    timestamp: { $gte: new Date(startDate), $lte: new Date(endDate) },
  };

  const [totalEvents, failureEvents, actionBreakdown, topActors] = await Promise.all([
    AuditLog.countDocuments(match),
    AuditLog.countDocuments({ ...match, outcome: 'failure' }),
    AuditLog.aggregate([
      { $match: match },
      { $group: { _id: '$action', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 20 },
    ]),
    AuditLog.aggregate([
      { $match: match },
      { $group: { _id: '$actor', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 10 },
    ]),
  ]);

  return {
    reportGenerated: new Date().toISOString(),
    period: { start: startDate, end: endDate },
    summary: {
      totalEvents,
      failureEvents,
      successRate: totalEvents > 0
        ? ((totalEvents - failureEvents) / totalEvents * 100).toFixed(2) + '%'
        : 'N/A',
    },
    actionBreakdown: actionBreakdown.map(a => ({ action: a._id, count: a.count })),
    topActors: topActors.map(a => ({ actor: a._id, count: a.count })),
  };
}

/* ── Express Middleware ─────────────────────────────────────────────── */

/**
 * Middleware that auto-logs API access events.
 */
function auditMiddleware(action, resource) {
  return (req, res, next) => {
    const originalJson = res.json.bind(res);
    res.json = function (body) {
      const outcome = res.statusCode < 400 ? 'success' : 'failure';
      log(req, action, resource, req.params?.id || null, {}, outcome);
      return originalJson(body);
    };
    next();
  };
}

module.exports = {
  AuditLog,
  log,
  query,
  getUserAuditTrail,
  getResourceAuditTrail,
  generateComplianceReport,
  auditMiddleware,
};
