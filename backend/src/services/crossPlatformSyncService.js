// Muud Health — Cross-Platform Sync Service
// © Muud Health — Armin Hoes, MD
//
// Orchestrates data synchronization across the MUUD Tech Triad:
//   Ring → App → Portal
//
// Core responsibilities:
//   1. Shared Vault: federated vault access across app and portal
//   2. Trends Federation: aggregate biometric + behavioral data from all platforms
//   3. Ring Sync: ingest ring data, distribute to app and portal dashboards
//   4. Conflict Resolution: last-write-wins with platform priority weighting
//
// Data flow:
//   Ring (BLE) → Phone (App) → Cloud (API) → Portal (Web)
//   Ring (BLE) → Phone (App) → Cloud (API) ← Portal (Web)
//   [bidirectional sync for vault, unidirectional for biometrics]

const mongoose = require('mongoose');
const logger = require('../utils/logger');
const { PLATFORM_TYPES } = require('../models/Account');

// ── Sync Event Schema (embedded, not a top-level collection) ─────

const SyncEventSchema = new mongoose.Schema(
  {
    userSub: { type: String, required: true, index: true },
    sourcePlatform: {
      type: String,
      enum: Object.values(PLATFORM_TYPES),
      required: true,
    },
    targetPlatform: {
      type: String,
      enum: [...Object.values(PLATFORM_TYPES), 'cloud'],
      required: true,
    },
    dataType: {
      type: String,
      enum: ['vault_item', 'biometric', 'trend_snapshot', 'journal', 'preference', 'notification'],
      required: true,
    },
    resourceId: { type: String, required: true },
    action: {
      type: String,
      enum: ['create', 'update', 'delete', 'sync'],
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'synced', 'failed', 'conflict'],
      default: 'pending',
      index: true,
    },
    conflictResolution: {
      type: String,
      enum: ['none', 'source_wins', 'target_wins', 'manual'],
      default: 'none',
    },
    syncedAt: { type: Date },
    failureReason: { type: String },
    retryCount: { type: Number, default: 0 },
    metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
  },
  { timestamps: true }
);

SyncEventSchema.index({ userSub: 1, status: 1, createdAt: -1 });
SyncEventSchema.index({ status: 1, retryCount: 1 });

const SyncEvent = mongoose.model('SyncEvent', SyncEventSchema);

// ── Shared Vault Sync ────────────────────────────────────────────
// The vault is shared across app and portal — items saved in one
// appear in the other. Ring does not have vault access.

const SharedVaultEntrySchema = new mongoose.Schema(
  {
    ownerSub: { type: String, required: true, index: true },

    // Original vault item reference
    vaultItemId: { type: mongoose.Schema.Types.ObjectId, ref: 'VaultItem', required: true },

    // Cross-platform sharing configuration
    sharedWith: [
      {
        sub: { type: String, required: true },
        accessLevel: { type: String, enum: ['view', 'edit', 'admin'], default: 'view' },
        grantedAt: { type: Date, default: Date.now },
        grantedBy: { type: String, required: true },
        _id: false,
      },
    ],

    // Organization-level sharing (for O accounts)
    sharedWithOrg: {
      organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization' },
      accessLevel: { type: String, enum: ['view', 'edit', 'none'], default: 'none' },
    },

    // Platform presence tracking
    syncedPlatforms: {
      app: { synced: { type: Boolean, default: false }, lastSyncAt: { type: Date } },
      portal: { synced: { type: Boolean, default: false }, lastSyncAt: { type: Date } },
    },

    // Vault metadata extensions
    category: { type: String, default: 'other' },
    tags: [{ type: String }],
    pinned: { type: Boolean, default: false },
  },
  { timestamps: true }
);

SharedVaultEntrySchema.index({ ownerSub: 1, 'sharedWith.sub': 1 });
SharedVaultEntrySchema.index({ 'sharedWithOrg.organizationId': 1 });

const SharedVaultEntry = mongoose.model('SharedVaultEntry', SharedVaultEntrySchema);

// ── Trend Snapshot (cross-platform aggregate) ────────────────────
// Aggregated view of user wellness across all three platforms.

const TrendSnapshotSchema = new mongoose.Schema(
  {
    userSub: { type: String, required: true, index: true },
    date: { type: Date, required: true, index: true },
    period: {
      type: String,
      enum: ['daily', 'weekly', 'monthly'],
      default: 'daily',
      index: true,
    },

    // Ring-sourced biometrics (aggregated)
    biometrics: {
      avgHeartRate: { type: Number },
      avgHrv: { type: Number },
      avgSpO2: { type: Number },
      avgTemperature: { type: Number },
      totalSteps: { type: Number },
      sleepMinutes: { type: Number },
      sleepQuality: { type: Number }, // 0–100
      stressLevel: { type: Number },  // 0–100
    },

    // App-sourced behavioral data
    behavioral: {
      journalEntries: { type: Number, default: 0 },
      journalWordCount: { type: Number, default: 0 },
      sentimentAvg: { type: Number },        // -1 to 1
      chatMessagesSent: { type: Number, default: 0 },
      connectionsActive: { type: Number, default: 0 },
      appSessionMinutes: { type: Number, default: 0 },
      vaultItemsSaved: { type: Number, default: 0 },
    },

    // Portal-sourced data (if applicable)
    portal: {
      reportsViewed: { type: Number, default: 0 },
      analyticsExports: { type: Number, default: 0 },
    },

    // Derived wellness scores (computed from biometrics + behavioral)
    wellness: {
      overallScore: { type: Number },   // 0–100
      physicalScore: { type: Number },   // Biometric-derived
      mentalScore: { type: Number },     // Journal sentiment + engagement
      socialScore: { type: Number },     // Connections + chat activity
      consistencyScore: { type: Number }, // Streak/habit adherence
    },

    // Source tracking: which platforms contributed to this snapshot
    sources: {
      ring: { type: Boolean, default: false },
      app: { type: Boolean, default: false },
      portal: { type: Boolean, default: false },
    },
  },
  { timestamps: true }
);

TrendSnapshotSchema.index({ userSub: 1, date: -1, period: 1 }, { unique: true });

const TrendSnapshot = mongoose.model('TrendSnapshot', TrendSnapshotSchema);

// ── Sync Service Functions ───────────────────────────────────────

/**
 * Record a sync event (for audit and retry purposes).
 */
async function recordSyncEvent(params) {
  try {
    const event = new SyncEvent(params);
    await event.save();
    return event;
  } catch (err) {
    logger.error({ err, params }, 'Failed to record sync event');
    return null;
  }
}

/**
 * Sync a vault item across platforms.
 * When a vault item is created/updated in app, create a SharedVaultEntry
 * so it's accessible in portal, and vice versa.
 */
async function syncVaultItem(userSub, vaultItemId, sourcePlatform, action = 'sync') {
  try {
    let entry = await SharedVaultEntry.findOne({ ownerSub: userSub, vaultItemId });

    if (!entry) {
      entry = new SharedVaultEntry({
        ownerSub: userSub,
        vaultItemId,
        syncedPlatforms: {
          app: { synced: sourcePlatform === PLATFORM_TYPES.APP, lastSyncAt: sourcePlatform === PLATFORM_TYPES.APP ? new Date() : undefined },
          portal: { synced: sourcePlatform === PLATFORM_TYPES.PORTAL, lastSyncAt: sourcePlatform === PLATFORM_TYPES.PORTAL ? new Date() : undefined },
        },
      });
    } else {
      if (sourcePlatform === PLATFORM_TYPES.APP || sourcePlatform === PLATFORM_TYPES.PORTAL) {
        entry.syncedPlatforms[sourcePlatform].synced = true;
        entry.syncedPlatforms[sourcePlatform].lastSyncAt = new Date();
      }
    }

    await entry.save();

    // Record sync event
    const targetPlatform = sourcePlatform === PLATFORM_TYPES.APP ? PLATFORM_TYPES.PORTAL : PLATFORM_TYPES.APP;
    await recordSyncEvent({
      userSub,
      sourcePlatform,
      targetPlatform,
      dataType: 'vault_item',
      resourceId: vaultItemId.toString(),
      action,
      status: 'synced',
      syncedAt: new Date(),
    });

    return entry;
  } catch (err) {
    logger.error({ err, userSub, vaultItemId }, 'Vault sync failed');
    await recordSyncEvent({
      userSub,
      sourcePlatform,
      targetPlatform: 'cloud',
      dataType: 'vault_item',
      resourceId: vaultItemId.toString(),
      action,
      status: 'failed',
      failureReason: err.message,
    });
    return null;
  }
}

/**
 * Share a vault item with another user or organization.
 */
async function shareVaultItem(ownerSub, vaultItemId, targetSub, accessLevel = 'view') {
  try {
    let entry = await SharedVaultEntry.findOne({ ownerSub, vaultItemId });
    if (!entry) {
      entry = new SharedVaultEntry({ ownerSub, vaultItemId });
    }

    // Check if already shared
    const existing = entry.sharedWith.find((s) => s.sub === targetSub);
    if (existing) {
      existing.accessLevel = accessLevel;
    } else {
      entry.sharedWith.push({
        sub: targetSub,
        accessLevel,
        grantedBy: ownerSub,
      });
    }

    await entry.save();
    return entry;
  } catch (err) {
    logger.error({ err, ownerSub, vaultItemId, targetSub }, 'Vault share failed');
    return null;
  }
}

/**
 * Generate or update a trend snapshot for a user.
 * Aggregates data from all three platforms.
 */
async function generateTrendSnapshot(userSub, date, period = 'daily') {
  try {
    const BiometricReading = mongoose.model('BiometricReading');

    // Date range for aggregation
    const startDate = new Date(date);
    startDate.setHours(0, 0, 0, 0);
    const endDate = new Date(startDate);

    if (period === 'daily') endDate.setDate(endDate.getDate() + 1);
    else if (period === 'weekly') endDate.setDate(endDate.getDate() + 7);
    else if (period === 'monthly') endDate.setMonth(endDate.getMonth() + 1);

    // Aggregate biometrics from ring
    const biometrics = await BiometricReading.aggregate([
      { $match: { userSub, recordedAt: { $gte: startDate, $lt: endDate } } },
      {
        $group: {
          _id: '$type',
          avg: { $avg: '$value' },
          sum: { $sum: '$value' },
          count: { $sum: 1 },
        },
      },
    ]);

    const bioMap = {};
    for (const b of biometrics) {
      bioMap[b._id] = b;
    }

    // Aggregate journal entries
    let journalStats = { entries: 0, wordCount: 0, sentimentAvg: 0 };
    try {
      const Post = mongoose.model('Post');
      const journals = await Post.aggregate([
        { $match: { authorSub: userSub, createdAt: { $gte: startDate, $lt: endDate } } },
        {
          $group: {
            _id: null,
            count: { $sum: 1 },
            totalWords: { $sum: { $size: { $split: [{ $ifNull: ['$body', ''] }, ' '] } } },
          },
        },
      ]);
      if (journals[0]) {
        journalStats.entries = journals[0].count;
        journalStats.wordCount = journals[0].totalWords;
      }
    } catch { /* Post model may not exist in test */ }

    // Build snapshot
    const snapshot = {
      userSub,
      date: startDate,
      period,
      biometrics: {
        avgHeartRate: bioMap.heart_rate?.avg,
        avgHrv: bioMap.hrv?.avg,
        avgSpO2: bioMap.spo2?.avg,
        avgTemperature: bioMap.temperature?.avg,
        totalSteps: bioMap.steps?.sum,
        sleepMinutes: bioMap.sleep?.sum,
        stressLevel: bioMap.stress?.avg,
      },
      behavioral: {
        journalEntries: journalStats.entries,
        journalWordCount: journalStats.wordCount,
        sentimentAvg: journalStats.sentimentAvg,
      },
      sources: {
        ring: Object.keys(bioMap).length > 0,
        app: journalStats.entries > 0,
        portal: false,
      },
    };

    // Compute wellness scores
    snapshot.wellness = computeWellnessScores(snapshot);

    // Upsert
    const result = await TrendSnapshot.findOneAndUpdate(
      { userSub, date: startDate, period },
      { $set: snapshot },
      { upsert: true, new: true }
    );

    return result;
  } catch (err) {
    logger.error({ err, userSub, date, period }, 'Trend snapshot generation failed');
    return null;
  }
}

/**
 * Compute composite wellness scores from biometric + behavioral data.
 */
function computeWellnessScores(snapshot) {
  const scores = { overallScore: 0, physicalScore: 0, mentalScore: 0, socialScore: 0, consistencyScore: 0 };

  // Physical: heart rate in healthy range, SpO2 > 95, sleep > 420 min (7hr)
  const hr = snapshot.biometrics?.avgHeartRate;
  const spo2 = snapshot.biometrics?.avgSpO2;
  const sleep = snapshot.biometrics?.sleepMinutes;

  if (hr) scores.physicalScore += hr >= 55 && hr <= 85 ? 30 : 15;
  if (spo2) scores.physicalScore += spo2 >= 95 ? 35 : spo2 >= 90 ? 20 : 10;
  if (sleep) scores.physicalScore += sleep >= 420 ? 35 : sleep >= 300 ? 25 : 10;

  // Mental: journal engagement + sentiment
  const journals = snapshot.behavioral?.journalEntries || 0;
  scores.mentalScore = Math.min(100, journals * 20 + 30);

  // Social: connections + chat (placeholder)
  const chatMsgs = snapshot.behavioral?.chatMessagesSent || 0;
  scores.socialScore = Math.min(100, chatMsgs * 5 + 40);

  // Consistency: having data from multiple sources
  const sourceCount = [snapshot.sources?.ring, snapshot.sources?.app, snapshot.sources?.portal].filter(Boolean).length;
  scores.consistencyScore = Math.min(100, sourceCount * 33 + 1);

  // Overall: weighted average
  scores.overallScore = Math.round(
    scores.physicalScore * 0.35 +
    scores.mentalScore * 0.30 +
    scores.socialScore * 0.15 +
    scores.consistencyScore * 0.20
  );

  return scores;
}

/**
 * Get pending sync events for retry processing.
 */
async function getPendingSyncEvents(limit = 50) {
  return SyncEvent.find({ status: { $in: ['pending', 'failed'] }, retryCount: { $lt: 5 } })
    .sort({ createdAt: 1 })
    .limit(limit);
}

/**
 * Get the latest trend snapshot for a user.
 */
async function getLatestSnapshot(userSub, period = 'daily') {
  return TrendSnapshot.findOne({ userSub, period }).sort({ date: -1 });
}

/**
 * Get shared vault items for a user (items shared WITH them).
 */
async function getSharedVaultItems(userSub, options = {}) {
  const { page = 1, limit = 20 } = options;
  const skip = (page - 1) * limit;

  return SharedVaultEntry.find({ 'sharedWith.sub': userSub })
    .populate('vaultItemId')
    .sort({ updatedAt: -1 })
    .skip(skip)
    .limit(limit);
}

module.exports = {
  SyncEvent,
  SharedVaultEntry,
  TrendSnapshot,
  recordSyncEvent,
  syncVaultItem,
  shareVaultItem,
  generateTrendSnapshot,
  computeWellnessScores,
  getPendingSyncEvents,
  getLatestSnapshot,
  getSharedVaultItems,
};
