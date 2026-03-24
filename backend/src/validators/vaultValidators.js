const { body, query } = require("express-validator");

const CATEGORIES = [
  "family",
  "friends",
  "events",
  "holidays",
  "work",
  "school",
  "other",
];

const save = [
  body("sourceType")
    .trim()
    .notEmpty()
    .withMessage("sourceType is required")
    .isIn(["post"])
    .withMessage("sourceType must be 'post'"),
  body("sourceId")
    .trim()
    .notEmpty()
    .withMessage("sourceId is required")
    .isMongoId()
    .withMessage("sourceId must be a valid ID"),
  body("category")
    .trim()
    .notEmpty()
    .withMessage("category is required")
    .isIn(CATEGORIES)
    .withMessage(`category must be one of: ${CATEGORIES.join(", ")}`),
  body("experienceType")
    .optional()
    .isString()
    .withMessage("experienceType must be a string"),
  body("tags")
    .optional()
    .isArray()
    .withMessage("tags must be an array"),
];

const unsave = [
  query("sourceId")
    .trim()
    .notEmpty()
    .withMessage("sourceId query param is required"),
];

const items = [
  query("category")
    .optional()
    .isIn(CATEGORIES)
    .withMessage(`category must be one of: ${CATEGORIES.join(", ")}`),
  query("limit")
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage("limit must be 1–100"),
  query("cursor")
    .optional()
    .isISO8601()
    .withMessage("cursor must be a valid ISO 8601 date"),
  query("from")
    .optional()
    .isISO8601()
    .withMessage("from must be a valid ISO 8601 date"),
  query("to")
    .optional()
    .isISO8601()
    .withMessage("to must be a valid ISO 8601 date"),
];

module.exports = { save, unsave, items };
