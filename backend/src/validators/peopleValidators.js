const { param, body, query } = require("express-validator");

const TIERS = ["connection", "inner_circle"];

const sendRequest = [
  param("sub").trim().notEmpty().withMessage("sub param is required"),
];

const acceptRequest = [
  param("requestId")
    .trim()
    .notEmpty()
    .withMessage("requestId is required")
    .isMongoId()
    .withMessage("requestId must be a valid ID"),
];

const declineRequest = [
  param("requestId")
    .trim()
    .notEmpty()
    .withMessage("requestId is required")
    .isMongoId()
    .withMessage("requestId must be a valid ID"),
];

const updateTier = [
  param("sub").trim().notEmpty().withMessage("sub param is required"),
  body("tier")
    .trim()
    .notEmpty()
    .withMessage("tier is required")
    .isIn(TIERS)
    .withMessage(`tier must be one of: ${TIERS.join(", ")}`),
];

const removeConnection = [
  param("sub").trim().notEmpty().withMessage("sub param is required"),
];

const getSuggestions = [
  query("q").optional().isString(),
  query("limit")
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage("limit must be 1–50"),
];

module.exports = {
  sendRequest,
  acceptRequest,
  declineRequest,
  updateTier,
  removeConnection,
  getSuggestions,
};
