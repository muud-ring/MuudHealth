// backend/src/controllers/postReadController.js
const Post = require("../models/Post");
const logger = require("../utils/logger");
const { signKey } = require("../utils/s3_sign");

// GET /posts/mine
exports.getMyPosts = async (req, res) => {
  try {
    const sub = req.user.sub;

    const posts = await Post.find({ authorSub: sub })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();

    const out = await Promise.all(
      posts.map(async (p) => {
        const firstImageKey = (p.mediaKeys && p.mediaKeys[0]) || "";
        const imageUrl = firstImageKey ? await signKey(firstImageKey) : null;
        const audioUrl = p.audioKey ? await signKey(p.audioKey) : null;

        return {
          id: p._id,
          caption: p.caption || "",
          imageUrl,
          audioUrl,
          visibility: p.visibility,
          createdAt: p.createdAt,
        };
      })
    );

    return res.status(200).json({ posts: out });
  } catch (err) {
    logger.error({ err }, "getMyPosts error");
    return res.status(500).json({ message: "Failed to fetch posts" });
  }
};
