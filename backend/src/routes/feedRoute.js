const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const feedCtrl = require("../controllers/feedController");

// Old (keep for now)
router.get("/home", requireAuth, feedCtrl.getHomeFeed);

// New (Explore feed)
router.get("/explore", requireAuth, feedCtrl.getHomeFeed);

module.exports = router;