const { body } = require("express-validator");

const signup = [
  body("identifier")
    .trim()
    .notEmpty()
    .withMessage("identifier is required (email or phone)"),
  body("password")
    .isLength({ min: 8 })
    .withMessage("password must be at least 8 characters"),
  body("fullName").trim().notEmpty().withMessage("fullName is required"),
  body("username")
    .trim()
    .isLength({ min: 2, max: 30 })
    .withMessage("username must be 2–30 characters"),
  body("birthdate")
    .trim()
    .notEmpty()
    .withMessage("birthdate is required")
    .isISO8601()
    .withMessage("birthdate must be a valid date"),
];

const confirmSignup = [
  body("identifier").trim().notEmpty().withMessage("identifier is required"),
  body("code")
    .trim()
    .notEmpty()
    .withMessage("code is required")
    .isLength({ min: 4, max: 10 })
    .withMessage("code must be 4–10 characters"),
];

const login = [
  body("identifier").trim().notEmpty().withMessage("identifier is required"),
  body("password").notEmpty().withMessage("password is required"),
];

const forgotPassword = [
  body("identifier").trim().notEmpty().withMessage("identifier is required"),
];

const confirmForgotPassword = [
  body("identifier").trim().notEmpty().withMessage("identifier is required"),
  body("code").trim().notEmpty().withMessage("code is required"),
  body("newPassword")
    .isLength({ min: 8 })
    .withMessage("newPassword must be at least 8 characters"),
];

const refreshToken = [
  body("refreshToken").notEmpty().withMessage("refreshToken is required"),
];

module.exports = {
  signup,
  confirmSignup,
  login,
  forgotPassword,
  confirmForgotPassword,
  refreshToken,
};
