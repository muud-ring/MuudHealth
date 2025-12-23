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

// Prevent duplicate "pending" requests for the same pair
FriendRequestSchema.index(
  { fromSub: 1, toSub: 1, status: 1 },
  { unique: true }
);

module.exports = mongoose.model("FriendRequest", FriendRequestSchema);
