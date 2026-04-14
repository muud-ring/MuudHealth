// Muud Health — Data Residency Controls (HIPAA Compliance)
// © Muud Health — Armin Hoes, MD

const logger = require('../utils/logger');

/**
 * Approved AWS regions for PHI data storage.
 * All PHI must remain within these US-based regions per HIPAA requirements.
 */
const APPROVED_REGIONS = Object.freeze(['us-west-2', 'us-east-1']);

/**
 * Region-specific service endpoints.
 */
const REGION_CONFIG = Object.freeze({
  'us-west-2': {
    s3Endpoint: 'https://s3.us-west-2.amazonaws.com',
    cognitoEndpoint: 'https://cognito-idp.us-west-2.amazonaws.com',
    documentDbEndpoint: null, // Set via MONGO_URI
    description: 'US West (Oregon) — Primary',
  },
  'us-east-1': {
    s3Endpoint: 'https://s3.us-east-1.amazonaws.com',
    cognitoEndpoint: 'https://cognito-idp.us-east-1.amazonaws.com',
    documentDbEndpoint: null,
    description: 'US East (N. Virginia) — Failover',
  },
});

/**
 * Validate that a region is approved for PHI storage.
 *
 * @param {string} region - AWS region identifier
 * @throws {Error} If region is not in the approved list
 */
function validateRegion(region) {
  if (!APPROVED_REGIONS.includes(region)) {
    const err = new Error(
      `Data residency violation: region "${region}" is not approved for PHI. ` +
      `Approved regions: ${APPROVED_REGIONS.join(', ')}`
    );
    err.code = 'DATA_RESIDENCY_VIOLATION';
    logger.error({ region, approved: APPROVED_REGIONS }, err.message);
    throw err;
  }
}

/**
 * Get configuration for the current AWS region.
 *
 * @returns {Object} Region-specific configuration
 */
function getRegionConfig() {
  const region = process.env.AWS_REGION || 'us-west-2';
  validateRegion(region);
  return {
    region,
    ...REGION_CONFIG[region],
  };
}

/**
 * Express middleware that enforces data residency.
 * Validates server region on every request and adds compliance headers.
 */
function enforceResidency(req, res, next) {
  const region = process.env.AWS_REGION || 'us-west-2';

  try {
    validateRegion(region);
  } catch (err) {
    return res.status(503).json({
      error: 'Service unavailable',
      message: 'Data residency configuration error',
    });
  }

  // Add compliance headers
  res.set('X-Data-Region', region);
  res.set('X-Data-Residency', 'US');
  res.set('X-HIPAA-Compliant', 'true');

  next();
}

/**
 * Validate S3 bucket region matches approved regions.
 *
 * @param {string} bucketRegion - Region where the S3 bucket is located
 * @returns {boolean} True if region is approved
 */
function validateBucketRegion(bucketRegion) {
  try {
    validateRegion(bucketRegion);
    return true;
  } catch {
    return false;
  }
}

/**
 * Generate data residency compliance report.
 */
function getResidencyReport() {
  const region = process.env.AWS_REGION || 'us-west-2';
  return {
    reportGenerated: new Date().toISOString(),
    currentRegion: region,
    isApproved: APPROVED_REGIONS.includes(region),
    approvedRegions: APPROVED_REGIONS,
    services: {
      compute: { region, compliant: APPROVED_REGIONS.includes(region) },
      storage: { region, compliant: APPROVED_REGIONS.includes(region) },
      database: { region, compliant: APPROVED_REGIONS.includes(region) },
      authentication: { region, compliant: APPROVED_REGIONS.includes(region) },
    },
    policy: 'All PHI data must remain within US-based AWS regions per HIPAA requirements.',
  };
}

module.exports = {
  APPROVED_REGIONS,
  REGION_CONFIG,
  validateRegion,
  getRegionConfig,
  enforceResidency,
  validateBucketRegion,
  getResidencyReport,
};
