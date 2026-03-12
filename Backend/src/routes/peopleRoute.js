// backend/src/routes/peopleRoute.js

const express = require("express");
const requireAuth = require("../middleware/requireAuth");
const peopleController = require("../controllers/peopleController");

const router = express.Router();

// Protect all people routes
router.use(requireAuth);

// Lists
router.get("/suggestions", peopleController.getSuggestions);
router.get("/connections", peopleController.getConnections);
router.get("/inner-circle", peopleController.getInnerCircle);
router.get("/me", peopleController.getMe);

// Requests
router.get("/requests", peopleController.getRequests);

router.post("/request/:sub", peopleController.sendRequest);
router.post("/request/:requestId/accept", peopleController.acceptRequest);

router.post("/request/:requestId/decline", peopleController.declineRequest);
router.delete("/:sub", peopleController.removeConnection);

// Tier
router.post("/:sub/tier", peopleController.updateTier);

module.exports = router;
