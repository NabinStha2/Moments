const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  name: { type: String, required: [true, "name must not be empty"] },
  email: {
    type: String,
    required: [true, "email must not be empty"],
    unique: true,
  },
  password: {
    type: String,
    required: [true, "password must not be empty"],
    minLength: [6, "password must be of length six"],
  },
  oneSignalUserId: [{ type: String, default: [] }],
  image: { type: Map, default: {}, of: String },
  about: { type: String, default: "" },
  friends: [{ type: String, default: [] }],
  msgFile: [{ type: String, default: [] }],
  posts: [{ type: mongoose.Types.ObjectId, ref: "PostModel" }],
});

const User = mongoose.model("User", userSchema);

module.exports = User;
