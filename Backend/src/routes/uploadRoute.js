// backend/src/routes/uploadRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const uploadCtrl = require("../controllers/uploadController");

router.post("/presign", requireAuth, uploadCtrl.presignUpload);

module.exports = router;
