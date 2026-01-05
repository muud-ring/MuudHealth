// backend/src/controllers/postReadController.js
const Post = require("../models/Post");
const { GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const { s3 } = require("../config/s3");

const BUCKET = process.env.S3_BUCKET;

async function signKey(key, expiresIn = 600) {
  if (!BUCKET || !key) return null;
  const cmd = new GetObjectCommand({ Bucket: BUCKET, Key: key });
  return await getSignedUrl(s3, cmd, { expiresIn });
}

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
    console.error("getMyPosts error:", err);
    return res.status(500).json({ message: "Failed to fetch posts" });
  }
};
