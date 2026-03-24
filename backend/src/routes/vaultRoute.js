// backend/src/routes/vaultRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const validate = require("../middleware/validate");
const rules = require("../validators/vaultValidators");
const vaultCtrl = require("../controllers/vaultController");

// landing sections
router.get("/landing", requireAuth, vaultCtrl.landing);

// list items (category, cursor pagination)
router.get("/items", requireAuth, rules.items, validate, vaultCtrl.items);

// save/unsave
router.post("/save", requireAuth, rules.save, validate, vaultCtrl.save);
router.delete("/save", requireAuth, rules.unsave, validate, vaultCtrl.unsave);

module.exports = router;
