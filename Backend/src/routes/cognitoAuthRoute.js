const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/cognitoAuthController");

router.post("/signup", ctrl.signup);
router.post("/confirm-signup", ctrl.confirmSignup);
router.post("/login", ctrl.login);
router.post("/forgot-password", ctrl.forgotPassword);
router.post("/confirm-forgot-password", ctrl.confirmForgotPassword);

module.exports = router;
