// backend/src/routes/postRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const postCtrl = require("../controllers/postController");

router.post("/", requireAuth, postCtrl.createPost);

// ✅ add edit
router.put("/:id", requireAuth, postCtrl.updatePost);

module.exports = router;
