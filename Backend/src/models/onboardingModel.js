// backend/src/models/onboardingModel.js

// This file is written to work with the native MongoDB driver style collections.
// We'll store onboarding documents in: db.collection("onboarding")

function buildOnboardingDoc({ sub, payload }) {
    const now = new Date();
  
    return {
      sub,
      completed: Boolean(payload.completed ?? true), // default true when saved
      themeColor: payload.themeColor ?? null, // string or null
      focusGoal: payload.focusGoal ?? null, // string or null
      activities: Array.isArray(payload.activities) ? payload.activities : [], // array of strings
      notificationsEnabled:
        typeof payload.notificationsEnabled === "boolean"
          ? payload.notificationsEnabled
          : null,
      initialMood: payload.initialMood ?? null, // string or null
      createdAt: now,
      updatedAt: now,
    };
  }
  
  module.exports = { buildOnboardingDoc };
  