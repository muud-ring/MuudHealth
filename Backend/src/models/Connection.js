const mongoose = require("mongoose");

const connectionSchema = new mongoose.Schema(
  {
    userA: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    userB: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },

    tier: { type: String, enum: ["connection", "inner_circle"], default: "connection" },
    tag: { type: String, enum: ["Friends", "Family", "Partner", ""], default: "" },
  },
  { timestamps: true }
);

// store one doc per pair (sorted)
connectionSchema.index({ userA: 1, userB: 1 }, { unique: true });

module.exports = mongoose.model("Connection", connectionSchema);
