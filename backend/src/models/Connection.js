const mongoose = require("mongoose");

const connectionSchema = new mongoose.Schema(
  {
    // ✅ should reference UserProfile (not User)
    userA: { type: mongoose.Schema.Types.ObjectId, ref: "UserProfile", required: true },
    userB: { type: mongoose.Schema.Types.ObjectId, ref: "UserProfile", required: true },

    tier: { type: String, enum: ["connection", "inner_circle"], default: "connection" },
    tag: { type: String, enum: ["Friends", "Family", "Partner", ""], default: "" },
  },
  { timestamps: true }
);

connectionSchema.index({ userA: 1, userB: 1 }, { unique: true });

module.exports = mongoose.model("Connection", connectionSchema);
