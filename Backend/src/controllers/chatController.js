const Conversation = require("../models/Conversation");
const Message = require("../models/Message");

function keyFor(subA, subB) {
  return [subA, subB].sort().join("|");
}

// POST /chat/conversation/:otherSub
exports.getOrCreateConversation = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    const otherSub = req.params.otherSub;
    if (!mySub || !otherSub) return res.status(400).json({ message: "Invalid" });
    if (mySub === otherSub) return res.status(400).json({ message: "Invalid" });

    const membersKey = keyFor(mySub, otherSub);

    const convo = await Conversation.findOneAndUpdate(
      { membersKey },
      { $setOnInsert: { members: [mySub, otherSub], membersKey } },
      { new: true, upsert: true }
    ).lean();

    return res.status(200).json({ conversation: convo });
  } catch (err) {
    console.error("getOrCreateConversation error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// GET /chat/messages/:conversationId
exports.getMessages = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    const { conversationId } = req.params;

    const convo = await Conversation.findById(conversationId).lean();
    if (!convo) return res.status(404).json({ message: "Not found" });
    if (!convo.members.includes(mySub)) return res.status(403).json({ message: "Forbidden" });

    const messages = await Message.find({ conversationId })
      .sort({ createdAt: 1 })
      .limit(300)
      .lean();

    return res.status(200).json({ messages });
  } catch (err) {
    console.error("getMessages error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// POST /chat/messages/:conversationId
exports.sendMessage = async (req, res) => {
  try {
    const mySub = req.user?.sub;
    const { conversationId } = req.params;
    const text = (req.body?.text || "").trim();

    if (!text) return res.status(400).json({ message: "Empty text" });

    const convo = await Conversation.findById(conversationId).lean();
    if (!convo) return res.status(404).json({ message: "Not found" });
    if (!convo.members.includes(mySub)) return res.status(403).json({ message: "Forbidden" });

    const toSub = convo.members.find((s) => s !== mySub);

    const msg = await Message.create({
      conversationId,
      fromSub: mySub,
      toSub,
      text,
    });

    const io = req.app.get("io");
if (io) {
  io.to(`conv:${conversationId}`).emit("newMessage", {
    _id: msg._id,
    conversationId,
    fromSub: msg.fromSub,
    toSub: msg.toSub,
    text: msg.text,
    createdAt: msg.createdAt,
  });

  io.to(`user:${toSub}`).emit("inboxUpdate", { conversationId });
}


    await Conversation.updateOne(
      { _id: conversationId },
      { $set: { lastMessage: text, lastMessageAt: new Date() } }
    );

    // Socket emit is handled in socket layer (we’ll call io there)
    return res.status(201).json({ message: msg });
  } catch (err) {
    console.error("sendMessage error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// GET /chat/inbox
exports.getInbox = async (req, res) => {
  try {
    const mySub = req.user?.sub;

    const convos = await Conversation.find({ members: mySub })
      .sort({ lastMessageAt: -1, updatedAt: -1 })
      .limit(50)
      .lean();

    return res.status(200).json({ conversations: convos });
  } catch (err) {
    console.error("getInbox error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};
