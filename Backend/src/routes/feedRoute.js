// backend/src/routes/feedRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const feedCtrl = require("../controllers/feedController");

router.get("/home", requireAuth, feedCtrl.getHomeFeed);

module.exports = router;
