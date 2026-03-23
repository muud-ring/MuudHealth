const mongoose = require('mongoose');

const biometricReadingSchema = new mongoose.Schema({
  userSub: {
    type: String,
    required: true,
    index: true,
  },
  type: {
    type: String,
    required: true,
    enum: ['heart_rate', 'hrv', 'spo2', 'temperature', 'sleep', 'steps', 'stress'],
    index: true,
  },
  value: {
    type: Number,
    required: true,
  },
  unit: {
    type: String,
    required: true,
  },
  source: {
    type: String,
    enum: ['smart_ring', 'manual', 'phone'],
    default: 'smart_ring',
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {},
  },
  recordedAt: {
    type: Date,
    required: true,
    index: true,
  },
}, {
  timestamps: true,
});

biometricReadingSchema.index({ userSub: 1, type: 1, recordedAt: -1 });
biometricReadingSchema.index({ userSub: 1, recordedAt: -1 });

module.exports = mongoose.model('BiometricReading', biometricReadingSchema);
