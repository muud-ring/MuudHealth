// backend/src/controllers/userController.js
const UserProfile = require("../models/UserProfile");
const logger = require("../utils/logger");

// GET /user/me
exports.getMe = async (req, res) => {
  try {
    const sub = req.user.sub;

    const profile = await UserProfile.findOne({ sub }).lean();

    return res.status(200).json(
      profile || {
        sub,
        name: "",
        username: "",
        bio: "",
        location: "",
        phone: "",
        avatarKey: "",
      }
    );
  } catch (err) {
    logger.error({ err }, "getMe error");
    return res.status(500).json({ message: "Failed to fetch profile" });
  }
};

// POST /user/me  (simple upsert)
exports.upsertMe = async (req, res) => {
  try {
    const sub = req.user.sub;

    const payload = {
      name: typeof req.body?.name === "string" ? req.body.name.trim() : "",
      username: typeof req.body?.username === "string" ? req.body.username.trim() : "",
      bio: typeof req.body?.bio === "string" ? req.body.bio.trim() : "",
      location: typeof req.body?.location === "string" ? req.body.location.trim() : "",
      phone: typeof req.body?.phone === "string" ? req.body.phone.trim() : "",
    };

    const profile = await UserProfile.findOneAndUpdate(
      { sub },
      { $set: { sub, ...payload } },
      { new: true, upsert: true }
    ).lean();

    return res.status(200).json({ message: "Profile saved", profile });
  } catch (err) {
    logger.error({ err }, "upsertMe error");
    return res.status(500).json({ message: "Failed to save profile" });
  }
};
