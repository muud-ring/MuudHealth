const Onboarding = require("../models/Onboarding");

function cleanString(v) {
  return typeof v === "string" ? v.trim() : "";
}
function cleanBool(v, fallback = false) {
  return typeof v === "boolean" ? v : fallback;
}
function cleanStringArray(v) {
  if (!Array.isArray(v)) return [];
  return v
    .filter((x) => typeof x === "string")
    .map((x) => x.trim())
    .filter(Boolean);
}

// GET /onboarding/me
exports.getMe = async (req, res) => {
  try {
    const sub = req.user.sub;

    const doc = await Onboarding.findOne({ sub }).lean();

    if (!doc) {
      return res.status(200).json({
        sub,
        favoriteColor: "",
        focusGoal: "",
        activities: [],
        notificationsEnabled: false,
        completed: false,
      });
    }

    return res.status(200).json(doc);
  } catch (err) {
    return res.status(500).json({ message: "Failed to fetch onboarding" });
  }
};

// POST /onboarding
exports.upsert = async (req, res) => {
  try {
    const sub = req.user.sub;

    const favoriteColor = cleanString(req.body.favoriteColor);
    const focusGoal = cleanString(req.body.focusGoal);
    const activities = cleanStringArray(req.body.activities);
    const notificationsEnabled = cleanBool(req.body.notificationsEnabled, false);

    // Since onboarding is skippable:
    // - if user posts completed=true => mark completed
    // - otherwise keep completed=false
    const completed = cleanBool(req.body.completed, false);

    const updated = await Onboarding.findOneAndUpdate(
      { sub },
      {
        $set: {
          sub, // ensure stored
          favoriteColor,
          focusGoal,
          activities,
          notificationsEnabled,
          completed,
        },
      },
      { new: true, upsert: true }
    ).lean();

    return res.status(200).json({ message: "Onboarding saved", onboarding: updated });
  } catch (err) {
    return res.status(500).json({ message: "Failed to save onboarding" });
  }
};

// GET /onboarding/status
exports.getStatus = async (req, res) => {
  try {
    const sub = req.user.sub;

    const doc = await Onboarding.findOne({ sub }).select("completed").lean();

    return res.status(200).json({
      completed: doc?.completed === true,
    });
  } catch (err) {
    return res.status(500).json({ message: "Failed to fetch onboarding status" });
  }
};
