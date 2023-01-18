const PostModel = require("../models/postModel");
const cloudinary = require("../utils/cloudinary");
const fs = require("fs");
const Activity = require("../models/activityModel");
const User = require("../models/userModel");
const uuidv4 = require("uuid").v4;

module.exports.getPosts = async (req, res) => {
  const { page } = req.query;
  const perPage = 3;
  const pageNumber = Number(page) || 1;
  // console.log(page);

  try {
    const count = await PostModel.countDocuments();
    const posts = await PostModel.find()
      .sort({ _id: -1 })
      .limit(perPage)
      .skip(perPage * (pageNumber - 1));
    // console.log(posts);
    // posts.map((post) => {
    //   console.log({ post });
    // });
    res.status(200).json({
      data: posts,
      pages: Math.ceil(count / perPage),
      message: "Success",
    });
  } catch (err) {
    console.error(err);
    res.status(400).json({ errMessage: err.message });
  }
};

module.exports.getAllPosts = async (req, res) => {
  // const { page } = req.query;
  // const perPage = 50;
  // const pageNumber = Number(page) || 1;

  console.log("all posts fetching...");

  try {
    const count = await PostModel.countDocuments();
    // console.log(count);
    const posts = await PostModel.find().lean();
    // console.log(posts);
    res.status(200).json({ message: "Success", data: posts });
  } catch (err) {
    console.error(err);
    res.status(400).json({ code: err.code, errMessage: err.message });
  }
};

module.exports.getPostById = async (req, res) => {
  console.log("single post fetching...");
  try {
    const post = await PostModel.findOne({ _id: req.params.id });

    // console.log(post);
    res.status(200).json({ message: "Success", data: [post] });
  } catch (err) {
    // console.error(err);
    res.status(400).json({ code: err.code, errMessage: err.message });
  }
};

module.exports.getPostsByCreator = async (req, res) => {
  try {
    // const name = req.params.name.split("%20").join(" ");
    // console.log(name);
    const posts = await PostModel.find({ creator: req.params.id });

    // console.log(posts);
    res.status(200).json({ message: "Success", data: posts });
  } catch (err) {
    // console.error(err);
    res.status(400).json({ errMessage: err.message });
  }
};

module.exports.createPost = async (req, res) => {
  const { name, description } = req.body;
  console.log(req.file.path);
  if (!name || !description)
    return res.json({ errMessage: "Fill the form completely" });
  var post;
  try {
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "moments",
      // folder: "developingmoments",
      resource_type: "auto",
      public_id: req.file.filename.split(".")[0],
    });
    if (result) {
      console.log(result.resource_type);
      if (result.resource_type == "video") {
        var thumbnail = await cloudinary.utils.video_thumbnail_url(
          result.public_id,
          {
            fetch_format: "jpg",
          }
        );
        // console.log(thumbnail);
        console.log("uploading video");
        post = await PostModel.create({
          name,
          description,
          fileType: "video",
          file: {
            thumbnail: thumbnail,
            fileName: result.public_id,
            fileUrl: result.url,
          },
          creator: req.userId,
          createdAt: Date.now(),
        });
        // console.log(post);
        const user = await User.findById({ _id: req.userId });
        if (user) {
          user.posts.push(post._id);
          // console.log(user);
          await User.findByIdAndUpdate(
            {
              _id: req.userId,
            },
            user,
            {
              new: true,
            }
          );
        }
      } else {
        console.log("uploading image");
        post = await PostModel.create({
          name,
          description,
          fileType: "image",
          file: {
            fileName: result.public_id,
            fileUrl: result.url,
          },
          creator: req.userId,
          createdAt: Date.now(),
        });
        // console.log(post);
        const user = await User.findById({ _id: req.userId });
        if (user) {
          user.posts.push(post._id);
          // console.log(user);
          await User.findByIdAndUpdate(
            {
              _id: req.userId,
            },
            user,
            {
              new: true,
            }
          );
        }
      }
    }
    // console.log(post);
    fs.unlinkSync(req.file.path);
    res.status(201).json({ message: "Success", data: [post] });
  } catch (err) {
    console.error(err.message);
    fs.unlinkSync(req.file.path);
    res.status(409).json({ errMessage: err.message });
  }
};

module.exports.updatePost = async (req, res) => {
  const id = req.params.id;
  console.log(req.file.path);
  var post;

  try {
    const postDetails = await PostModel.findById({ _id: id });
    console.log("deleting the previous file");
    var result = await cloudinary.search
      .expression(
        `(resource_type:image AND public_id: ${postDetails.file.get(
          "fileName"
        )}) OR (resource_type:video AND public_id: ${postDetails.file.get(
          "fileName"
        )})`
      )
      .execute();
    console.log(`deleting the previous ${result.resources[0].resource_type}`);
    var rsType = result.resources[0].resource_type;
    await cloudinary.api.delete_resources(postDetails.file.get("fileName"), {
      resource_type: rsType,
    });
    var uploadResult = await cloudinary.uploader.upload(req.file.path, {
      folder: "moments",
      // folder: "developingmoments",
      resource_type: "auto",
      public_id: req.file.filename.split(".")[0],
    });
    console.log(uploadResult);
    if (uploadResult) {
      console.log(uploadResult.resource_type);
      if (uploadResult.resource_type == "video") {
        var thumbnail = await cloudinary.utils.video_thumbnail_url(
          uploadResult.public_id,
          {
            fetch_format: "jpg",
          }
        );
        console.log(thumbnail);
        console.log("uploading video");
        var postBody = {
          description: req.body.description,
          fileType: "video",
          file: {
            thumbnail: thumbnail,
            fileName: uploadResult.public_id,
            fileUrl: uploadResult.url,
          },
        };
        post = await PostModel.findByIdAndUpdate(
          {
            _id: req.params.id,
          },
          postBody,
          { new: true, timestamp: true }
        );
      } else {
        console.log("uploading image");
        var postBody = {
          description: req.body.description,
          fileType: "image",
          file: {
            fileName: uploadResult.public_id,
            fileUrl: uploadResult.url,
          },
        };
        post = await PostModel.findByIdAndUpdate(
          {
            _id: req.params.id,
          },
          postBody,
          { new: true, timestamp: true }
        );
      }
      fs.unlinkSync(req.file.path);
      res.status(201).json({ message: "Success", data: [post] });
    }
  } catch (err) {
    console.error(err.message);
    fs.unlinkSync(req.file.path);
    res.status(201).json({ errMessage: err.message });
  }
};

module.exports.commentPost = async (req, res) => {
  const { id } = req.params;
  const {
    value,
    userId,
    creatorId,
    userImageUrl,
    activityName,
    postUrl,
    commentId,
    isReply,
    replyToUserId,
  } = req.body;
  console.log(`${id} --- ${value} --- ${replyToUserId} --- ${commentId}`);
  if (!req.userId) return res.json({ errMessage: "Unauthenticated!" });

  var activityId = uuidv4();
  console.log(activityId);
  try {
    const post = await PostModel.findById(id);
    // console.log(post);

    const acts = await Activity.findOne({ activityUserId: creatorId });
    newActivityData = {
      userId: userId,
      postId: id,
      userImageUrl: userImageUrl,
      activityName: activityName,
      postUrl: postUrl,
      type: "Comment",
      ownerId: creatorId,
      activityId: activityId,
      timestamps: new Date(),
    };
    acts.activity.push(newActivityData);
    const activity = await Activity.findOneAndUpdate(
      { activityUserId: creatorId },
      acts,
      {
        new: true,
      }
    );
    // console.log(activity);

    if (isReply) {
      newReplyCommentData = {
        commentName: value,
        commentUserId: userId,
        timestamps: new Date(),
        replyToUserId: replyToUserId,
      };

      post.comments.map((cmt) => {
        if (cmt._id.toString() === commentId) {
          // console.log(`cmt: ${cmt}`);
          cmt.activityId.push(activityId);
          cmt.replyComments.push(newReplyCommentData);
        }
      });
      // console.log(post.comments);
    } else {
      newCommentData = {
        commentName: value,
        commentUserId: userId,
        activityId: activityId,
        timestamps: new Date(),
        replyComments: [],
      };
      post.comments.push(newCommentData);
    }
    const updatedPost = await PostModel.findByIdAndUpdate(id, post, {
      new: true,
    });

    res.status(201).json({ message: "Success", data: [updatedPost] });
  } catch (err) {
    console.error(err.message);
    res.status(201).json({ errMessage: err.message });
  }
};

module.exports.likePost = async (req, res) => {
  const {
    userId,
    creatorId,
    userImageUrl,
    activityName,
    postUrl,
    reactionType,
    likeValue,
  } = req.body;
  if (!req.userId) return res.json({ errMessage: "Unauthenticated!" });
  console.log(userId, creatorId, postUrl, activityName, reactionType);

  const { id } = req.params;

  try {
    const post = await PostModel.findById(id);
    const index = post.likes.findIndex(
      (like) => String(like.userId) === String(req.userId)
    );

    const acts = await Activity.findOne({ activityUserId: creatorId });
    if (acts) {
      const activityIndex = acts.activity.findIndex((item) => {
        if (item.type === "Like") {
          if (item.userId == userId) {
            if (item.postId == id) {
              // console.log("false");
              return true;
            } else {
              return false;
            }
          }
        }
        return false;
      });
      // console.log(activityIndex);
      newActivityData = {
        userId: userId,
        postId: id,
        userImageUrl: userImageUrl,
        activityName: activityName,
        postUrl: postUrl,
        type: "Like",
        ownerId: creatorId,
        timestamps: new Date(),
      };

      if (index === -1) {
        newLikesData = {
          userId: req.userId,
          reactionType: reactionType,
          timestamps: new Date(),
          likeValue: likeValue,
        };

        post.likes.push(newLikesData);
        acts.activity.push(newActivityData);
      } else {
        if (post.likes[index].reactionType !== reactionType) {
          console.log(post.likes[index].reactionType, reactionType);
          post.likes[index].reactionType = reactionType;
          if (activityIndex !== -1) {
            acts.activity[activityIndex].activityName = activityName;
          }
        } else {
          console.log("unlike");
          post.likes = post.likes.filter(
            (like) => String(like.userId) !== String(userId)
          );
          acts.activity = acts.activity.filter((item) => {
            if (item.type === "Like") {
              if (item.userId == userId) {
                if (item.postId == id) {
                  // console.log("false");
                  return false;
                } else {
                  return true;
                }
              }
            }
            return true;
          });
        }
      }
    }

    const updatedPost = await PostModel.findByIdAndUpdate({ _id: id }, post, {
      new: true,
    });

    // console.log(acts);
    await Activity.findOneAndUpdate({ activityUserId: creatorId }, acts, {
      new: true,
      timestamps: true,
    });
    // console.log(updatedPost.likes);
    res.status(201).json({ message: "Success", data: [updatedPost] });
  } catch (err) {
    console.error(err.message);
    res.status(400).json({ errMessage: err.message });
  }
};

module.exports.deletePost = async (req, res) => {
  // const id = req.params.id;
  try {
    const deletedPost = await PostModel.findByIdAndDelete(req.params.id);
    // console.log(deletedPost.file.get("fileUrl"));
    console.log("deleting the post");
    // console.log(deletedPost);

    const user = await User.findById({ _id: deletedPost.creator });
    if (user) {
      // console.log(user.posts);
      user.posts = user.posts.filter((post) => post === deletedPost.creator);
      // console.log(user.posts);
      await User.findByIdAndUpdate({ _id: deletedPost.creator }, user, {
        new: true,
      });
    }

    const acts = await Activity.findOne({ "activity.postId": req.params.id });
    if (acts != null) {
      acts.activity = acts.activity.filter((item) => {
        if (item.postId == req.params.id) {
          // console.log("false");
          return false;
        } else {
          return true;
        }
      });
      // console.log(acts);

      await Activity.findOneAndUpdate(
        { "activity.postId": req.params.id },
        acts,
        {
          new: true,
          timestamps: true,
        }
      );
    }

    cloudinary.search
      .expression(
        `(resource_type:image AND public_id: ${deletedPost.file.get(
          "fileName"
        )}) OR (resource_type:video AND public_id: ${deletedPost.file.get(
          "fileName"
        )})`
      )
      .execute()
      .then((result) => {
        console.log(result.resources[0].resource_type);
        var rsType = result.resources[0].resource_type;
        cloudinary.api
          .delete_resources(deletedPost.file.get("fileName"), {
            resource_type: rsType,
          })
          .then((result) => {
            console.log(result);
            res.status(201).json({ message: "Success", data: [deletedPost] });
          });
      });
  } catch (err) {
    console.error(err.message);
    res.status(201).json({ errMessage: err.message });
  }
};

module.exports.deleteComment = async (req, res) => {
  const postId = req.params.id;
  const { commentId, activityId } = req.body;
  console.log(activityId);
  try {
    const post = await PostModel.findById(postId);
    console.log("deleting the comment");
    // console.log(deletedPost);

    if (post) {
      post.comments = post.comments.filter((cmt) => {
        if (cmt._id == commentId) {
          return false;
        }
        return true;
      });
    }
    const updatedPost = await PostModel.findByIdAndUpdate(
      { _id: postId },
      post,
      {
        new: true,
      }
    );

    const acts = await Activity.findOne({ "activity.activityId": activityId });
    if (acts != null) {
      console.log(acts);

      activityId.map((id) => {
        acts.activity = acts.activity.filter((item) => {
          if (item.activityId === id) {
            console.log("false");
            return false;
          } else {
            return true;
          }
        });
        return true;
      });
      console.log(acts);

      await Activity.findOneAndUpdate(
        { "activity.activityId": activityId },
        acts,
        {
          new: true,
          timestamps: true,
        }
      );
    }

    res.status(200).json({ message: "Success", data: [updatedPost] });
  } catch (err) {
    console.error(err.message);
    res.status(201).json({ errMessage: err.message });
  }
};
