const express = require("express");
const router = express.Router();
const { STSClient, GetCallerIdentityCommand } = require("@aws-sdk/client-sts");
const FriendRequest = require("../models/FriendRequest"); // ✅ ADD

// ------------------
// Existing route
// ------------------
router.get("/whoami", async (req, res) => {
  try {
    const sts = new STSClient({ region: process.env.AWS_REGION || "us-west-2" });
    const out = await sts.send(new GetCallerIdentityCommand({}));
    res.json({
      account: out.Account,
      arn: out.Arn,
      userId: out.UserId,
      awsProfileEnv: process.env.AWS_PROFILE || null,
      awsRegionEnv: process.env.AWS_REGION || null,
    });
  } catch (e) {
    res.status(500).json({ message: e.message, code: e.name });
  }
});

// ------------------
// ✅ NEW: cleanup duplicate friend requests
// ------------------
router.post("/cleanup-friend-requests", async (req, res) => {
  try {
    const pending = await FriendRequest.find({ status: "pending" })
      .sort({ createdAt: -1 })
      .lean();

    const seen = new Set();
    const toDelete = [];

    for (const r of pending) {
      const key = `${r.fromSub}__${r.toSub}__pending`;
      if (seen.has(key)) {
        toDelete.push(r._id);
      } else {
        seen.add(key);
      }
    }

    if (toDelete.length > 0) {
      await FriendRequest.deleteMany({ _id: { $in: toDelete } });
    }

    return res.json({
      message: "Cleanup complete",
      deleted: toDelete.length,
    });
  } catch (err) {
    console.error("cleanup-friend-requests error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
