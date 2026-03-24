// backend/src/routes/peopleRoute.js

const express = require("express");
const requireAuth = require("../middleware/requireAuth");
const validate = require("../middleware/validate");
const rules = require("../validators/peopleValidators");
const peopleController = require("../controllers/peopleController");

const router = express.Router();

// Protect all people routes
router.use(requireAuth);

// Lists
router.get("/suggestions", rules.getSuggestions, validate, peopleController.getSuggestions);
router.get("/connections", peopleController.getConnections);
router.get("/inner-circle", peopleController.getInnerCircle);
router.get("/me", peopleController.getMe);

// Requests
router.get("/requests", peopleController.getRequests);

router.post("/request/:sub", rules.sendRequest, validate, peopleController.sendRequest);
router.post("/request/:requestId/accept", rules.acceptRequest, validate, peopleController.acceptRequest);

router.post("/request/:requestId/decline", rules.declineRequest, validate, peopleController.declineRequest);
router.delete("/:sub", rules.removeConnection, validate, peopleController.removeConnection);

// Tier
router.post("/:sub/tier", rules.updateTier, validate, peopleController.updateTier);

module.exports = router;
