const { GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const { s3, S3_BUCKET } = require("../config/s3");

// Return empty string if no avatar or misconfigured S3
async function avatarUrlFromKey(key) {
  if (!key || typeof key !== "string") return "";
  if (!S3_BUCKET) return ""; // ✅ IMPORTANT GUARD

  try {
    const command = new GetObjectCommand({
      Bucket: S3_BUCKET,
      Key: key,
    });

    // 1 hour signed URL
    return await getSignedUrl(s3, command, { expiresIn: 3600 });
  } catch (err) {
    console.error("avatarUrlFromKey error:", err);
    return "";
  }
}

async function attachAvatarUrls(profiles) {
  if (!Array.isArray(profiles) || profiles.length === 0) return profiles;

  return Promise.all(
    profiles.map(async (p) => ({
      ...p,
      avatarUrl: await avatarUrlFromKey(p.avatarKey),
    }))
  );
}

module.exports = { avatarUrlFromKey, attachAvatarUrls };
