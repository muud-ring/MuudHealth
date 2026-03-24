const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const validate = require("../middleware/validate");
const rules = require("../validators/onboardingValidators");
const ctrl = require("../controllers/onboardingController");

router.get("/me", requireAuth, ctrl.getMe);
router.get("/status", requireAuth, ctrl.getStatus);
router.post("/", requireAuth, rules.upsert, validate, ctrl.upsert);

module.exports = router;
