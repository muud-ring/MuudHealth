const { body, param, query } = require("express-validator");

const VALID_TYPES = [
  "heart_rate",
  "hrv",
  "spo2",
  "temperature",
  "steps",
  "stress",
  "sleep",
];

const recordReading = [
  body("type")
    .trim()
    .notEmpty()
    .withMessage("type is required")
    .isIn(VALID_TYPES)
    .withMessage(`type must be one of: ${VALID_TYPES.join(", ")}`),
  body("value").isNumeric().withMessage("value must be a number"),
  body("unit").trim().notEmpty().withMessage("unit is required"),
  body("source")
    .optional()
    .trim()
    .isString()
    .withMessage("source must be a string"),
  body("metadata")
    .optional()
    .isObject()
    .withMessage("metadata must be an object"),
  body("recordedAt")
    .optional()
    .isISO8601()
    .withMessage("recordedAt must be a valid ISO 8601 date"),
];

const recordBatch = [
  body("readings")
    .isArray({ min: 1 })
    .withMessage("readings must be a non-empty array"),
  body("readings.*.type")
    .trim()
    .notEmpty()
    .withMessage("each reading must have a type")
    .isIn(VALID_TYPES)
    .withMessage(`type must be one of: ${VALID_TYPES.join(", ")}`),
  body("readings.*.value")
    .isNumeric()
    .withMessage("each reading must have a numeric value"),
  body("readings.*.unit")
    .trim()
    .notEmpty()
    .withMessage("each reading must have a unit"),
  body("readings.*.source")
    .optional()
    .trim()
    .isString(),
  body("readings.*.metadata")
    .optional()
    .isObject(),
  body("readings.*.recordedAt")
    .optional()
    .isISO8601()
    .withMessage("recordedAt must be a valid ISO 8601 date"),
];

const getHistory = [
  query("type")
    .optional()
    .trim()
    .isIn(VALID_TYPES)
    .withMessage(`type must be one of: ${VALID_TYPES.join(", ")}`),
  query("from")
    .optional()
    .isISO8601()
    .withMessage("from must be a valid ISO 8601 date"),
  query("to")
    .optional()
    .isISO8601()
    .withMessage("to must be a valid ISO 8601 date"),
  query("limit")
    .optional()
    .isInt({ min: 1, max: 1000 })
    .withMessage("limit must be 1–1000"),
];

const getDailySummary = [
  param("date")
    .trim()
    .notEmpty()
    .withMessage("date param is required")
    .matches(/^\d{4}-\d{2}-\d{2}/)
    .withMessage("date must be in YYYY-MM-DD format"),
];

const getSummaryRange = [
  query("from")
    .notEmpty()
    .withMessage("from query param is required")
    .isISO8601()
    .withMessage("from must be a valid date"),
  query("to")
    .notEmpty()
    .withMessage("to query param is required")
    .isISO8601()
    .withMessage("to must be a valid date"),
];

module.exports = {
  recordReading,
  recordBatch,
  getHistory,
  getDailySummary,
  getSummaryRange,
};
