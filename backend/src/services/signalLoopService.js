// Muud Health — Signal Loop Orchestration Service
// © Muud Health — Armin Hoes, MD
//
// Implements the core Muud pathway: Signal → Insight → Action → Learn → Grow
//
// Each stage is a discrete processing unit:
//   SIGNAL  — Raw data capture from ring, app, manual input
//   INSIGHT — Processing, aggregation, pattern detection, scoring
//   ACTION  — Notifications, reminders, alerts, nudges
//   LEARN   — Content recommendations, expert connections, coaching
//   GROW    — Progress tracking, milestone recognition, streak management
//
// The signal loop runs continuously:
//   - Ring pushes biometric signals every N minutes
//   - App captures behavioral signals on user interaction
//   - Portal captures administrative signals on dashboard use
//   - Each signal triggers the pipeline asynchronously

const mongoose = require('mongoose');
const logger = require('../utils/logger');

// ── Signal Types ─────────────────────────────────────────────────

const SIGNAL_TYPES = Object.freeze({
  // Ring signals
  HEART_RATE: 'heart_rate',
  HRV: 'hrv',
  SPO2: 'spo2',
  TEMPERATURE: 'temperature',
  SLEEP: 'sleep',
  STEPS: 'steps',
  STRESS: 'stress',

  // App behavioral signals
  JOURNAL_ENTRY: 'journal_entry',
  VAULT_SAVE: 'vault_save',
  CHAT_MESSAGE: 'chat_message',
  CONNECTION_MADE: 'connection_made',
  MOOD_CHECK: 'mood_check',
  APP_SESSION: 'app_session',

  // Portal signals
  REPORT_VIEWED: 'report_viewed',
  ANALYTICS_EXPORTED: 'analytics_exported',
  MEMBER_MANAGED: 'member_managed',

  // Clinical signals
  SESSION_COMPLETED: 'session_completed',
  PRESCRIPTION_UPDATED: 'prescription_updated',
  ASSESSMENT_COMPLETED: 'assessment_completed',
});

const PIPELINE_STAGES = Object.freeze({
  SIGNAL: 'signal',
  INSIGHT: 'insight',
  ACTION: 'action',
  LEARN: 'learn',
  GROW: 'grow',
});

// ── Signal Event Schema ──────────────────────────────────────────

const SignalEventSchema = new mongoose.Schema(
  {
    userSub: { type: String, required: true, index: true },
    signalType: {
      type: String,
      enum: Object.values(SIGNAL_TYPES),
      required: true,
      index: true,
    },
    source: {
      type: String,
      enum: ['ring', 'app', 'portal', 'clinic', 'manual'],
      required: true,
    },
    value: { type: mongoose.Schema.Types.Mixed, required: true },
    metadata: { type: mongoose.Schema.Types.Mixed, default: {} },

    // Pipeline tracking
    pipelineStage: {
      type: String,
      enum: Object.values(PIPELINE_STAGES),
      default: PIPELINE_STAGES.SIGNAL,
      index: true,
    },
    pipelineHistory: [
      {
        stage: { type: String },
        processedAt: { type: Date },
        result: { type: mongoose.Schema.Types.Mixed },
        _id: false,
      },
    ],

    // Processing status
    processed: { type: Boolean, default: false, index: true },
    processedAt: { type: Date },
  },
  { timestamps: true }
);

SignalEventSchema.index({ userSub: 1, signalType: 1, createdAt: -1 });
SignalEventSchema.index({ processed: 1, pipelineStage: 1 });

const SignalEvent = mongoose.model('SignalEvent', SignalEventSchema);

// ── Insight Rules ────────────────────────────────────────────────
// Configurable rules that detect patterns and generate insights.

const INSIGHT_RULES = [
  {
    id: 'low_spo2_alert',
    name: 'Low Blood Oxygen Alert',
    signalTypes: [SIGNAL_TYPES.SPO2],
    condition: (signal) => signal.value < 92,
    severity: 'high',
    insightMessage: 'Your blood oxygen level dropped below 92%. Consider consulting your provider.',
    actionType: 'notification',
  },
  {
    id: 'high_resting_hr',
    name: 'Elevated Resting Heart Rate',
    signalTypes: [SIGNAL_TYPES.HEART_RATE],
    condition: (signal) => signal.value > 100 && signal.metadata?.context === 'resting',
    severity: 'medium',
    insightMessage: 'Your resting heart rate is elevated. Take a moment to breathe and relax.',
    actionType: 'nudge',
  },
  {
    id: 'sleep_deficit',
    name: 'Sleep Deficit Detected',
    signalTypes: [SIGNAL_TYPES.SLEEP],
    condition: (signal) => signal.value < 360, // Less than 6 hours
    severity: 'medium',
    insightMessage: 'You slept less than 6 hours. Consistent sleep is key to mental wellness.',
    actionType: 'recommendation',
  },
  {
    id: 'journal_streak',
    name: 'Journal Streak Achievement',
    signalTypes: [SIGNAL_TYPES.JOURNAL_ENTRY],
    condition: (signal) => signal.metadata?.streakDays >= 7,
    severity: 'positive',
    insightMessage: 'Amazing! You\'ve journaled for 7 consecutive days. Keep growing!',
    actionType: 'milestone',
  },
  {
    id: 'high_stress',
    name: 'High Stress Detected',
    signalTypes: [SIGNAL_TYPES.STRESS],
    condition: (signal) => signal.value > 80,
    severity: 'high',
    insightMessage: 'Your stress levels are elevated. Consider a guided breathing exercise.',
    actionType: 'intervention',
  },
  {
    id: 'step_goal',
    name: 'Daily Step Goal Reached',
    signalTypes: [SIGNAL_TYPES.STEPS],
    condition: (signal) => signal.value >= 10000,
    severity: 'positive',
    insightMessage: 'You reached your 10,000 step goal today!',
    actionType: 'milestone',
  },
];

// ── Pipeline Functions ───────────────────────────────────────────

/**
 * STAGE 1: SIGNAL — Capture and persist a raw signal.
 */
async function captureSignal(userSub, signalType, value, source, metadata = {}) {
  try {
    const event = new SignalEvent({
      userSub,
      signalType,
      source,
      value,
      metadata,
      pipelineStage: PIPELINE_STAGES.SIGNAL,
    });

    event.pipelineHistory.push({
      stage: PIPELINE_STAGES.SIGNAL,
      processedAt: new Date(),
      result: { captured: true },
    });

    await event.save();

    // Immediately attempt to process through the pipeline
    setImmediate(() => processSignal(event._id).catch((err) => {
      logger.error({ err, signalId: event._id }, 'Async signal processing failed');
    }));

    return event;
  } catch (err) {
    logger.error({ err, userSub, signalType }, 'Signal capture failed');
    return null;
  }
}

/**
 * STAGE 2: INSIGHT — Process signal through insight rules.
 */
async function processSignal(signalId) {
  const signal = await SignalEvent.findById(signalId);
  if (!signal || signal.processed) return null;

  const insights = [];

  for (const rule of INSIGHT_RULES) {
    if (rule.signalTypes.includes(signal.signalType)) {
      try {
        if (rule.condition(signal)) {
          insights.push({
            ruleId: rule.id,
            ruleName: rule.name,
            severity: rule.severity,
            message: rule.insightMessage,
            actionType: rule.actionType,
          });
        }
      } catch (err) {
        logger.warn({ err, ruleId: rule.id }, 'Insight rule evaluation failed');
      }
    }
  }

  signal.pipelineStage = PIPELINE_STAGES.INSIGHT;
  signal.pipelineHistory.push({
    stage: PIPELINE_STAGES.INSIGHT,
    processedAt: new Date(),
    result: { insightsGenerated: insights.length, insights },
  });

  // If insights were generated, proceed to ACTION stage
  if (insights.length > 0) {
    for (const insight of insights) {
      await dispatchAction(signal.userSub, insight);
    }

    signal.pipelineStage = PIPELINE_STAGES.ACTION;
    signal.pipelineHistory.push({
      stage: PIPELINE_STAGES.ACTION,
      processedAt: new Date(),
      result: { actionsDispatched: insights.length },
    });
  }

  signal.processed = true;
  signal.processedAt = new Date();
  await signal.save();

  return { signal, insights };
}

/**
 * STAGE 3: ACTION — Dispatch notifications, nudges, interventions.
 */
async function dispatchAction(userSub, insight) {
  try {
    // Create a notification record (integrates with existing notification system)
    const actionRecord = {
      userSub,
      type: insight.actionType,
      ruleId: insight.ruleId,
      message: insight.message,
      severity: insight.severity,
      dispatchedAt: new Date(),
      read: false,
    };

    // In production, this would push via FCM/APNs, email, or SMS
    // For now, we persist the action for the notification endpoint to surface.
    logger.info({ userSub, ruleId: insight.ruleId, actionType: insight.actionType }, 'Action dispatched');

    return actionRecord;
  } catch (err) {
    logger.error({ err, userSub, insight }, 'Action dispatch failed');
    return null;
  }
}

/**
 * STAGE 4: LEARN — Generate content recommendations based on patterns.
 */
async function generateRecommendations(userSub, recentInsights = []) {
  const recommendations = [];

  // Map insight types to content categories
  const contentMap = {
    intervention: ['guided_breathing', 'meditation', 'grounding_exercise'],
    recommendation: ['sleep_hygiene', 'stress_management', 'mindfulness'],
    nudge: ['quick_check_in', 'gratitude_prompt', 'stretch_break'],
    milestone: ['celebration', 'next_challenge', 'share_achievement'],
  };

  for (const insight of recentInsights) {
    const content = contentMap[insight.actionType];
    if (content) {
      recommendations.push({
        userSub,
        source: insight.ruleId,
        contentType: content[Math.floor(Math.random() * content.length)],
        reason: insight.message,
        priority: insight.severity === 'high' ? 1 : insight.severity === 'medium' ? 2 : 3,
        generatedAt: new Date(),
      });
    }
  }

  return recommendations;
}

/**
 * STAGE 5: GROW — Track milestones, streaks, and progress.
 */
async function evaluateGrowth(userSub) {
  try {
    // Count recent positive signals
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const recentSignals = await SignalEvent.countDocuments({
      userSub,
      createdAt: { $gte: weekAgo },
    });

    const positiveInsights = await SignalEvent.countDocuments({
      userSub,
      createdAt: { $gte: weekAgo },
      'pipelineHistory.result.insights': { $elemMatch: { severity: 'positive' } },
    });

    // Compute engagement streak
    const dailySignals = await SignalEvent.aggregate([
      { $match: { userSub, createdAt: { $gte: new Date(Date.now() - 30 * 86400000) } } },
      { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }, count: { $sum: 1 } } },
      { $sort: { _id: -1 } },
    ]);

    let streak = 0;
    const today = new Date().toISOString().slice(0, 10);
    const dateSet = new Set(dailySignals.map((d) => d._id));
    const checkDate = new Date();

    for (let i = 0; i < 30; i++) {
      const dateStr = checkDate.toISOString().slice(0, 10);
      if (dateSet.has(dateStr)) {
        streak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    return {
      userSub,
      period: '7d',
      totalSignals: recentSignals,
      positiveInsights,
      engagementStreak: streak,
      growthLevel: streak >= 21 ? 'thriving' : streak >= 14 ? 'growing' : streak >= 7 ? 'building' : 'starting',
      evaluatedAt: new Date(),
    };
  } catch (err) {
    logger.error({ err, userSub }, 'Growth evaluation failed');
    return null;
  }
}

/**
 * Run the full pipeline for a batch of unprocessed signals.
 */
async function processPendingSignals(batchSize = 100) {
  const pending = await SignalEvent.find({ processed: false })
    .sort({ createdAt: 1 })
    .limit(batchSize);

  let processed = 0;
  let errors = 0;

  for (const signal of pending) {
    try {
      await processSignal(signal._id);
      processed++;
    } catch (err) {
      errors++;
      logger.error({ err, signalId: signal._id }, 'Pipeline processing error');
    }
  }

  return { processed, errors, total: pending.length };
}

module.exports = {
  SIGNAL_TYPES,
  PIPELINE_STAGES,
  INSIGHT_RULES,
  SignalEvent,
  captureSignal,
  processSignal,
  dispatchAction,
  generateRecommendations,
  evaluateGrowth,
  processPendingSignals,
};
