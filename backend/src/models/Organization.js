// Muud Health — Organization Model
// © Muud Health — Armin Hoes, MD
//
// Represents an enterprise/organizational Muud account.
// Tracks size category, product need (Triad/Dual/Solo), member roster,
// license allocation, and billing metadata.
//
// Size categories:  Large (100+), Mid (51–100), Small (11–50), Starter (1–10)
// Need categories:  Triad (ring+app+portal), Dual Mobile (ring+app),
//                   Dual Web (ring+portal), Solo (app or portal only)

const mongoose = require('mongoose');

const { ORG_SIZES, ORG_NEEDS } = require('./Account');

// ── Schema ───────────────────────────────────────────────────────

const OrganizationSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    slug: { type: String, required: true, unique: true, lowercase: true, trim: true },

    // Classification
    size: {
      type: String,
      enum: Object.values(ORG_SIZES),
      required: true,
      index: true,
    },
    need: {
      type: String,
      enum: Object.values(ORG_NEEDS),
      required: true,
      index: true,
    },

    // Computed tier (1–5) — recalculated on size/need change
    tier: {
      type: Number,
      min: 1,
      max: 5,
      required: true,
      index: true,
    },

    // ── License allocation ─────────────────────────────────────
    licenses: {
      total: { type: Number, required: true, min: 1 },
      used: { type: Number, default: 0, min: 0 },
    },

    // ── Contact & billing ──────────────────────────────────────
    primaryContact: {
      name: { type: String, default: '' },
      email: { type: String, default: '' },
      phone: { type: String, default: '' },
    },
    billingEmail: { type: String, default: '' },

    // ── Platform configuration ─────────────────────────────────
    platforms: {
      app: { type: Boolean, default: false },
      portal: { type: Boolean, default: false },
      ring: { type: Boolean, default: false },
    },

    // ── Branding ───────────────────────────────────────────────
    branding: {
      logoKey: { type: String, default: '' },     // S3 key for org logo
      primaryColor: { type: String, default: '' }, // hex color
      displayName: { type: String, default: '' },  // public-facing name
    },

    // ── Data governance ────────────────────────────────────────
    dataGovernance: {
      // Org-level data residency override (defaults to US-only global policy)
      region: { type: String, default: 'us-west-2' },
      // Whether the org requires BAA on file
      baaRequired: { type: Boolean, default: true },
      baaSignedAt: { type: Date },
      // Custom data retention (days) — 0 = default platform retention
      retentionDays: { type: Number, default: 0 },
    },

    // ── Members ────────────────────────────────────────────────
    // Lightweight embedded roster — full member data lives in Account model.
    members: [
      {
        sub: { type: String, required: true },
        role: {
          type: String,
          enum: ['member', 'manager', 'admin', 'owner'],
          default: 'member',
        },
        joinedAt: { type: Date, default: Date.now },
        _id: false,
      },
    ],

    // ── Superadmins assigned to this org ───────────────────────
    assignedSuperadmins: [{ type: String }], // subs of S3 accounts

    // ── Status ─────────────────────────────────────────────────
    status: {
      type: String,
      enum: ['active', 'trial', 'suspended', 'deactivated'],
      default: 'active',
      index: true,
    },

    contractStartDate: { type: Date },
    contractEndDate: { type: Date },
  },
  { timestamps: true }
);

// ── Indexes ──────────────────────────────────────────────────────

OrganizationSchema.index({ name: 'text' });
OrganizationSchema.index({ 'members.sub': 1 });
OrganizationSchema.index({ size: 1, need: 1 });

// ── Instance methods ─────────────────────────────────────────────

/**
 * Returns true if the org has available license seats.
 */
OrganizationSchema.methods.hasAvailableLicenses = function () {
  return this.licenses.used < this.licenses.total;
};

/**
 * Returns the number of remaining license seats.
 */
OrganizationSchema.methods.remainingLicenses = function () {
  return Math.max(0, this.licenses.total - this.licenses.used);
};

/**
 * Derives which platforms are enabled based on need category.
 */
OrganizationSchema.methods.derivePlatforms = function () {
  switch (this.need) {
    case ORG_NEEDS.TRIAD:
      return { app: true, portal: true, ring: true };
    case ORG_NEEDS.DUAL_MOBILE:
      return { app: true, portal: false, ring: true };
    case ORG_NEEDS.DUAL_WEB:
      return { app: false, portal: true, ring: true };
    case ORG_NEEDS.SOLO:
      // Default solo to app; portal requires explicit config
      return { app: true, portal: false, ring: false };
    default:
      return { app: true, portal: false, ring: false };
  }
};

/**
 * Returns the member count by role.
 */
OrganizationSchema.methods.memberCountByRole = function () {
  const counts = { member: 0, manager: 0, admin: 0, owner: 0 };
  for (const m of this.members) {
    counts[m.role] = (counts[m.role] || 0) + 1;
  }
  return counts;
};

/**
 * Size category label → numeric range.
 */
OrganizationSchema.methods.getSizeRange = function () {
  const ranges = {
    [ORG_SIZES.LARGE]: { min: 100, max: Infinity },
    [ORG_SIZES.MID]: { min: 51, max: 100 },
    [ORG_SIZES.SMALL]: { min: 11, max: 50 },
    [ORG_SIZES.STARTER]: { min: 1, max: 10 },
  };
  return ranges[this.size] || { min: 1, max: 10 };
};

// ── Pre-save: auto-derive platforms from need ────────────────────

OrganizationSchema.pre('save', function (next) {
  if (this.isModified('need') || this.isNew) {
    this.platforms = this.derivePlatforms();
  }
  next();
});

module.exports = mongoose.model('Organization', OrganizationSchema);
