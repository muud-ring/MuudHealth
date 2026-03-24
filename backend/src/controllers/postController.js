// backend/src/controllers/postController.js
const Post = require("../models/Post");
const logger = require("../utils/logger");

function normalizeVisibility(v) {
  const s = (v || "").toString().toLowerCase().trim();
  if (s === "inner circle" || s === "innercircle" || s === "inner_circle") return "innerCircle";
  if (s === "connections") return "connections";
  return "public";
}

// POST /posts
// body: { caption, mediaKeys: [], audioKey, visibility, recipientSubs: [] }
exports.createPost = async (req, res) => {
  try {
    const sub = req.user.sub;

    const caption = (req.body?.caption || "").toString();
    const mediaKeys = Array.isArray(req.body?.mediaKeys) ? req.body.mediaKeys : [];
    const audioKey = (req.body?.audioKey || "").toString();
    const visibility = normalizeVisibility(req.body?.visibility);
    const recipientSubs = Array.isArray(req.body?.recipientSubs) ? req.body.recipientSubs : [];

    if (!mediaKeys.length) {
      return res.status(400).json({ message: "mediaKeys required" });
    }

    if (visibility !== "public" && recipientSubs.length === 0) {
      return res.status(400).json({ message: "recipientSubs required for non-public posts" });
    }

    const post = await Post.create({
      authorSub: sub,
      caption,
      mediaKeys,
      audioKey,
      visibility,
      recipientSubs,
    });

    return res.status(201).json({ post });
  } catch (err) {
    logger.error({ err }, "createPost error");
    return res.status(500).json({ message: "Failed to create post" });
  }
};

// PUT /posts/:id  (owner-only)
// body: { caption, visibility, recipientSubs }
exports.updatePost = async (req, res) => {
  try {
    const sub = req.user.sub;
    const id = req.params.id;

    const post = await Post.findById(id);
    if (!post) return res.status(404).json({ message: "Post not found" });

    // ✅ only owner can edit
    if (post.authorSub !== sub) {
      return res.status(403).json({ message: "Not allowed" });
    }

    const caption = (req.body?.caption ?? post.caption ?? "").toString();
    const visibility = normalizeVisibility(req.body?.visibility ?? post.visibility);

    const recipientSubs = Array.isArray(req.body?.recipientSubs)
      ? req.body.recipientSubs
      : (post.recipientSubs || []);

    // enforce: non-public must have recipients
    if (visibility !== "public" && recipientSubs.length === 0) {
      return res.status(400).json({ message: "recipientSubs required for non-public posts" });
    }

    post.caption = caption;
    post.visibility = visibility;
    post.recipientSubs = recipientSubs;

    await post.save();

    return res.status(200).json({ post });
  } catch (err) {
    logger.error({ err }, "updatePost error");
    return res.status(500).json({ message: "Failed to update post" });
  }
};

// DELETE /posts/:id (owner-only)
exports.deletePost = async (req, res) => {
  try {
    const sub = req.user.sub;
    const id = req.params.id;

    const post = await Post.findById(id);
    if (!post) return res.status(404).json({ message: "Post not found" });

    if (post.authorSub !== sub) {
      return res.status(403).json({ message: "Not allowed" });
    }

    await Post.deleteOne({ _id: id });

    // NOTE: Later we can also delete from S3 (mediaKeys/audioKey) safely.
    return res.status(200).json({ ok: true });
  } catch (err) {
    logger.error({ err }, "deletePost error");
    return res.status(500).json({ message: "Failed to delete post" });
  }
};
