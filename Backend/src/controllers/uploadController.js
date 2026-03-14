// backend/src/controllers/uploadController.js
const crypto = require("crypto");
const { PutObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const { s3 } = require("../config/s3");

const BUCKET = process.env.S3_BUCKET;

function extFromMime(mime) {
  if (!mime) return "bin";
  if (mime === "image/png") return "png";
  if (mime === "image/webp") return "webp";
  if (mime === "image/jpeg" || mime === "image/jpg") return "jpg";
  if (mime === "audio/m4a") return "m4a";
  if (mime === "audio/mp4") return "m4a";
  if (mime === "audio/aac") return "aac";
  if (mime === "audio/mpeg") return "mp3";
  return "bin";
}

// POST /uploads/presign
// body: { contentType: "image/jpeg", kind: "journalImage" | "journalAudio" }
exports.presignUpload = async (req, res) => {
  try {
    const sub = req.user.sub;

    if (!BUCKET) {
      return res.status(500).json({ message: "S3_BUCKET missing in env" });
    }

    const contentType = (req.body?.contentType || "").trim();
    const kind = (req.body?.kind || "journalImage").trim();

    if (!contentType) {
      return res.status(400).json({ message: "Missing contentType" });
    }

    const ext = extFromMime(contentType);
    const rand = crypto.randomBytes(8).toString("hex");

    // Keep uploads organized by user and feature
    const base = `users/${sub}/journal`;
    const ts = Date.now();

    const key =
      kind === "journalAudio"
        ? `${base}/audio/voice-${ts}-${rand}.${ext}`
        : `${base}/images/img-${ts}-${rand}.${ext}`;

    const command = new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      ContentType: contentType,
    });

    const uploadUrl = await getSignedUrl(s3, command, { expiresIn: 600 });

    return res.status(200).json({
      uploadUrl,
      key,
      bucket: BUCKET,
    });
  } catch (err) {
    console.error("presignUpload error:", err);
    return res.status(500).json({ message: "Failed to create upload url" });
  }
};
