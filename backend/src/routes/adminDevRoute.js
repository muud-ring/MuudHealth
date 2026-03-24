// backend/src/routes/adminDevRoute.js
const express = require("express");
const router = express.Router();

const UserProfile = require("../models/UserProfile");
const FriendRequest = require("../models/FriendRequest");
const Connection = require("../models/Connection");

// Optional models (your project has them, but this is safe anyway)
let Conversation = null;
let Message = null;

try {
  Conversation = require("../models/Conversation");
} catch (_) { /* optional model */ }

try {
  Message = require("../models/Message");
} catch (_) { /* optional model */ }

// ⚠️ DEV ONLY: wipe People + Chat data from DocumentDB
router.post("/wipe-people", async (req, res) => {
  try {
    await FriendRequest.deleteMany({});
    await Connection.deleteMany({});
    await UserProfile.deleteMany({});

    if (Conversation?.deleteMany) await Conversation.deleteMany({});
    if (Message?.deleteMany) await Message.deleteMany({});

    return res.json({
      ok: true,
      message: "✅ Wiped UserProfile + FriendRequest + Connection + (Chat if present)",
    });
  } catch (e) {
    return res.status(500).json({ ok: false, message: e.message });
  }
});

module.exports = router;
