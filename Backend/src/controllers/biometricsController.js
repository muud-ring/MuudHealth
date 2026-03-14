const BiometricReading = require('../models/BiometricReading');
const DailySummary = require('../models/DailySummary');

exports.recordReading = async (req, res) => {
  try {
    const userSub = req.user.sub;
    const { type, value, unit, source, metadata, recordedAt } = req.body;

    const reading = await BiometricReading.create({
      userSub,
      type,
      value,
      unit,
      source: source || 'smart_ring',
      metadata: metadata || {},
      recordedAt: recordedAt ? new Date(recordedAt) : new Date(),
    });

    res.status(201).json({ reading });
  } catch (err) {
    res.status(500).json({ error: 'Failed to record reading' });
  }
};

exports.recordBatch = async (req, res) => {
  try {
    const userSub = req.user.sub;
    const { readings } = req.body;

    if (!Array.isArray(readings) || readings.length === 0) {
      return res.status(400).json({ error: 'Readings array required' });
    }

    const docs = readings.map(r => ({
      userSub,
      type: r.type,
      value: r.value,
      unit: r.unit,
      source: r.source || 'smart_ring',
      metadata: r.metadata || {},
      recordedAt: r.recordedAt ? new Date(r.recordedAt) : new Date(),
    }));

    const result = await BiometricReading.insertMany(docs);
    res.status(201).json({ count: result.length });
  } catch (err) {
    res.status(500).json({ error: 'Failed to record batch' });
  }
};

exports.getHistory = async (req, res) => {
  try {
    const userSub = req.user.sub;
    const { type, from, to, limit } = req.query;

    const filter = { userSub };
    if (type) filter.type = type;
    if (from || to) {
      filter.recordedAt = {};
      if (from) filter.recordedAt.$gte = new Date(from);
      if (to) filter.recordedAt.$lte = new Date(to);
    }

    const readings = await BiometricReading.find(filter)
      .sort({ recordedAt: -1 })
      .limit(parseInt(limit) || 100)
      .lean();

    res.json({ readings });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch history' });
  }
};

exports.getLatest = async (req, res) => {
  try {
    const userSub = req.user.sub;
    const types = ['heart_rate', 'hrv', 'spo2', 'temperature', 'steps', 'stress'];

    const latest = {};
    for (const type of types) {
      const reading = await BiometricReading.findOne({ userSub, type })
        .sort({ recordedAt: -1 })
        .lean();
      if (reading) latest[type] = reading;
    }

    res.json({ latest });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch latest readings' });
  }
};

exports.getDailySummary = async (req, res) => {
  try {
    const userSub = req.user.sub;
    const { date } = req.params;

    let summary = await DailySummary.findOne({ userSub, date }).lean();

    if (!summary) {
      summary = await _generateDailySummary(userSub, date);
    }

    res.json({ summary });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch daily summary' });
  }
};

exports.getSummaryRange = async (req, res) => {
  try {
    const userSub = req.user.sub;
    const { from, to } = req.query;

    if (!from || !to) {
      return res.status(400).json({ error: 'from and to dates required' });
    }

    const summaries = await DailySummary.find({
      userSub,
      date: { $gte: from, $lte: to },
    }).sort({ date: -1 }).lean();

    res.json({ summaries });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch summaries' });
  }
};

async function _generateDailySummary(userSub, dateStr) {
  const dayStart = new Date(dateStr + 'T00:00:00.000Z');
  const dayEnd = new Date(dateStr + 'T23:59:59.999Z');

  const readings = await BiometricReading.find({
    userSub,
    recordedAt: { $gte: dayStart, $lte: dayEnd },
  }).lean();

  const byType = {};
  for (const r of readings) {
    if (!byType[r.type]) byType[r.type] = [];
    byType[r.type].push(r.value);
  }

  const avg = arr => arr.length ? arr.reduce((a, b) => a + b, 0) / arr.length : null;
  const min = arr => arr.length ? Math.min(...arr) : null;
  const max = arr => arr.length ? Math.max(...arr) : null;

  const summary = {
    userSub,
    date: dateStr,
    heartRate: byType.heart_rate ? {
      avg: Math.round(avg(byType.heart_rate)),
      min: min(byType.heart_rate),
      max: max(byType.heart_rate),
      resting: min(byType.heart_rate),
    } : undefined,
    hrv: byType.hrv ? {
      avg: Math.round(avg(byType.hrv)),
      min: min(byType.hrv),
      max: max(byType.hrv),
    } : undefined,
    spo2: byType.spo2 ? {
      avg: Math.round(avg(byType.spo2) * 10) / 10,
      min: min(byType.spo2),
    } : undefined,
    temperature: byType.temperature ? {
      avg: Math.round(avg(byType.temperature) * 10) / 10,
      min: min(byType.temperature),
      max: max(byType.temperature),
    } : undefined,
    steps: byType.steps ? {
      total: byType.steps.reduce((a, b) => a + b, 0),
      goal: 10000,
    } : undefined,
    stress: byType.stress ? {
      avg: Math.round(avg(byType.stress)),
      max: max(byType.stress),
    } : undefined,
  };

  const saved = await DailySummary.findOneAndUpdate(
    { userSub, date: dateStr },
    summary,
    { upsert: true, new: true }
  );

  return saved;
}
