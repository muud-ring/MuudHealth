const express = require("express");
const router = express.Router();
const requireAuth = require("../middleware/requireAuth");
const chat = require("../controllers/chatController");

router.get("/inbox", requireAuth, chat.getInbox);
router.post("/conversation/:otherSub", requireAuth, chat.getOrCreateConversation);
router.get("/messages/:conversationId", requireAuth, chat.getMessages);
router.post("/messages/:conversationId", requireAuth, chat.sendMessage);

module.exports = router;
