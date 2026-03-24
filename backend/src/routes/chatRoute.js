const express = require("express");
const router = express.Router();

const requireAuth = require("../middleware/requireAuth");
const validate = require("../middleware/validate");
const rules = require("../validators/chatValidators");
const chatController = require("../controllers/chatController");

router.get("/unread-count", requireAuth, chatController.getUnreadCount);
router.get("/conversations", requireAuth, chatController.getConversations);
router.get("/inbox", requireAuth, chatController.getInbox);

router.post(
  "/conversation/:otherSub",
  requireAuth,
  rules.getOrCreateConversation,
  validate,
  chatController.getOrCreateConversation
);

router.get(
  "/messages/:conversationId",
  requireAuth,
  rules.getMessages,
  validate,
  chatController.getMessages
);

router.post(
  "/messages/:conversationId",
  requireAuth,
  rules.sendMessage,
  validate,
  chatController.sendMessage
);

module.exports = router;
