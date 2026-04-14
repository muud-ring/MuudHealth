// backend/src/models/UserProfile.js
const mongoose = require("mongoose");

const UserProfileSchema = new mongoose.Schema(
  {
    sub: { type: String, required: true, unique: true, index: true },

    name: { type: String, default: "" },
    username: { type: String, default: "" },
    bio: { type: String, default: "" },
    location: { type: String, default: "" },
    phone: { type: String, default: "" },

    // Role-based access control
    role: {
      type: String,
      enum: ['user', 'moderator', 'clinician', 'admin'],
      default: 'user',
      index: true,
    },

    // S3
    avatarKey: { type: String, default: "" }, // users/<sub>/profile/avatar.jpg

    // Account linkage (unified I/O/S account system)
    accountId: { type: mongoose.Schema.Types.ObjectId, ref: 'Account', index: true },

    // Push notification tokens
    fcmTokens: [
      {
        token: { type: String, required: true },
        platform: { type: String, enum: ["ios", "android", "web", "unknown"], default: "unknown" },
        registeredAt: { type: Date, default: Date.now },
      },
    ],
  },
  { timestamps: true }
);

module.exports = mongoose.model("UserProfile", UserProfileSchema);