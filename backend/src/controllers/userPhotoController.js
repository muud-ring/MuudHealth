// backend/src/controllers/userPhotoController.js
const crypto = require("crypto");
const { PutObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const { s3 } = require("../config/s3");
const UserProfile = require("../models/UserProfile");

const BUCKET = process.env.S3_BUCKET;

function extFromMime(mime) {
  if (!mime) return "jpg";
  if (mime === "image/png") return "png";
  if (mime === "image/webp") return "webp";
  if (mime === "image/jpeg" || mime === "image/jpg") return "jpg";
  return "jpg";
}

// POST /user/avatar/presign
// body: { contentType: "image/jpeg" }
exports.presignAvatarUpload = async (req, res) => {
  try {
    const sub = req.user.sub;

    if (!BUCKET) {
      return res.status(500).json({ message: "S3_BUCKET missing in env" });
    }

    const contentType = req.body?.contentType || "image/jpeg";
    const ext = extFromMime(contentType);

    // unique filename to avoid caching problems
    const rand = crypto.randomBytes(8).toString("hex");
    const key = `users/${sub}/profile/avatar-${Date.now()}-${rand}.${ext}`;

    const command = new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      ContentType: contentType,
      // private by default (bucket is private + ACLs disabled)
    });

    const uploadUrl = await getSignedUrl(s3, command, { expiresIn: 600 });

    return res.status(200).json({
      uploadUrl,
      key,
      bucket: BUCKET,
    });
  } catch (err) {
    console.error("presignAvatarUpload error:", err);
    return res.status(500).json({ message: "Failed to create upload url" });
  }
};

// POST /user/avatar/confirm
// body: { key: "users/<sub>/profile/..." }
exports.confirmAvatarUpload = async (req, res) => {
  try {
    const sub = req.user.sub;
    const key = (req.body?.key || "").trim();

    if (!key) return res.status(400).json({ message: "Missing key" });

    // safety: user can only set their own folder
    const prefix = `users/${sub}/`;
    if (!key.startsWith(prefix)) {
      return res.status(403).json({ message: "Invalid key for this user" });
    }

    const profile = await UserProfile.findOneAndUpdate(
      { sub },
      { $set: { sub, avatarKey: key } },
      { new: true, upsert: true }
    ).lean();

    return res.status(200).json({ message: "Avatar saved", profile });
  } catch (err) {
    console.error("confirmAvatarUpload error:", err);
    return res.status(500).json({ message: "Failed to save avatar" });
  }
};

const { GetObjectCommand } = require("@aws-sdk/client-s3");

// GET /user/avatar/url  -> { url: "https://..." } or { url: null }
exports.getAvatarUrl = async (req, res) => {
  try {
    const sub = req.user.sub;

    const profile = await UserProfile.findOne({ sub }).select("avatarKey").lean();
    const key = profile?.avatarKey || "";

    if (!key) {
      return res.status(200).json({ url: null });
    }

    const cmd = new GetObjectCommand({
      Bucket: BUCKET,
      Key: key,
    });

    // short-lived view url (10 mins)
    const url = await getSignedUrl(s3, cmd, { expiresIn: 600 });

    return res.status(200).json({ url });
  } catch (err) {
    console.error("getAvatarUrl error:", err);
    return res.status(500).json({ message: "Failed to generate avatar url" });
  }
};