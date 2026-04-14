// Muud Health — Monitoring & Alerting Service
// © Muud Health — Armin Hoes, MD

const os = require('os');
const mongoose = require('mongoose');
const logger = require('../utils/logger');

/* ── Default Alert Thresholds ──────────────────────────────────────── */

const DEFAULT_THRESHOLDS = {
  memoryUsagePercent: 85,
  responseTimeMs: 2000,
  errorRatePercent: 5,
  dbConnectionsMax: 50,
  uptimeMinimumSeconds: 60,
};

let thresholds = { ...DEFAULT_THRESHOLDS };
let _responseTimeSamples = [];
let _errorCount = 0;
let _requestCount = 0;

/* ── Metrics Collection ────────────────────────────────────────────── */

/**
 * Record a request's response time for monitoring.
 */
function recordResponseTime(ms) {
  _responseTimeSamples.push(ms);
  _requestCount++;
  // Keep only last 1000 samples
  if (_responseTimeSamples.length > 1000) {
    _responseTimeSamples = _responseTimeSamples.slice(-1000);
  }
}

/**
 * Record an error occurrence.
 */
function recordError() {
  _errorCount++;
}

/**
 * Reset counters (typically called after each alert check cycle).
 */
function resetCounters() {
  _responseTimeSamples = [];
  _errorCount = 0;
  _requestCount = 0;
}

/* ── Health Report ─────────────────────────────────────────────────── */

/**
 * Collect comprehensive system health metrics.
 *
 * @returns {Object} Health report with system, database, and application metrics
 */
async function getHealthReport() {
  const memUsage = process.memoryUsage();
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const usedMemPercent = ((totalMem - freeMem) / totalMem * 100).toFixed(1);

  // Database status
  let dbStatus = 'disconnected';
  let dbConnections = 0;
  try {
    const state = mongoose.connection.readyState;
    dbStatus = ['disconnected', 'connected', 'connecting', 'disconnecting'][state] || 'unknown';
    if (mongoose.connection.db) {
      const serverStatus = await mongoose.connection.db.admin().serverStatus();
      dbConnections = serverStatus?.connections?.current || 0;
    }
  } catch {
    dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'error';
  }

  // Response time stats
  const avgResponseTime = _responseTimeSamples.length > 0
    ? (_responseTimeSamples.reduce((a, b) => a + b, 0) / _responseTimeSamples.length).toFixed(1)
    : 0;
  const p95ResponseTime = _responseTimeSamples.length > 0
    ? _responseTimeSamples.sort((a, b) => a - b)[Math.floor(_responseTimeSamples.length * 0.95)]
    : 0;

  const errorRate = _requestCount > 0
    ? (_errorCount / _requestCount * 100).toFixed(2)
    : 0;

  return {
    timestamp: new Date().toISOString(),
    status: 'healthy',
    uptime: process.uptime(),
    system: {
      platform: os.platform(),
      nodeVersion: process.version,
      cpuCores: os.cpus().length,
      loadAverage: os.loadavg(),
      totalMemory: totalMem,
      freeMemory: freeMem,
      usedMemoryPercent: parseFloat(usedMemPercent),
    },
    process: {
      pid: process.pid,
      heapUsed: memUsage.heapUsed,
      heapTotal: memUsage.heapTotal,
      rss: memUsage.rss,
      external: memUsage.external,
    },
    database: {
      status: dbStatus,
      connections: dbConnections,
    },
    application: {
      avgResponseTimeMs: parseFloat(avgResponseTime),
      p95ResponseTimeMs: p95ResponseTime,
      requestCount: _requestCount,
      errorCount: _errorCount,
      errorRatePercent: parseFloat(errorRate),
    },
  };
}

/* ── Alert Evaluation ──────────────────────────────────────────────── */

/**
 * Evaluate metrics against configured alert thresholds.
 *
 * @param {Object} metrics - Output from getHealthReport()
 * @returns {Object} Alert status with triggered alerts
 */
function checkAlertThresholds(metrics) {
  const alerts = [];

  if (metrics.system.usedMemoryPercent > thresholds.memoryUsagePercent) {
    alerts.push({
      severity: 'critical',
      metric: 'memory',
      value: metrics.system.usedMemoryPercent,
      threshold: thresholds.memoryUsagePercent,
      message: `Memory usage at ${metrics.system.usedMemoryPercent}% (threshold: ${thresholds.memoryUsagePercent}%)`,
    });
  }

  if (metrics.application.avgResponseTimeMs > thresholds.responseTimeMs) {
    alerts.push({
      severity: 'warning',
      metric: 'responseTime',
      value: metrics.application.avgResponseTimeMs,
      threshold: thresholds.responseTimeMs,
      message: `Avg response time ${metrics.application.avgResponseTimeMs}ms (threshold: ${thresholds.responseTimeMs}ms)`,
    });
  }

  if (metrics.application.errorRatePercent > thresholds.errorRatePercent) {
    alerts.push({
      severity: 'critical',
      metric: 'errorRate',
      value: metrics.application.errorRatePercent,
      threshold: thresholds.errorRatePercent,
      message: `Error rate at ${metrics.application.errorRatePercent}% (threshold: ${thresholds.errorRatePercent}%)`,
    });
  }

  if (metrics.database.status !== 'connected') {
    alerts.push({
      severity: 'critical',
      metric: 'database',
      value: metrics.database.status,
      threshold: 'connected',
      message: `Database status: ${metrics.database.status}`,
    });
  }

  if (alerts.length > 0) {
    logger.warn({ alertCount: alerts.length, alerts }, 'Alert thresholds breached');
    dispatchAlerts(alerts);
  }

  return {
    healthy: alerts.length === 0,
    alertCount: alerts.length,
    alerts,
    checkedAt: new Date().toISOString(),
  };
}

/**
 * Dispatch alerts to configured channels.
 * Extensible: add webhook, email, PagerDuty, etc.
 */
async function dispatchAlerts(alerts) {
  const webhookUrl = process.env.ALERT_WEBHOOK_URL;

  if (webhookUrl) {
    try {
      const { default: fetch } = await import('node-fetch');
      await fetch(webhookUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          service: 'muud-health-api',
          alerts,
          timestamp: new Date().toISOString(),
        }),
      });
    } catch (err) {
      logger.error({ err }, 'Failed to dispatch alert webhook');
    }
  }

  // Always log alerts regardless of webhook
  for (const alert of alerts) {
    logger[alert.severity === 'critical' ? 'error' : 'warn'](alert, 'ALERT');
  }
}

/**
 * Update alert thresholds at runtime.
 */
function setThresholds(newThresholds) {
  thresholds = { ...thresholds, ...newThresholds };
  logger.info({ thresholds }, 'Alert thresholds updated');
}

/**
 * Express middleware to record response times.
 */
function metricsMiddleware(req, res, next) {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    recordResponseTime(duration);
    if (res.statusCode >= 500) recordError();
  });
  next();
}

module.exports = {
  getHealthReport,
  checkAlertThresholds,
  setThresholds,
  recordResponseTime,
  recordError,
  resetCounters,
  metricsMiddleware,
};
