// backend/src/routes/vaultRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const vaultCtrl = require("../controllers/vaultController");

// landing sections
router.get("/landing", requireAuth, vaultCtrl.landing);

// list items (category, cursor pagination)
router.get("/items", requireAuth, vaultCtrl.items);

// save/unsave
router.post("/save", requireAuth, vaultCtrl.save);
router.delete("/save", requireAuth, vaultCtrl.unsave);

module.exports = router;