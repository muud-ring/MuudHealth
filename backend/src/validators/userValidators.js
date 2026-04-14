const { body } = require("express-validator");

const upsertMe = [
  body("name")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("name must be at most 100 characters"),
  body("username")
    .optional()
    .trim()
    .isLength({ min: 2, max: 30 })
    .withMessage("username must be 2–30 characters"),
  body("bio")
    .optional()
    .isString()
    .isLength({ max: 500 })
    .withMessage("bio must be at most 500 characters"),
  body("location")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("location must be at most 100 characters"),
  body("phone")
    .optional()
    .trim()
    .isString()
    .withMessage("phone must be a string"),
];

module.exports = { upsertMe };
