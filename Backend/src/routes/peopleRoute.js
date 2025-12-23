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

// Requests
router.get("/requests", peopleController.getRequests);
router.get("/requests/:sub", peopleController.getRequestsForSub); // TEMP (demo only)

router.post("/request/:sub", peopleController.sendRequest);
router.post("/request/:requestId/accept", peopleController.acceptRequest);

// Tier
router.post("/:sub/tier", peopleController.updateTier);

module.exports = router;
