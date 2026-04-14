// Muud Health — Service Plan Model
// © Muud Health — Armin Hoes, MD
//
// Represents the 3×3×3 Muud Clinic service offering plus Academy and Coaching.
//
// Categories:
//   clinic    — Healthcare services (PMF, TMF, CMF)
//   academy   — Instructional programs (e.g., NBHWC certification)
//   coaching  — Interventional wellness coaching
//   content   — Premium content subscription (SAAS)
//
// Clinic plan types (3):
//   PMF = Psychiatry & Mental Fitness   (45 min)
//   TMF = Therapy & Mental Fitness      (60 min)
//   CMF = Combined Mental Fitness       (75 min)
//
// Frequencies (3):
//   weekly | biweekly | monthly
//
// Tier determination:
//   T1 = CMF weekly/biweekly
//   T2 = PMF/TMF weekly/biweekly
//   T3 = Any clinic monthly | Academy | Coaching weekly/biweekly
//   T4 = Content subscription only (auto for ring users)
//   T5 = Freemium

const mongoose = require('mongoose');

// ── Constants ────────────────────────────────────────────────────

const PLAN_CATEGORIES = Object.freeze({
  CLINIC: 'clinic',
  ACADEMY: 'academy',
  COACHING: 'coaching',
  CONTENT: 'content',
});

const CLINIC_PLAN_TYPES = Object.freeze({
  PMF: 'PMF', // Psychiatry & Mental Fitness — 45 min
  TMF: 'TMF', // Therapy & Mental Fitness — 60 min
  CMF: 'CMF', // Combined Mental Fitness — 75 min
});

const PLAN_FREQUENCIES = Object.freeze({
  WEEKLY: 'weekly',
  BIWEEKLY: 'biweekly',
  MONTHLY: 'monthly',
});

const SESSION_DURATIONS = Object.freeze({
  PMF: 45, // minutes
  TMF: 60,
  CMF: 75,
});

// ── Schema ───────────────────────────────────────────────────────

const ServicePlanSchema = new mongoose.Schema(
  {
    // Owner reference
    ownerSub: { type: String, required: true, index: true },

    // Plan classification
    category: {
      type: String,
      enum: Object.values(PLAN_CATEGORIES),
      required: true,
      index: true,
    },

    // Clinic-specific: PMF, TMF, or CMF
    planType: {
      type: String,
      enum: [...Object.values(CLINIC_PLAN_TYPES), 'general'],
      default: 'general',
    },

    // Session frequency
    frequency: {
      type: String,
      enum: [...Object.values(PLAN_FREQUENCIES), 'on_demand', 'program'],
      default: 'monthly',
    },

    // Session duration in minutes (auto-populated for clinic plans)
    sessionDuration: {
      type: Number,
      default: 0,
    },

    // ── Academy-specific fields ────────────────────────────────
    academy: {
      programName: { type: String, default: '' },       // e.g., "NBHWC Certification"
      programType: { type: String, default: '' },        // e.g., "certification", "workshop"
      totalModules: { type: Number, default: 0 },
      completedModules: { type: Number, default: 0 },
      enrolledAt: { type: Date },
      expectedCompletionDate: { type: Date },
    },

    // ── Coaching-specific fields ───────────────────────────────
    coaching: {
      coachSub: { type: String, default: '' },           // Assigned coach's sub
      coachName: { type: String, default: '' },
      specialty: { type: String, default: '' },          // e.g., "wellness", "nutrition"
      sessionsCompleted: { type: Number, default: 0 },
      nextSessionDate: { type: Date },
    },

    // ── Clinic-specific fields ─────────────────────────────────
    clinic: {
      providerSub: { type: String, default: '' },        // Assigned provider's sub
      providerName: { type: String, default: '' },
      providerType: { type: String, default: '' },       // "psychiatrist", "therapist"
      sessionsCompleted: { type: Number, default: 0 },
      nextSessionDate: { type: Date },
      diagnosisCodes: [{ type: String }],                // ICD-10 codes (encrypted at rest)
    },

    // ── Subscription/billing ───────────────────────────────────
    pricing: {
      amount: { type: Number, default: 0 },              // in cents
      currency: { type: String, default: 'USD' },
      billingCycle: { type: String, enum: ['monthly', 'quarterly', 'annual'], default: 'monthly' },
    },

    // ── Status ─────────────────────────────────────────────────
    status: {
      type: String,
      enum: ['active', 'paused', 'cancelled', 'completed', 'pending'],
      default: 'pending',
      index: true,
    },

    startDate: { type: Date },
    endDate: { type: Date },

    // Computed tier impact
    impliedTier: {
      type: Number,
      min: 1,
      max: 5,
      index: true,
    },

    // Organizational context (if plan is org-sponsored)
    organizationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Organization' },
  },
  { timestamps: true }
);

// ── Indexes ──────────────────────────────────────────────────────

ServicePlanSchema.index({ ownerSub: 1, status: 1 });
ServicePlanSchema.index({ ownerSub: 1, category: 1, status: 1 });
ServicePlanSchema.index({ organizationId: 1, status: 1 });

// ── Pre-save: auto-populate derived fields ───────────────────────

ServicePlanSchema.pre('save', function (next) {
  // Auto-set session duration for clinic plans
  if (this.category === PLAN_CATEGORIES.CLINIC && SESSION_DURATIONS[this.planType]) {
    this.sessionDuration = SESSION_DURATIONS[this.planType];
  }

  // Compute implied tier
  this.impliedTier = computeImpliedTier(this);

  next();
});

/**
 * Compute the tier this plan implies for the account.
 */
function computeImpliedTier(plan) {
  if (plan.category === PLAN_CATEGORIES.CLINIC) {
    if (plan.planType === 'CMF' && ['weekly', 'biweekly'].includes(plan.frequency)) return 1;
    if (['PMF', 'TMF'].includes(plan.planType) && ['weekly', 'biweekly'].includes(plan.frequency)) return 2;
    if (plan.frequency === 'monthly') return 3;
  }
  if (plan.category === PLAN_CATEGORIES.ACADEMY) return 3;
  if (plan.category === PLAN_CATEGORIES.COACHING && ['weekly', 'biweekly'].includes(plan.frequency)) return 3;
  if (plan.category === PLAN_CATEGORIES.CONTENT) return 4;
  return 5;
}

// ── Instance methods ─────────────────────────────────────────────

/**
 * Returns human-readable plan summary.
 */
ServicePlanSchema.methods.getSummary = function () {
  const parts = [];

  if (this.category === PLAN_CATEGORIES.CLINIC) {
    parts.push(`${this.planType} (${this.sessionDuration}min ${this.frequency})`);
  } else if (this.category === PLAN_CATEGORIES.ACADEMY) {
    parts.push(`Academy: ${this.academy?.programName || 'Program'}`);
  } else if (this.category === PLAN_CATEGORIES.COACHING) {
    parts.push(`Coaching (${this.frequency}) with ${this.coaching?.coachName || 'TBD'}`);
  } else {
    parts.push('Content Subscription');
  }

  parts.push(`Status: ${this.status}`);
  parts.push(`Tier Impact: T${this.impliedTier}`);

  return parts.join(' | ');
};

/**
 * Returns true if this plan is currently active.
 */
ServicePlanSchema.methods.isActive = function () {
  if (this.status !== 'active') return false;
  if (this.endDate && this.endDate < new Date()) return false;
  return true;
};

module.exports = mongoose.model('ServicePlan', ServicePlanSchema);
module.exports.PLAN_CATEGORIES = PLAN_CATEGORIES;
module.exports.CLINIC_PLAN_TYPES = CLINIC_PLAN_TYPES;
module.exports.PLAN_FREQUENCIES = PLAN_FREQUENCIES;
module.exports.SESSION_DURATIONS = SESSION_DURATIONS;
