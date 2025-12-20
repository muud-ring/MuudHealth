const express = require("express");
const requireAuth = require("../middleware/requireAuth");

const router = express.Router();

// Returns Cognito identity from access token
router.get("/me", requireAuth, (req, res) => {
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

module.exports = router;
