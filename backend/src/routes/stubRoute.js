// backend/src/routes/stubRoute.js
// Stub responses for portal routes not yet backed by real data
// Returns empty arrays / null objects so the portal renders without errors
const express = require("express");
const requireAuth = require("../middleware/requireAuth");
const router = express.Router();

router.get("/", requireAuth, (_req, res) => res.json({ data: [], meta: { stub: true } }));
module.exports = router;
