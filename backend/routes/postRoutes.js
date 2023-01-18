const express = require("express");
const {
  getPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
  likePost,
  getPostsByCreator,
  commentPost,
  uploadImage,
  getAllPosts,
  deleteComment,
} = require("../controllers/postController");
const { authorization } = require("../middleware/authMiddleware");
const upload = require("./uploadRoutes");

const router = express.Router();

router.get("/", getPosts);

router.get("/all", getAllPosts);

router.get("/creators/:id", getPostsByCreator);

router.get("/singlePost/:id", getPostById);

router.post("/", upload.single("image"), authorization, createPost);

// router.patch("/uploadImage/:id", upload.single("image"), uploadImage);

router.patch("/:id", upload.single("image"), authorization, updatePost);

router.delete("/:id", authorization, deletePost);

router.patch("/deleteComment/:id", authorization, deleteComment);

router.patch("/like/:id", authorization, likePost);

router.patch("/:id/commentPost", authorization, commentPost);

module.exports = router;
