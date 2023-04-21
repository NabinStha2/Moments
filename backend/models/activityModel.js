const mongoose = require("mongoose");

const activitySchema = mongoose.Schema({
  activityUserId: {
    type: mongoose.Types.ObjectId,
    ref: "User",
    required: true,
  },
  activity: [
    {
      postId: {
        type: mongoose.Types.ObjectId,
        ref: "PostModel",
      },
      userId: {
        type: mongoose.Types.ObjectId,
        ref: "User",
        required: true,
      },
      activityName: { type: String },
      activityId: { type: String },
      userImageUrl: { type: String },
      postUrl: { type: String },
      ownerId: { type: mongoose.Types.ObjectId, ref: "User" },
      type: {
        type: String,
        enum: ["Like", "Comment", "ReplyComment", "AddFriend", "RemoveFriend"],
      },
      timestamps: { type: Date, default: Date() },
    },
  ],
});

const Activity = mongoose.model("Activity", activitySchema);

module.exports = Activity;
