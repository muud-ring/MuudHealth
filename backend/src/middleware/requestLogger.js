// Muud Health — HTTP Request/Response Logger Middleware
// © Muud Health — Armin Hoes, MD

const crypto = require('crypto');
const logger = require('../utils/logger');

const SENSITIVE_HEADERS = new Set(['authorization', 'cookie', 'x-api-key']);
const SENSITIVE_BODY_FIELDS = new Set([
  'password', 'newPassword', 'confirmPassword', 'token', 'refreshToken',
  'accessToken', 'idToken', 'secret', 'apiKey', 'ssn', 'creditCard',
]);

/**
 * Redact sensitive fields from an object (shallow).
 */
function redactSensitive(obj, sensitiveKeys) {
  if (!obj || typeof obj !== 'object') return obj;
  const result = {};
  for (const [key, value] of Object.entries(obj)) {
    result[key] = sensitiveKeys.has(key.toLowerCase()) ? '[REDACTED]' : value;
  }
  return result;
}

/**
 * HTTP request logging middleware with correlation IDs.
 *
 * - Generates or uses X-Request-Id for request correlation
 * - Logs method, URL, status, response time, user sub
 * - Redacts sensitive headers and body fields
 */
function requestLogger(req, res, next) {
  // Correlation ID
  const requestId = req.headers['x-request-id'] || crypto.randomUUID();
  req.requestId = requestId;
  res.setHeader('X-Request-Id', requestId);

  const start = process.hrtime.bigint();

  // Log on response finish
  res.on('finish', () => {
    const duration = Number(process.hrtime.bigint() - start) / 1e6; // ms

    const logData = {
      requestId,
      method: req.method,
      url: req.originalUrl,
      statusCode: res.statusCode,
      responseTimeMs: parseFloat(duration.toFixed(2)),
      contentLength: res.getHeader('content-length') || 0,
      userSub: req.user?.sub || null,
      ip: req.ip || req.headers['x-forwarded-for'],
      userAgent: req.headers['user-agent'],
    };

    // Choose log level based on status code
    if (res.statusCode >= 500) {
      logger.error(logData, 'HTTP request completed with server error');
    } else if (res.statusCode >= 400) {
      logger.warn(logData, 'HTTP request completed with client error');
    } else {
      logger.info(logData, 'HTTP request completed');
    }
  });

  next();
}

module.exports = requestLogger;
