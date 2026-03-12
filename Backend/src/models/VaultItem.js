// backend/src/models/VaultItem.js
const mongoose = require("mongoose");

const TagSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: ["theme", "feeling", "location", "person"],
      required: true,
    },
    value: { type: String, required: true },
  },
  { _id: false }
);

const VaultItemSchema = new mongoose.Schema(
  {
    ownerSub: { type: String, required: true, index: true },

    // MVP: only posts for now (your Journals are posts)
    sourceType: { type: String, enum: ["post"], default: "post", index: true },
    sourceId: { type: mongoose.Schema.Types.ObjectId, required: true, index: true },

    // 7 categories
    category: {
      type: String,
      enum: ["family", "friends", "events", "holidays", "work", "school", "other"],
      default: "other",
      index: true,
    },

    // filters (optional now; powerful later)
    tags: { type: [TagSchema], default: [] },
    experienceType: { type: String, default: "" }, // group|solo|yoga|shopping etc.

    savedAt: { type: Date, default: Date.now, index: true },
  },
  { timestamps: true }
);

// Prevent duplicates: user can’t save same post twice
VaultItemSchema.index({ ownerSub: 1, sourceType: 1, sourceId: 1 }, { unique: true });

module.exports = mongoose.model("VaultItem", VaultItemSchema);
