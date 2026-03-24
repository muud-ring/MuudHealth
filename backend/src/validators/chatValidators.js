const { body, param } = require("express-validator");

const getOrCreateConversation = [
  param("otherSub")
    .trim()
    .notEmpty()
    .withMessage("otherSub param is required"),
];

const getMessages = [
  param("conversationId")
    .trim()
    .notEmpty()
    .withMessage("conversationId param is required")
    .isMongoId()
    .withMessage("conversationId must be a valid ID"),
];

const sendMessage = [
  param("conversationId")
    .trim()
    .notEmpty()
    .withMessage("conversationId param is required")
    .isMongoId()
    .withMessage("conversationId must be a valid ID"),
  body("text")
    .trim()
    .notEmpty()
    .withMessage("text is required")
    .isLength({ max: 5000 })
    .withMessage("text must be at most 5000 characters"),
];

module.exports = {
  getOrCreateConversation,
  getMessages,
  sendMessage,
};
