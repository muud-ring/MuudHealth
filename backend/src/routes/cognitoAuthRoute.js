const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/cognitoAuthController");
const validate = require("../middleware/validate");
const rules = require("../validators/authValidators");
const { authLimiter } = require("../middleware/rateLimiter");

router.use(authLimiter);

router.post("/signup", rules.signup, validate, ctrl.signup);
router.post("/confirm-signup", rules.confirmSignup, validate, ctrl.confirmSignup);
router.post("/login", rules.login, validate, ctrl.login);
router.post("/forgot-password", rules.forgotPassword, validate, ctrl.forgotPassword);
router.post("/confirm-forgot-password", rules.confirmForgotPassword, validate, ctrl.confirmForgotPassword);
router.post("/refresh", rules.refreshToken, validate, ctrl.refreshToken);

module.exports = router;
