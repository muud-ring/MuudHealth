// backend/src/routes/userRoute.js
const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const validate = require("../middleware/validate");
const userRules = require("../validators/userValidators");
const uploadRules = require("../validators/uploadValidators");
const userCtrl = require("../controllers/userController");
const photoCtrl = require("../controllers/userPhotoController");

// 1) Returns Cognito identity/claims from access token
router.get("/claims", requireAuth, (req, res) => {
  const claims = req.user?.claims || {};
  return res.status(200).json({
    sub: claims.sub,
    email: claims.email,
    phone_number: claims.phone_number,
    username: claims.username,
    name: claims.name,
    birthdate: claims.birthdate,
    token_use: claims.token_use,
  });
});

// 2) Profile (stored in DocumentDB)
router.get("/me", requireAuth, userCtrl.getMe);
router.put("/me", requireAuth, userRules.upsertMe, validate, userCtrl.upsertMe);

// 3) Avatar upload (PRIVATE S3 presigned flow)
router.post("/avatar/presign", requireAuth, uploadRules.presignAvatarUpload, validate, photoCtrl.presignAvatarUpload);
router.post("/avatar/confirm", requireAuth, uploadRules.confirmAvatarUpload, validate, photoCtrl.confirmAvatarUpload);

router.get("/avatar/url", requireAuth, photoCtrl.getAvatarUrl);

module.exports = router;
