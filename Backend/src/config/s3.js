// backend/src/config/s3.js
const { S3Client } = require("@aws-sdk/client-s3");

const region = process.env.AWS_REGION || "us-west-2";

if (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY) {
  console.warn("⚠️ Missing AWS keys in env (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY)");
}

const s3 = new S3Client({
  region,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || "",
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || "",
  },
});

module.exports = { s3, region };