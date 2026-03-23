// backend/src/routes/postReadRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const readCtrl = require("../controllers/postReadController");

router.get("/mine", requireAuth, readCtrl.getMyPosts);

module.exports = router;