const mongoose = require("mongoose");

const postSchema = new mongoose.Schema({
  // title: {
  //   type: String,
  //   required: [true, "title is required"],
  // },
  description: { type: String, required: [true, "title is required"] },
  comments: [
    {
      commentName: { type: String, default: "" },
      commentUserId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
      activityId: [{ type: String, default: [] }],
      timestamps: { type: Date, default: Date() },
      replyComments: [
        {
          replyToUserId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
          commentName: { type: String, default: "" },
          commentUserId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
          },
          timestamps: { type: Date, default: Date() },
        },
      ],
    },
  ],
  name: String,
  creator: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: "User",
    index: true,
  },
  // tags: [{ type: String }],
  fileType: { type: String, enum: ["image", "video"] },
  file: { type: Map, default: {}, of: String },
  likes: [
    {
      userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
      reactionType: {
        type: String,
        enum: ["Like", "Haha", "Sad", "Love", "Angry", "Shy", "Wow"],
        default: "like",
      },
      timestamps: { type: Date, default: Date() },
    },
  ],
  createdAt: {
    type: Date,
    default: Date(),
  },
});

const PostModel = mongoose.model("PostModel", postSchema);

module.exports = PostModel;
