// backend/src/models/Post.js
const mongoose = require("mongoose");

const PostSchema = new mongoose.Schema(
  {
    authorSub: { type: String, required: true, index: true },

    caption: { type: String, default: "" },

    mediaKeys: { type: [String], default: [] }, // images
    audioKey: { type: String, default: "" },

    visibility: {
      type: String,
      enum: ["public", "connections", "innerCircle"],
      default: "public",
      index: true,
    },

    recipientSubs: { type: [String], default: [] }, // for non-public

    // future
    locationText: { type: String, default: "" },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Post", PostSchema);
