// backend/src/models/FriendRequest.js
const mongoose = require("mongoose");

const FriendRequestSchema = new mongoose.Schema(
  {
    fromSub: { type: String, required: true, index: true },
    toSub: { type: String, required: true, index: true },
    status: {
      type: String,
      enum: ["pending", "accepted", "declined"],
      default: "pending",
      index: true,
    },
  },
  { timestamps: true }
);

// ✅ Only one PENDING request allowed for a given fromSub -> toSub pair
FriendRequestSchema.index(
  { fromSub: 1, toSub: 1, status: 1 },
  {
    unique: true,
    partialFilterExpression: { status: "pending" },
  }
);

module.exports = mongoose.model("FriendRequest", FriendRequestSchema);
