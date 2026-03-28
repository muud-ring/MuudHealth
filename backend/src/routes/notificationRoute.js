// backend/src/routes/notificationRoute.js
const { Router } = require("express");
const requireAuth = require("../middleware/requireAuth");
const validate = require("../middleware/validate");
const { body } = require("express-validator");
const ctrl = require("../controllers/notificationController");

const router = Router();

const registerValidation = [
  body("token").trim().notEmpty().withMessage("token is required"),
  body("platform")
    .optional()
    .isIn(["ios", "android", "web", "unknown"])
    .withMessage("platform must be ios, android, web, or unknown"),
];

const unregisterValidation = [
  body("token").trim().notEmpty().withMessage("token is required"),
];

router.post(
  "/register-device",
  requireAuth,
  registerValidation,
  validate,
  ctrl.registerDevice
);

router.delete(
  "/unregister-device",
  requireAuth,
  unregisterValidation,
  validate,
  ctrl.unregisterDevice
);

module.exports = router;
