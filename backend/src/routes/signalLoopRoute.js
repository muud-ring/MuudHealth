// Muud Health — Signal Loop API Routes
// © Muud Health — Armin Hoes, MD
//
// Exposes the Signal → Insight → Action → Learn → Grow pipeline via REST.

const express = require('express');
const router = express.Router();
const requireAuth = require('../middleware/requireAuth');
const { fullAccountContext } = require('../middleware/platformAuth');
const { requireEntitlement, FEATURES } = require('../config/entitlements');
const signalLoop = require('../services/signalLoopService');
const crossPlatform = require('../services/crossPlatformSyncService');
const logger = require('../utils/logger');

// ── POST /signals — Capture a new signal ─────────────────────────
router.post('/', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const { signalType, value, metadata = {} } = req.body;
    if (!signalType || value === undefined) {
      return res.status(400).json({ error: 'signalType and value required' });
    }

    const event = await signalLoop.captureSignal(
      req.user.sub,
      signalType,
      value,
      req.platform,
      metadata
    );

    if (!event) return res.status(500).json({ error: 'Signal capture failed' });

    res.status(201).json({
      signalId: event._id,
      pipelineStage: event.pipelineStage,
      message: 'Signal captured and queued for processing',
    });
  } catch (err) {
    next(err);
  }
});

// ── POST /signals/batch — Capture multiple signals (ring sync) ───
router.post('/batch', requireAuth, fullAccountContext, async (req, res, next) => {
  try {
    const { signals } = req.body;
    if (!Array.isArray(signals) || signals.length === 0) {
      return res.status(400).json({ error: 'signals array required' });
    }

    const MAX_BATCH = 100;
    const batch = signals.slice(0, MAX_BATCH);
    const results = [];

    for (const s of batch) {
      const event = await signalLoop.captureSignal(
        req.user.sub,
        s.signalType,
        s.value,
        req.platform,
        s.metadata || {}
      );
      results.push({ signalType: s.signalType, captured: !!event, signalId: event?._id });
    }

    const captured = results.filter((r) => r.captured).length;
    logger.info({ sub: req.user.sub, total: batch.length, captured }, 'Batch signal capture');

    res.status(201).json({
      total: batch.length,
      captured,
      results,
    });
  } catch (err) {
    next(err);
  }
});

// ── GET /signals/growth — Growth evaluation for user ─────────────
router.get(
  '/growth',
  requireAuth,
  fullAccountContext,
  requireEntitlement(FEATURES.APP_TRENDS),
  async (req, res, next) => {
    try {
      const growth = await signalLoop.evaluateGrowth(req.user.sub);
      if (!growth) return res.status(500).json({ error: 'Growth evaluation failed' });
      res.json(growth);
    } catch (err) {
      next(err);
    }
  }
);

// ── GET /signals/trends — Trend snapshots for user ───────────────
router.get(
  '/trends',
  requireAuth,
  fullAccountContext,
  requireEntitlement(FEATURES.APP_TRENDS),
  async (req, res, next) => {
    try {
      const { period = 'daily', days = 30 } = req.query;
      const since = new Date();
      since.setDate(since.getDate() - Math.min(parseInt(days) || 30, 365));

      const snapshots = await crossPlatform.TrendSnapshot.find({
        userSub: req.user.sub,
        period,
        date: { $gte: since },
      }).sort({ date: -1 });

      const latest = snapshots[0] || null;

      res.json({
        snapshots,
        latest,
        period,
        count: snapshots.length,
      });
    } catch (err) {
      next(err);
    }
  }
);

// ── POST /signals/trends/generate — Force trend snapshot generation
router.post(
  '/trends/generate',
  requireAuth,
  fullAccountContext,
  async (req, res, next) => {
    try {
      const { date, period = 'daily' } = req.body;
      const targetDate = date ? new Date(date) : new Date();

      const snapshot = await crossPlatform.generateTrendSnapshot(
        req.user.sub,
        targetDate,
        period
      );

      if (!snapshot) return res.status(500).json({ error: 'Snapshot generation failed' });
      res.json({ snapshot });
    } catch (err) {
      next(err);
    }
  }
);

// ── GET /signals/recommendations — Learn stage content ───────────
router.get(
  '/recommendations',
  requireAuth,
  fullAccountContext,
  requireEntitlement(FEATURES.AI_INSIGHTS),
  async (req, res, next) => {
    try {
      // Fetch recent insights from processed signals
      const recentSignals = await signalLoop.SignalEvent.find({
        userSub: req.user.sub,
        processed: true,
        'pipelineHistory.result.insightsGenerated': { $gt: 0 },
      })
        .sort({ createdAt: -1 })
        .limit(10);

      const insights = recentSignals.flatMap((s) =>
        (s.pipelineHistory || [])
          .filter((h) => h.result?.insights)
          .flatMap((h) => h.result.insights)
      );

      const recommendations = await signalLoop.generateRecommendations(req.user.sub, insights);

      res.json({ recommendations, basedOnInsights: insights.length });
    } catch (err) {
      next(err);
    }
  }
);

module.exports = router;
