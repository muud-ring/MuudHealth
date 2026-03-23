const mongoose = require("mongoose");

const OnboardingSchema = new mongoose.Schema(
  {
    sub: { type: String, required: true, unique: true, index: true },

    // Step 1: Favorite color (optional / skippable)
    favoriteColor: { type: String, default: "" },

    // Step 2: Focus goal (Option 2 screen)
    focusGoal: {
      type: String,
      enum: ["", "Improve mood", "Increase focus and productivity", "Self-improvement", "Reduce stress or anxiety", "Other"],
      default: "",
    },

    // Step 3: Preferred activities (can store multiple)
    activities: { type: [String], default: [] },

    // Step 4: Notifications permission
    notificationsEnabled: { type: Boolean, default: false },

    // General
    completed: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Onboarding", OnboardingSchema);
