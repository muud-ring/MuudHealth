const mongoose = require("mongoose");

const ConversationSchema = new mongoose.Schema(
  {
    members: { type: [String], required: true, index: true }, // subs
    membersKey: { type: String, required: true, unique: true, index: true }, // sorted "subA|subB"
    lastMessage: { type: String, default: "" },
    lastMessageAt: { type: Date, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Conversation", ConversationSchema);
