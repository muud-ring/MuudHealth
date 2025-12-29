const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const chatController = require("../controllers/chatController");

// ✅ Inbox list (UI-ready)
router.get("/conversations", requireAuth, chatController.getConversations);

// ✅ Optional: raw Conversation docs (if you still want it)
router.get("/inbox", requireAuth, chatController.getInbox);

// ✅ Chat thread
router.post(
  "/conversation/:otherSub",
  requireAuth,
  chatController.getOrCreateConversation
);

router.get(
  "/messages/:conversationId",
  requireAuth,
  chatController.getMessages
);

router.post(
  "/messages/:conversationId",
  requireAuth,
  chatController.sendMessage
);

module.exports = router;
