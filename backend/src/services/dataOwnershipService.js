// Muud Health — Data Ownership Service
// © Muud Health — Armin Hoes, MD
//
// Resolves data ownership boundaries between Individual (I) and
// Organizational (O) accounts. Core principle:
//
//   Individual accounts → User owns ALL data (PHI + usage + content)
//   Organizational accounts → Org owns usage/analytics data;
//                             User retains ownership of PHI
//   Superadmin accounts → Access-only; no data ownership
//
// HIPAA Note: PHI ownership ALWAYS remains with the individual regardless
// of account type. Organizations may access de-identified aggregates only.

const logger = require('../utils/logger');
const { ACCOUNT_TYPES } = require('../models/Account');

// ── Data Classification ──────────────────────────────────────────

const DATA_CLASSES = Object.freeze({
  PHI: 'phi',                     // Protected Health Information — always user-owned
  PII: 'pii',                     // Personally Identifiable Information
  CLINICAL: 'clinical',           // Clinical records, session notes, diagnoses
  BIOMETRIC: 'biometric',         // Ring/device sensor data
  BEHAVIORAL: 'behavioral',       // App usage patterns, engagement metrics
  CONTENT: 'content',             // User-generated content (journal, vault, posts)
  ANALYTICS: 'analytics',         // Aggregated/derived metrics
  ADMINISTRATIVE: 'administrative', // Account settings, preferences
});

// Data classes that are ALWAYS user-owned regardless of account type
const USER_OWNED_ALWAYS = new Set([
  DATA_CLASSES.PHI,
  DATA_CLASSES.PII,
  DATA_CLASSES.CLINICAL,
]);

// Data classes that are org-accessible (read-only, de-identified) for O accounts
const ORG_ACCESSIBLE = new Set([
  DATA_CLASSES.BIOMETRIC,      // Aggregated only — never raw
  DATA_CLASSES.BEHAVIORAL,     // Usage metrics
  DATA_CLASSES.ANALYTICS,      // Derived insights
]);

// Data classes with shared ownership for O accounts (user + org both have access)
const SHARED_OWNERSHIP = new Set([
  DATA_CLASSES.CONTENT,        // User-generated but org may reference
  DATA_CLASSES.BIOMETRIC,      // Raw = user, aggregated = org
]);

// ── Ownership Resolution ─────────────────────────────────────────

/**
 * Determine who owns a specific piece of data.
 *
 * @param {Object} account - The account making the request
 * @param {string} dataClass - One of DATA_CLASSES
 * @param {Object} [options] - Additional context
 * @param {boolean} [options.isAggregated] - Whether data is aggregated/de-identified
 * @returns {{ owner: string, access: string[], canDelete: boolean, canExport: boolean, canShare: boolean }}
 */
function resolveOwnership(account, dataClass, options = {}) {
  if (!account) {
    return { owner: 'unknown', access: [], canDelete: false, canExport: false, canShare: false };
  }

  const result = {
    owner: account.ownerSub,
    access: [account.ownerSub],
    canDelete: false,
    canExport: false,
    canShare: false,
  };

  // PHI/PII/Clinical: always user-owned, never org-transferable
  if (USER_OWNED_ALWAYS.has(dataClass)) {
    result.owner = account.ownerSub;
    result.canDelete = true;
    result.canExport = true;
    result.canShare = false; // PHI cannot be shared without explicit consent
    return result;
  }

  switch (account.accountType) {
    case ACCOUNT_TYPES.INDIVIDUAL:
      // Individual: user owns everything
      result.owner = account.ownerSub;
      result.canDelete = true;
      result.canExport = true;
      result.canShare = true;
      break;

    case ACCOUNT_TYPES.ORGANIZATIONAL: {
      const orgId = account.organizational?.organizationId?.toString();

      if (ORG_ACCESSIBLE.has(dataClass) && options.isAggregated) {
        // Aggregated analytics/biometric: org has read access
        result.owner = account.ownerSub;
        result.access.push(`org:${orgId}`);
        result.canDelete = true;
        result.canExport = true;
        result.canShare = false; // User can delete but org retains aggregate
      } else if (SHARED_OWNERSHIP.has(dataClass)) {
        // Shared: user owns, org can reference
        result.owner = account.ownerSub;
        result.access.push(`org:${orgId}`);
        result.canDelete = true;
        result.canExport = true;
        result.canShare = true;
      } else {
        // Default: user-owned
        result.owner = account.ownerSub;
        result.canDelete = true;
        result.canExport = true;
        result.canShare = true;
      }
      break;
    }

    case ACCOUNT_TYPES.SUPERADMIN:
      // Superadmins: access-only, no ownership
      result.owner = 'platform'; // data owned by platform or user, not SA
      result.canDelete = account.tier === 1; // Only S1 can delete
      result.canExport = account.tier <= 2;  // S1 and S2 can export
      result.canShare = false;
      break;

    default:
      result.owner = account.ownerSub;
  }

  return result;
}

/**
 * Check if an actor can access a target user's data.
 *
 * @param {Object} actorAccount - Account of the user requesting access
 * @param {string} targetSub - Sub of the user whose data is being accessed
 * @param {Object} targetAccount - Account of the target user
 * @param {string} dataClass - Classification of the data being accessed
 * @param {string} accessType - 'read' | 'write' | 'delete' | 'export'
 * @returns {{ allowed: boolean, reason: string, deIdentified: boolean }}
 */
function checkDataAccess(actorAccount, targetSub, targetAccount, dataClass, accessType = 'read') {
  // Self access — always allowed
  if (actorAccount.ownerSub === targetSub) {
    return { allowed: true, reason: 'self_access', deIdentified: false };
  }

  // PHI: never accessible by others except S1/S2 with audit
  if (USER_OWNED_ALWAYS.has(dataClass)) {
    if (actorAccount.accountType === ACCOUNT_TYPES.SUPERADMIN && actorAccount.tier <= 2) {
      if (accessType === 'read') {
        return { allowed: true, reason: 'superadmin_phi_audit', deIdentified: false };
      }
    }
    // Clinicians treating this patient
    if (actorAccount.accountType === ACCOUNT_TYPES.INDIVIDUAL) {
      const actorRole = actorAccount.role; // From UserProfile
      if (actorRole === 'clinician' && accessType === 'read') {
        return { allowed: true, reason: 'treating_clinician', deIdentified: false };
      }
    }
    return { allowed: false, reason: 'phi_protected', deIdentified: false };
  }

  // Superadmin access
  if (actorAccount.accountType === ACCOUNT_TYPES.SUPERADMIN) {
    if (actorAccount.tier === 1) {
      return { allowed: true, reason: 's1_full_access', deIdentified: false };
    }
    if (actorAccount.tier === 2 && accessType === 'read') {
      return { allowed: true, reason: 's2_read_access', deIdentified: false };
    }
    if (actorAccount.tier === 3) {
      // S3: can only access members of managed orgs
      const managedOrgs = (actorAccount.superadmin?.managedOrganizations || []).map((id) => id.toString());
      const targetOrgId = targetAccount?.organizational?.organizationId?.toString();
      if (targetOrgId && managedOrgs.includes(targetOrgId)) {
        return {
          allowed: accessType === 'read',
          reason: 's3_managed_org',
          deIdentified: !ORG_ACCESSIBLE.has(dataClass),
        };
      }
      return { allowed: false, reason: 's3_not_managed', deIdentified: false };
    }
  }

  // Org admin/owner accessing member data
  if (
    actorAccount.accountType === ACCOUNT_TYPES.ORGANIZATIONAL &&
    ['admin', 'owner'].includes(actorAccount.organizational?.orgRole)
  ) {
    const sameOrg =
      actorAccount.organizational?.organizationId?.toString() ===
      targetAccount?.organizational?.organizationId?.toString();

    if (sameOrg && ORG_ACCESSIBLE.has(dataClass)) {
      return {
        allowed: accessType === 'read',
        reason: 'org_admin_aggregate',
        deIdentified: true, // Org admins get de-identified data only
      };
    }
  }

  return { allowed: false, reason: 'no_access', deIdentified: false };
}

/**
 * Generate a data portability export manifest for an account.
 * GDPR/CCPA compliance: users can export all their owned data.
 */
function generateExportManifest(account) {
  const manifest = {
    accountSub: account.ownerSub,
    accountType: account.accountType,
    tier: account.tier,
    exportDate: new Date().toISOString(),
    dataCategories: [],
  };

  for (const [key, cls] of Object.entries(DATA_CLASSES)) {
    const ownership = resolveOwnership(account, cls);
    if (ownership.canExport) {
      manifest.dataCategories.push({
        category: key,
        classification: cls,
        owner: ownership.owner,
        exportable: true,
      });
    }
  }

  return manifest;
}

/**
 * Express middleware — attaches req.dataOwnership helper.
 */
function dataOwnershipMiddleware(req, res, next) {
  req.dataOwnership = {
    resolve: (dataClass, opts) => resolveOwnership(req.account, dataClass, opts),
    checkAccess: (targetSub, targetAccount, dataClass, accessType) =>
      checkDataAccess(req.account, targetSub, targetAccount, dataClass, accessType),
    exportManifest: () => generateExportManifest(req.account),
  };
  return next();
}

module.exports = {
  DATA_CLASSES,
  USER_OWNED_ALWAYS,
  ORG_ACCESSIBLE,
  SHARED_OWNERSHIP,
  resolveOwnership,
  checkDataAccess,
  generateExportManifest,
  dataOwnershipMiddleware,
};
