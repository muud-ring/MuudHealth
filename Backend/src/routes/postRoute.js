// backend/src/routes/postRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const postCtrl = require("../controllers/postController");

// create
router.post("/", requireAuth, postCtrl.createPost);

// update (owner-only)
router.put("/:id", requireAuth, postCtrl.updatePost);

// delete (owner-only)
router.delete("/:id", requireAuth, postCtrl.deletePost);

module.exports = router;
