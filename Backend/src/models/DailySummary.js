const mongoose = require('mongoose');

const dailySummarySchema = new mongoose.Schema({
  userSub: {
    type: String,
    required: true,
    index: true,
  },
  date: {
    type: String,
    required: true,
  },
  heartRate: {
    avg: Number,
    min: Number,
    max: Number,
    resting: Number,
  },
  hrv: {
    avg: Number,
    min: Number,
    max: Number,
  },
  spo2: {
    avg: Number,
    min: Number,
  },
  temperature: {
    avg: Number,
    min: Number,
    max: Number,
  },
  sleep: {
    totalMinutes: Number,
    deepMinutes: Number,
    lightMinutes: Number,
    remMinutes: Number,
    awakeMinutes: Number,
    score: Number,
  },
  steps: {
    total: Number,
    goal: { type: Number, default: 10000 },
  },
  stress: {
    avg: Number,
    max: Number,
  },
  wellnessScore: {
    type: Number,
    min: 0,
    max: 100,
  },
}, {
  timestamps: true,
});

dailySummarySchema.index({ userSub: 1, date: -1 }, { unique: true });

module.exports = mongoose.model('DailySummary', dailySummarySchema);
