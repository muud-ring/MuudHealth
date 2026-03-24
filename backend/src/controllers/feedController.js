// backend/src/controllers/feedController.js
const Post = require("../models/Post");
const logger = require("../utils/logger");
const Connection = require("../models/Connection");
const UserProfile = require("../models/UserProfile");

const { GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const { s3 } = require("../config/s3");

const BUCKET = process.env.S3_BUCKET;

async function signKey(key, expiresIn = 600) {
  if (!BUCKET || !key) return null;
  const cmd = new GetObjectCommand({ Bucket: BUCKET, Key: key });
  return await getSignedUrl(s3, cmd, { expiresIn });
}

exports.getHomeFeed = async (req, res) => {
  try {
    const viewerSub = req.user.sub;

    // 1) Find viewer profile (_id needed for Connection model)
    const viewerProfile = await UserProfile.findOne({ sub: viewerSub })
      .select("_id sub")
      .lean();

    if (!viewerProfile?._id) {
      return res.status(200).json({ posts: [] });
    }

    const viewerId = viewerProfile._id;

    // 2) Get all connections where viewer is userA or userB
    const connections = await Connection.find({
      $or: [{ userA: viewerId }, { userB: viewerId }],
    })
      .select("userA userB tier")
      .lean();

    // 3) Get the "other side" user ids grouped by tier
    const connectionUserIds = [];
    const innerCircleUserIds = [];

    for (const c of connections) {
      const otherId = String(c.userA) === String(viewerId) ? c.userB : c.userA;
      if (!otherId) continue;

      if (c.tier === "inner_circle") innerCircleUserIds.push(otherId);
      else connectionUserIds.push(otherId);
    }

    // 4) Convert those UserProfile _ids -> subs
    const allOtherIds = [...new Set([...connectionUserIds, ...innerCircleUserIds])];

    const otherProfiles = allOtherIds.length
      ? await UserProfile.find({ _id: { $in: allOtherIds } })
          .select("sub")
          .lean()
      : [];

    const idToSub = new Map(otherProfiles.map((p) => [String(p._id), p.sub]));

    const connectionSubs = connectionUserIds
      .map((id) => idToSub.get(String(id)))
      .filter(Boolean);

    const innerCircleSubs = innerCircleUserIds
      .map((id) => idToSub.get(String(id)))
      .filter(Boolean);

    // 5) Build visibility query
    // Rules:
    // - always show my posts
    // - public visible to all
    // - connections visible if author is in my connectionSubs OR innerCircleSubs (inner circle are also connections)
    // - inner_circle visible if author is in my innerCircleSubs
    // - direct shares visible if my sub is in recipientSubs (independent)
    const query = {
      $or: [
        { authorSub: viewerSub },
        { visibility: "public" },
        {
          $and: [
            { visibility: "connections" },
            { authorSub: { $in: [...new Set([...connectionSubs, ...innerCircleSubs])] } },
          ],
        },
        {
          $and: [
            { visibility: "innerCircle" },
            { authorSub: { $in: innerCircleSubs } },
          ],
        },
        { recipientSubs: viewerSub },
      ],
    };

    const posts = await Post.find(query)
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();

    // 6) Add signed URLs
    const out = await Promise.all(
      posts.map(async (p) => {
        const firstImageKey = (p.mediaKeys && p.mediaKeys[0]) || "";
        const imageUrl = firstImageKey ? await signKey(firstImageKey) : null;
        const audioUrl = p.audioKey ? await signKey(p.audioKey) : null;

        return {
          id: p._id,
          authorSub: p.authorSub,
          caption: p.caption || "",
          visibility: p.visibility || "public",
          createdAt: p.createdAt,
          imageUrl,
          audioUrl,
        };
      })
    );

    return res.status(200).json({ posts: out });
  } catch (err) {
    logger.error({ err }, "getHomeFeed error");
    return res.status(500).json({ message: "Failed to load feed" });
  }
};
