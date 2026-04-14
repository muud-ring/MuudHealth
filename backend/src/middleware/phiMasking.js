// Muud Health — PHI Field Masking Middleware (HIPAA Compliance)
// © Muud Health — Armin Hoes, MD

const logger = require('../utils/logger');

const PHI_FIELDS = new Set([
  'ssn', 'socialSecurityNumber',
  'dateOfBirth', 'dob', 'birthDate',
  'phone', 'phoneNumber', 'mobile', 'cellPhone',
  'email', 'emailAddress',
  'address', 'streetAddress', 'zipCode', 'postalCode',
  'medicalRecordNumber', 'mrn',
  'insuranceId', 'insuranceNumber', 'policyNumber',
  'diagnosis', 'diagnoses',
  'medication', 'medications', 'prescription',
  'healthCondition', 'healthConditions',
  'treatmentPlan', 'labResults',
  'geneticData', 'biometricData',
]);

const REDACTED = '***REDACTED***';

/**
 * Deep-clone an object and redact all PHI fields.
 *
 * @param {*} obj - Input value
 * @param {number} depth - Current recursion depth
 * @returns {*} Cloned value with PHI fields redacted
 */
function maskPHI(obj, depth = 0) {
  if (depth > 20) return '[MAX_DEPTH]';
  if (obj === null || obj === undefined) return obj;
  if (typeof obj !== 'object') return obj;

  if (Array.isArray(obj)) {
    return obj.map(item => maskPHI(item, depth + 1));
  }

  const masked = {};
  for (const [key, value] of Object.entries(obj)) {
    if (PHI_FIELDS.has(key)) {
      masked[key] = REDACTED;
    } else if (typeof value === 'object' && value !== null) {
      masked[key] = maskPHI(value, depth + 1);
    } else {
      masked[key] = value;
    }
  }
  return masked;
}

/**
 * Express middleware that masks PHI in logged request/response payloads.
 * Wraps res.json to intercept response bodies for audit logging.
 */
function phiLoggingMiddleware(req, res, next) {
  // Mask request body for logging
  if (req.body && typeof req.body === 'object') {
    req._maskedBody = maskPHI(req.body);
  }

  // Intercept res.json to log masked response
  const originalJson = res.json.bind(res);
  res.json = function (body) {
    if (process.env.LOG_PHI_ACCESS === 'true') {
      const maskedResponse = typeof body === 'object' ? maskPHI(body) : body;
      logger.debug({
        method: req.method,
        url: req.originalUrl,
        user: req.user?.sub || 'anonymous',
        responseStatus: res.statusCode,
        maskedBody: maskedResponse,
      }, 'PHI-masked response logged');
    }
    return originalJson(body);
  };

  next();
}

/**
 * Mask PHI fields in a Pino log serializer.
 * Attach to Pino config for automatic masking of all logged objects.
 */
function pinoPhiSerializer(obj) {
  return maskPHI(obj);
}

module.exports = {
  PHI_FIELDS,
  REDACTED,
  maskPHI,
  phiLoggingMiddleware,
  pinoPhiSerializer,
};
