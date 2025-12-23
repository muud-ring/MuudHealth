// backend/src/controllers/peopleController.js

const Connection = require("../models/Connection");
const FriendRequest = require("../models/FriendRequest");
const UserProfile = require("../models/UserProfile");

/* -------------------------------------------------------------------------- */
/*                               Helper Utils                                 */
/* -------------------------------------------------------------------------- */

async function getMyProfile(req) {
  const mySub = req.user?.sub;
  if (!mySub) return null;
  return UserProfile.findOne({ sub: mySub }, { _id: 1, sub: 1 }).lean();
}

function getOtherUserId(connection, myId) {
  return String(connection.userA) === String(myId)
    ? connection.userB
    : connection.userA;
}

/* -------------------------------------------------------------------------- */
/*                                   Lists                                    */
/* -------------------------------------------------------------------------- */

/**
 * GET /people/connections
 */
exports.getConnections = async (req, res) => {
  try {
    const me = await getMyProfile(req);
    if (!me) return res.status(401).json({ message: "UserProfile not found" });

    const connections = await Connection.find({
      tier: "connection",
      $or: [{ userA: me._id }, { userB: me._id }],
    }).lean();

    const otherUserIds = connections.map((c) =>
      getOtherUserId(c, me._id)
    );

    const profiles = await UserProfile.find(
      { _id: { $in: otherUserIds } },
      { sub: 1, name: 1, username: 1, bio: 1, location: 1, avatarKey: 1 }
    ).lean();

    return res.status(200).json({ connections: profiles });
  } catch (err) {
    console.error("getConnections error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * GET /people/inner-circle
 */
exports.getInnerCircle = async (req, res) => {
  try {
    const me = await getMyProfile(req);
    if (!me) return res.status(401).json({ message: "UserProfile not found" });

    const connections = await Connection.find({
      tier: "inner_circle",
      $or: [{ userA: me._id }, { userB: me._id }],
    }).lean();

    const otherUserIds = connections.map((c) =>
      getOtherUserId(c, me._id)
    );

    const profiles = await UserProfile.find(
      { _id: { $in: otherUserIds } },
      { sub: 1, name: 1, username: 1, bio: 1, location: 1, avatarKey: 1 }
    ).lean();

    return res.status(200).json({ innerCircle: profiles });
  } catch (err) {
    console.error("getInnerCircle error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * GET /people/suggestions?q=
 */
exports.getSuggestions = async (req, res) => {
  try {
    const me = await getMyProfile(req);
    if (!me) return res.status(401).json({ message: "UserProfile not found" });

    const q = (req.query.q || "").trim();
    const limit = Math.min(parseInt(req.query.limit || "20", 10), 50);

    const connections = await Connection.find({
      $or: [{ userA: me._id }, { userB: me._id }],
    }).lean();

    const connectedIds = connections.map((c) =>
      getOtherUserId(c, me._id)
    );

    const pending = await FriendRequest.find({
      status: "pending",
      $or: [{ fromSub: me.sub }, { toSub: me.sub }],
    }).lean();

    const excludeSubs = new Set([me.sub]);
    pending.forEach((r) => {
      excludeSubs.add(r.fromSub);
      excludeSubs.add(r.toSub);
    });

    const query = {
      _id: { $nin: [me._id, ...connectedIds] },
      sub: { $nin: Array.from(excludeSubs) },
    };

    if (q) {
      query.$or = [
        { name: { $regex: q, $options: "i" } },
        { username: { $regex: q, $options: "i" } },
      ];
    }

    const suggestions = await UserProfile.find(
      query,
      { sub: 1, name: 1, username: 1, bio: 1, location: 1, avatarKey: 1 }
    )
      .limit(limit)
      .lean();

    return res.status(200).json({ suggestions });
  } catch (err) {
    console.error("getSuggestions error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/* -------------------------------------------------------------------------- */
/*                                Friend Requests                              */
/* -------------------------------------------------------------------------- */

/**
 * GET /people/requests
 */
exports.getRequests = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    if (!mySub) return res.status(401).json({ message: "Missing user sub" });

    const incoming = await FriendRequest.find({
      toSub: mySub,
      status: "pending",
    })
      .sort({ createdAt: -1 })
      .lean();

    const fromSubs = incoming.map((r) => r.fromSub);

    const profiles = await UserProfile.find(
      { sub: { $in: fromSubs } },
      { sub: 1, name: 1, username: 1, avatarKey: 1 }
    ).lean();

    const map = new Map(profiles.map((p) => [p.sub, p]));

    const requests = incoming.map((r) => ({
      ...r,
      fromUser: map.get(r.fromSub) || null,
    }));

    return res.status(200).json({ requests });
  } catch (err) {
    console.error("getRequests error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/* -------------------------------------------------------------------------- */
/*                                   Actions                                  */
/* -------------------------------------------------------------------------- */

/**
 * POST /people/request/:sub
 */
exports.sendRequest = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    const targetSub = req.params.sub;

    if (!mySub || !targetSub) {
      return res.status(400).json({ message: "Invalid request" });
    }
    if (mySub === targetSub) {
      return res.status(400).json({ message: "Cannot request yourself" });
    }

    const exists = await FriendRequest.findOne({
      status: "pending",
      $or: [
        { fromSub: mySub, toSub: targetSub },
        { fromSub: targetSub, toSub: mySub },
      ],
    });

    if (exists) {
      return res.status(400).json({ message: "Request already exists" });
    }

    const request = await FriendRequest.create({
      fromSub: mySub,
      toSub: targetSub,
      status: "pending",
    });

    return res.status(201).json({ request });
  } catch (err) {
    console.error("sendRequest error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * POST /people/request/:requestId/accept
 * Only receiver can accept. Creates/ensures connection.
 */
exports.acceptRequest = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    if (!mySub) return res.status(401).json({ message: "Missing user sub" });

    const request = await FriendRequest.findById(req.params.requestId);
    if (!request) return res.status(404).json({ message: "Request not found" });

    if (request.status !== "pending") {
      return res.status(400).json({ message: "Request already handled" });
    }

    // ✅ Security: only the receiver can accept
    if (request.toSub !== mySub) {
      return res.status(403).json({ message: "Only the receiver can accept this request" });
    }

    const [fromUser, toUser] = await Promise.all([
      UserProfile.findOne({ sub: request.fromSub }, { _id: 1 }).lean(),
      UserProfile.findOne({ sub: request.toSub }, { _id: 1 }).lean(),
    ]);

    if (!fromUser || !toUser) {
      return res.status(400).json({ message: "UserProfile missing" });
    }

    const a = String(fromUser._id) < String(toUser._id) ? fromUser._id : toUser._id;
    const b = a === fromUser._id ? toUser._id : fromUser._id;

    await Connection.updateOne(
      { userA: a, userB: b },
      { $setOnInsert: { tier: "connection" } },
      { upsert: true }
    );

    request.status = "accepted";
    await request.save();

    return res.status(200).json({ message: "Request accepted" });
  } catch (err) {
    console.error("acceptRequest error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * POST /people/request/:requestId/decline
 * Only receiver can decline.
 */
exports.declineRequest = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    if (!mySub) return res.status(401).json({ message: "Missing user sub" });

    const request = await FriendRequest.findById(req.params.requestId);
    if (!request) return res.status(404).json({ message: "Request not found" });

    if (request.status !== "pending") {
      return res.status(400).json({ message: "Request already handled" });
    }

    if (request.toSub !== mySub) {
      return res.status(403).json({ message: "Only the receiver can decline this request" });
    }

    request.status = "declined";
    await request.save();

    return res.status(200).json({ message: "Request declined" });
  } catch (err) {
    console.error("declineRequest error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * POST /people/:sub/tier
 */
exports.updateTier = async (req, res) => {
  try {
    const me = await getMyProfile(req);
    const targetSub = req.params.sub;
    const { tier } = req.body;

    if (!me || !["connection", "inner_circle"].includes(tier)) {
      return res.status(400).json({ message: "Invalid request" });
    }

    const target = await UserProfile.findOne({ sub: targetSub }, { _id: 1 }).lean();
    if (!target) return res.status(404).json({ message: "User not found" });

    const a = String(me._id) < String(target._id) ? me._id : target._id;
    const b = a === me._id ? target._id : me._id;

    const updated = await Connection.findOneAndUpdate(
      { userA: a, userB: b },
      { tier },
      { new: true }
    ).lean();

    if (!updated) {
      return res.status(404).json({ message: "Connection not found" });
    }

    return res.status(200).json({ message: "Tier updated", tier: updated.tier });
  } catch (err) {
    console.error("updateTier error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * DELETE /people/:sub
 * Remove connection between me and target user.
 */
exports.removeConnection = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    const targetSub = req.params.sub;

    if (!mySub) return res.status(401).json({ message: "Missing user sub" });
    if (!targetSub) return res.status(400).json({ message: "Missing target sub" });

    const [me, target] = await Promise.all([
      UserProfile.findOne({ sub: mySub }, { _id: 1 }).lean(),
      UserProfile.findOne({ sub: targetSub }, { _id: 1 }).lean(),
    ]);

    if (!me || !target) {
      return res.status(404).json({ message: "UserProfile not found" });
    }

    const a = String(me._id) < String(target._id) ? me._id : target._id;
    const b = a === me._id ? target._id : me._id;

    const result = await Connection.deleteOne({ userA: a, userB: b });

    return res.status(200).json({
      message: "Connection removed",
      deletedCount: result.deletedCount || 0,
    });
  } catch (err) {
    console.error("removeConnection error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};
