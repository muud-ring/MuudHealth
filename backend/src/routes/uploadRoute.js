// backend/src/routes/uploadRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const validate = require("../middleware/validate");
const rules = require("../validators/uploadValidators");
const uploadCtrl = require("../controllers/uploadController");

router.post("/presign", requireAuth, rules.presignUpload, validate, uploadCtrl.presignUpload);

module.exports = router;
