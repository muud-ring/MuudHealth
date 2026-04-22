const { body, param } = require("express-validator");

const VISIBILITY_OPTIONS = ["public", "connections", "innerCircle"];

const createPost = [
  body("caption")
    .optional()
    .isString()
    .isLength({ max: 5000 })
    .withMessage("caption must be at most 5000 characters"),
  // "content" is accepted as an alias for "caption" (portal field-name variant)
  body("content")
    .optional()
    .isString()
    .isLength({ max: 5000 })
    .withMessage("content must be at most 5000 characters"),
  // "emotion" is accepted as an alias for "caption" (portal field-name variant)
  body("emotion")
    .optional()
    .isString()
    .isLength({ max: 5000 })
    .withMessage("emotion must be at most 5000 characters"),
  body("mediaKeys")
    .optional()
    .isArray()
    .withMessage("mediaKeys must be an array"),
  body("audioKey")
    .optional()
    .isString()
    .withMessage("audioKey must be a string"),
  body("visibility")
    .optional()
    .isIn(VISIBILITY_OPTIONS)
    .withMessage(`visibility must be one of: ${VISIBILITY_OPTIONS.join(", ")}`),
  // "privacyLevel" is accepted as an alias for "visibility" (portal field-name variant)
  body("privacyLevel")
    .optional()
    .isIn(VISIBILITY_OPTIONS)
    .withMessage(`privacyLevel must be one of: ${VISIBILITY_OPTIONS.join(", ")}`),
  body("recipientSubs")
    .optional()
    .isArray()
    .withMessage("recipientSubs must be an array"),
];

const updatePost = [
  param("id").isMongoId().withMessage("id must be a valid ID"),
  body("caption")
    .optional()
    .isString()
    .isLength({ max: 5000 })
    .withMessage("caption must be at most 5000 characters"),
  // "content" is accepted as an alias for "caption" (portal field-name variant)
  body("content")
    .optional()
    .isString()
    .isLength({ max: 5000 })
    .withMessage("content must be at most 5000 characters"),
  // "emotion" is accepted as an alias for "caption" (portal field-name variant)
  body("emotion")
    .optional()
    .isString()
    .isLength({ max: 5000 })
    .withMessage("emotion must be at most 5000 characters"),
  body("visibility")
    .optional()
    .isIn(VISIBILITY_OPTIONS)
    .withMessage(`visibility must be one of: ${VISIBILITY_OPTIONS.join(", ")}`),
  // "privacyLevel" is accepted as an alias for "visibility" (portal field-name variant)
  body("privacyLevel")
    .optional()
    .isIn(VISIBILITY_OPTIONS)
    .withMessage(`privacyLevel must be one of: ${VISIBILITY_OPTIONS.join(", ")}`),
  body("recipientSubs")
    .optional()
    .isArray()
    .withMessage("recipientSubs must be an array"),
];

const deletePost = [
  param("id").isMongoId().withMessage("id must be a valid ID"),
];

module.exports = { createPost, updatePost, deletePost };
