// backend/src/routes/postRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const validate = require("../middleware/validate");
const rules = require("../validators/postValidators");
const postCtrl = require("../controllers/postController");

// create
router.post("/", requireAuth, rules.createPost, validate, postCtrl.createPost);

// update (owner-only)
router.put("/:id", requireAuth, rules.updatePost, validate, postCtrl.updatePost);

// delete (owner-only)
router.delete("/:id", requireAuth, rules.deletePost, validate, postCtrl.deletePost);

module.exports = router;
