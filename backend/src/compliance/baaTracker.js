// Muud Health — BAA (Business Associate Agreement) Tracker
// © Muud Health — Armin Hoes, MD

const logger = require('../utils/logger');

/**
 * Registry of all cloud vendors that handle or may encounter PHI.
 * Each entry tracks the BAA status for HIPAA compliance.
 */
const BAA_REGISTRY = [
  {
    vendor: 'Amazon Web Services',
    service: 'S3 (File Storage)',
    baaStatus: 'active',
    baaDate: '2025-01-15',
    renewalDate: '2026-01-15',
    contactEmail: 'aws-baa@amazon.com',
    notes: 'AWS BAA covers S3, Cognito, DocumentDB, CloudWatch under single agreement',
  },
  {
    vendor: 'Amazon Web Services',
    service: 'Cognito (Authentication)',
    baaStatus: 'active',
    baaDate: '2025-01-15',
    renewalDate: '2026-01-15',
    contactEmail: 'aws-baa@amazon.com',
    notes: 'Covered under master AWS BAA',
  },
  {
    vendor: 'Amazon Web Services',
    service: 'DocumentDB / MongoDB Atlas',
    baaStatus: 'active',
    baaDate: '2025-01-15',
    renewalDate: '2026-01-15',
    contactEmail: 'aws-baa@amazon.com',
    notes: 'Covered under master AWS BAA',
  },
  {
    vendor: 'MongoDB Inc.',
    service: 'MongoDB Atlas (Database)',
    baaStatus: 'active',
    baaDate: '2025-02-01',
    renewalDate: '2026-02-01',
    contactEmail: 'legal@mongodb.com',
    notes: 'Atlas dedicated cluster with encryption at rest enabled',
  },
  {
    vendor: 'Twilio Inc.',
    service: 'SMS / Voice (Notifications)',
    baaStatus: 'active',
    baaDate: '2025-03-01',
    renewalDate: '2026-03-01',
    contactEmail: 'privacy@twilio.com',
    notes: 'HIPAA-eligible Twilio edition required for PHI in SMS content',
  },
  {
    vendor: 'Mailgun (Sinch)',
    service: 'Email (Transactional)',
    baaStatus: 'pending',
    baaDate: null,
    renewalDate: null,
    contactEmail: 'legal@mailgun.com',
    notes: 'BAA requested — ensure no PHI in email body until executed',
  },
  {
    vendor: 'Google (Firebase)',
    service: 'Push Notifications / Crashlytics',
    baaStatus: 'active',
    baaDate: '2025-04-01',
    renewalDate: '2026-04-01',
    contactEmail: 'firebase-support@google.com',
    notes: 'Google Cloud BAA covers Firebase services used for push and crash reporting',
  },
];

/**
 * Get BAAs expiring within the specified number of days.
 *
 * @param {number} days - Look-ahead window in days
 * @returns {Array} BAA entries expiring soon
 */
function getExpiringSoon(days = 90) {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() + days);

  return BAA_REGISTRY.filter(entry => {
    if (!entry.renewalDate) return false;
    const renewal = new Date(entry.renewalDate);
    return renewal <= cutoff && entry.baaStatus === 'active';
  });
}

/**
 * Validate that all vendors have active BAAs.
 *
 * @returns {Object} Compliance status report
 */
function validateAllBAAs() {
  const active = BAA_REGISTRY.filter(e => e.baaStatus === 'active');
  const pending = BAA_REGISTRY.filter(e => e.baaStatus === 'pending');
  const expired = BAA_REGISTRY.filter(e => e.baaStatus === 'expired');
  const notRequired = BAA_REGISTRY.filter(e => e.baaStatus === 'not_required');

  const isCompliant = expired.length === 0 && pending.length === 0;

  if (!isCompliant) {
    logger.warn({
      pendingCount: pending.length,
      expiredCount: expired.length,
      vendors: [...pending, ...expired].map(e => `${e.vendor} (${e.service})`),
    }, 'BAA compliance issue detected');
  }

  return {
    compliant: isCompliant,
    summary: {
      total: BAA_REGISTRY.length,
      active: active.length,
      pending: pending.length,
      expired: expired.length,
      notRequired: notRequired.length,
    },
    issues: [
      ...pending.map(e => ({
        severity: 'warning',
        vendor: e.vendor,
        service: e.service,
        issue: 'BAA pending — do not transmit PHI to this service',
      })),
      ...expired.map(e => ({
        severity: 'critical',
        vendor: e.vendor,
        service: e.service,
        issue: 'BAA expired — immediate renewal required',
      })),
    ],
  };
}

/**
 * Generate a BAA compliance report for compliance officers.
 */
function toBAAReport() {
  const expiringSoon = getExpiringSoon(90);
  const validation = validateAllBAAs();

  return {
    reportTitle: 'Muud Health — Business Associate Agreement Compliance Report',
    generatedAt: new Date().toISOString(),
    generatedBy: 'Muud Health Compliance System',
    organization: 'Muud Health',
    complianceOfficer: 'Armin Hoes, MD',
    overallStatus: validation.compliant ? 'COMPLIANT' : 'ACTION REQUIRED',
    summary: validation.summary,
    expiringSoon: expiringSoon.map(e => ({
      vendor: e.vendor,
      service: e.service,
      renewalDate: e.renewalDate,
      contactEmail: e.contactEmail,
    })),
    allAgreements: BAA_REGISTRY.map(e => ({
      vendor: e.vendor,
      service: e.service,
      status: e.baaStatus.toUpperCase(),
      executed: e.baaDate || 'N/A',
      renewal: e.renewalDate || 'N/A',
      notes: e.notes,
    })),
    issues: validation.issues,
    recommendations: [
      ...(expiringSoon.length > 0
        ? ['Initiate renewal process for BAAs expiring within 90 days']
        : []),
      ...validation.issues.map(i => `${i.vendor}: ${i.issue}`),
      'Review BAA registry quarterly',
      'Update registry when adding new cloud vendors or services',
    ],
  };
}

module.exports = {
  BAA_REGISTRY,
  getExpiringSoon,
  validateAllBAAs,
  toBAAReport,
};
