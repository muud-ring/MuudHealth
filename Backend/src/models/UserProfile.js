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

    // S3
    avatarKey: { type: String, default: "" }, // users/<sub>/profile/avatar.jpg
  },
  { timestamps: true }
);

module.exports = mongoose.model("UserProfile", UserProfileSchema);
