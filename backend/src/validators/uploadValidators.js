const { body } = require("express-validator");

const CONTENT_TYPES = [
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/gif",
  "audio/mpeg",
  "audio/wav",
  "audio/aac",
  "audio/m4a",
];

const presignUpload = [
  body("contentType")
    .trim()
    .notEmpty()
    .withMessage("contentType is required")
    .isIn(CONTENT_TYPES)
    .withMessage(`contentType must be one of: ${CONTENT_TYPES.join(", ")}`),
  body("kind")
    .optional()
    .isIn(["journalImage", "journalAudio"])
    .withMessage("kind must be 'journalImage' or 'journalAudio'"),
];

const presignAvatarUpload = [
  body("contentType")
    .optional()
    .isIn(["image/jpeg", "image/png", "image/webp"])
    .withMessage("contentType must be image/jpeg, image/png, or image/webp"),
];

const confirmAvatarUpload = [
  body("key").trim().notEmpty().withMessage("key is required"),
];

module.exports = { presignUpload, presignAvatarUpload, confirmAvatarUpload };
