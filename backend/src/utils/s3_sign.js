// backend/src/utils/s3_sign.js
//
// Shared S3 presigned-URL helper.  Replaces the identical signKey()
// function that was duplicated in feedController, postReadController,
// and vaultController.

const { GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const { s3, S3_BUCKET } = require("../config/s3");

/**
 * Generate a short-lived presigned GET URL for an S3 object key.
 * Returns null if bucket is not configured or key is falsy.
 *
 * @param {string} key       - S3 object key
 * @param {number} expiresIn - TTL in seconds (default 600 = 10 min)
 * @returns {Promise<string|null>}
 */
async function signKey(key, expiresIn = 600) {
  if (!S3_BUCKET || !key) return null;
  const cmd = new GetObjectCommand({ Bucket: S3_BUCKET, Key: key });
  return getSignedUrl(s3, cmd, { expiresIn });
}

module.exports = { signKey };
