const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const ctrl = require("../controllers/onboardingController");

router.get("/me", requireAuth, ctrl.getMe);
router.get("/status", requireAuth, ctrl.getStatus);
router.post("/", requireAuth, ctrl.upsert);

module.exports = router;
