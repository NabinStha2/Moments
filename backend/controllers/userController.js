const User = require("../models/userModel");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const cloudinary = require("../utils/cloudinary");
const PostModel = require("../models/postModel");
const NodeCache = require("node-cache");
// const myCache = new NodeCache();
const fs = require("fs");
const Activity = require("../models/activityModel");

const getAllUsers = async (req, res) => {
  try {
    console.log("Fetching All Data...");

    const users = await User.find()
      .sort({ name: "asc" })
      .select("-password")
      .lean();
    if (users) {
      // myCache.set("users", JSON.stringify(users), 864000);
      // console.log("all user data cache:" + myCache.has("users"));

      console.log(users);
      res.status(200).json({ message: "Success", data: users });
    } else {
      res.status(404).json({ errMessage: "No User!" });
    }
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const getUser = async (req, res) => {
  try {
    const id = req.params.id;
    console.log("Fetching Owner Data...");

    const user = await User.findById({ _id: id }).select("-password").lean();
    if (user) {
      // if (myCache.has(`${id}`) === false) {
      //   myCache.set(`${user._id}`, JSON.stringify(user), 864000);
      // }

      console.log(user);
      res.status(200).json({ message: "Success", data: user });
    } else {
      res.status(404).json({ errMessage: "No User!" });
    }
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const getUserFriends = async (req, res) => {
  try {
    const id = req.params.id;
    console.log("Fetching Friends Data...");

    var users = await User.find().select("-password").lean();
    var user = await User.findById({ _id: id }).select("-password").lean();

    if (user) {
      users = users.filter((usr) => {
        // console.log(usr._id);
        const index = user.friends.findIndex((id) => id === String(usr._id));
        if (index === -1) {
          return false;
        } else {
          return true;
        }
      });
      console.log("users: " + users);
      // if (myCache.has(`${id}friends`) === false) {
      //   myCache.set(`${user._id}friends`, JSON.stringify(users), 864000);
      // }

      users.map((usr) => console.log(usr._id));
      res.status(200).json({ message: "Success", data: users });
    } else {
      res.status(404).json({ errMessage: "No User!" });
    }
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const login = async (req, res) => {
  const { email, password, oneSignalUserId } = req.body;
  console.log(email, oneSignalUserId);

  try {
    const userExists = await User.findOne({ email: email });

    if (userExists) {
      // var filterUser = userExists.oneSignalUserId.filter(
      //   (id) => id !== oneSignalUserId
      // );
      // filterUser.push(oneSignalUserId);
      // await User.findByIdAndUpdate(
      //   { _id: userExists },
      //   { oneSignalUserId: filterUser },
      //   { new: true }
      // );

      if (!userExists.oneSignalUserId.includes(oneSignalUserId)) {
        console.log("updating oneSignalUserId");
        userExists.oneSignalUserId.push(oneSignalUserId);
        console.log(userExists);
        await User.findByIdAndUpdate({ _id: userExists._id }, userExists, {
          new: true,
        });
      }
      const isPasswordCorrect = await bcrypt.compare(
        password,
        userExists.password
      );
      if (!isPasswordCorrect)
        return res.status(400).json({ errMessage: "Password incorrect!" });

      const token = jwt.sign(
        { email: userExists.email, id: userExists._id },
        process.env.TOKEN_SECRET_KEY,
        {
          expiresIn: "600d",
        }
      );
      var data = {
        email: userExists.email,
        friends: userExists.friends,
        oneSignalUserId: userExists.oneSignalUserId,
        image: userExists.image,
        about: userExists.about,
        name: userExists.name,
        posts: userExists.posts,
        msgFile: userExists.msgFile,
        _id: userExists._id,
        token: token,
      };
      console.log(data);
      res.status(200).json({ message: "Success", data: data });
    } else {
      res.status(404).json({ errMessage: "User not found with this email." });
    }
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const getOneSignalUserById = async (req, res) => {
  try {
    const post = await PostModel.findById({ _id: req.params.id })
      .populate("creator")
      .lean();
    // console.log(post);
    const user = await User.findById({ _id: post.creator._id });
    // console.log(user.oneSignalUserId);
    res.status(200).json({ message: "Success", data: user.oneSignalUserId });
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const logout = async (req, res) => {
  const { oneSignalUserId } = req.body;
  try {
    // myCache.del("users");
    // myCache.del(`${req.params.id}`);
    // myCache.del(`${req.params.id}friends`);
    const user = await User.findById({ _id: req.params.id });
    console.log(user.oneSignalUserId);

    const filteredUser = user.oneSignalUserId.filter(
      (id) => id !== oneSignalUserId
    );
    console.log(filteredUser);
    const updatedUser = await User.findByIdAndUpdate(
      { _id: req.params.id },
      { oneSignalUserId: filteredUser },
      { new: true }
    );
    console.log(updatedUser.oneSignalUserId);

    res.status(200).json({ oneSignalUserId: user.oneSignalUserId });
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const register = async (req, res) => {
  const { firstName, lastName, email, password, confirmPassword } = req.body;

  try {
    const userExists = await User.findOne({ email: email });
    if (!userExists) {
      if (password !== confirmPassword) {
        return res.status(400).json({ errMessage: "Password don't match!" });
      }
      if (password.length < 6) {
        return res
          .status(400)
          .json({ errMessage: "Password must be of 6 length!" });
      }
      const hashedPassword = await bcrypt.hash(password, 12);

      const newUser = await User.create({
        email,
        password: hashedPassword,
        name: `${firstName} ${lastName}`,
      });

      const token = jwt.sign(
        { email: newUser.email, id: newUser._id },
        process.env.TOKEN_SECRET_KEY,
        {
          expiresIn: "30d",
        }
      );

      await Activity.create({
        activityUserId: newUser._id,
        activity: [],
      });
      var data = {
        email: newUser.email,
        friends: newUser.friends,
        oneSignalUserId: newUser.oneSignalUserId,
        image: newUser.image,
        about: newUser.about,
        name: newUser.name,
        posts: newUser.posts,
        msgFile: newUser.msgFile,
        _id: newUser._id,
        token: token,
      };
      // console.log(newUser);

      res.status(200).json({ message: "Success", data: data });
    } else {
      res
        .status(400)
        .json({ errMessage: "User already exists with this email." });
    }
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const imageUpload = async (req, res) => {
  const id = req.params.id;

  console.log(`${id} ---- ${req.file.path}`);
  try {
    const existsUser = await User.findById({ _id: id });
    if (existsUser && existsUser.image.get("imageName") != null) {
      console.log("user image deleted from cloudinary");
      await cloudinary.uploader.destroy(existsUser.image.get("imageName"));
    }

    // if (myCache.has(`${id}`) === true) {
    //   myCache.del(`${existsUser._id}`);
    // }
    // myCache.del("users");
    // myCache.del(`${req.params.id}friends`);
    // upload image here
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "moments",
      // folder: "developingmoments",
      resource_type: "auto",
      public_id: req.file.filename.split(".")[0],
    });
    // console.log(result);
    if (result) {
      // const user = await User.findById({ _id: id });
      const user = await User.findByIdAndUpdate(
        { _id: id },
        {
          image: {
            imageName: result.public_id,
            imageUrl: result.url,
          },
        },
        { new: true }
      );
      // console.log(user);
      //fs.unlinkSync(req.file.path);
      res.status(200).json({ message: "Success", data: user });
    }
  } catch (err) {
    // console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const msgImageUpload = async (req, res) => {
  const id = req.params.id;

  console.log(`${id} ---- ${req.file.path}`);
  try {
    const existsUser = await User.findById({ _id: id });

    // upload image here
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "messageMoments",
      resource_type: "auto",
      public_id: req.file.filename.split(".")[0],
    });
    // console.log(result);
    if (result) {
      var thumbnail = "";
      if (result.resource_type == "video") {
        thumbnail = await cloudinary.utils.video_thumbnail_url(
          result.public_id,
          {
            fetch_format: "jpg",
          }
        );
      }

      existsUser.msgFile.push(result.public_id);
      const updatedUser = await User.findByIdAndUpdate(
        { _id: id },
        existsUser,
        { new: true }
      );
      console.log(updatedUser);
      //fs.unlinkSync(req.file.path);
      var messageModel = {
        messageContent: req.body.text,
        messageType: "sender",
        filePath: result.url,
        fileType: result.resource_type,
        thumbnail: thumbnail,
      };
      res.status(201).json({ message: "Success", data: messageModel });
    }
  } catch (err) {
    console.log(err.message);
    //fs.unlinkSync(req.file.path);
    res.status(500).json({ errMessage: err.message });
  }
};

const deleteMsgImage = async (req, res) => {
  const id = req.params.id;
  try {
    const existsUser = await User.findById({ _id: id });

    existsUser.msgFile.forEach((image) => {
      cloudinary.search
        .expression(
          `(resource_type:image AND public_id: ${image}) OR (resource_type:video AND public_id: ${image})`
        )
        .execute()
        .then((result) => {
          console.log(result.resources[0].resource_type);
          var rsType = result.resources[0].resource_type;
          cloudinary.api
            .delete_resources(image, {
              resource_type: rsType,
            })
            .then((result) => {
              // console.log(result);
            });
        });
    });
    const updatedUser = await User.findByIdAndUpdate(
      { _id: id },
      { msgFile: [] },
      { new: true }
    );
    console.log(updatedUser.msgFile);
    res.status(200).json({ message: "Success" });
  } catch (err) {
    // console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const editUserProfile = async (req, res) => {
  const id = req.params.id;
  const name = req.body.name;
  const about = req.body.about || "";
  // console.log(`${id} ---- ${name} -- ${about}`);
  try {
    const userData = await User.findById({ _id: id });
    const user = await User.findByIdAndUpdate(
      { _id: id },
      {
        name: name == "" ? userData.name : name,
        about: about,
      },
      { new: true }
    );

    // if (myCache.has(`${id}`) === true) {
    //   myCache.del(`${userData._id}`);
    // }
    // myCache.del("users");
    // console.log(myCache.has("users"));

    // console.log(user.phoneNumber);
    res.status(200).json({ message: "Success", data: user });
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

const addUser = async (req, res) => {
  const id = req.params.id;
  const { friend, creatorId, userImageUrl, activityName } = req.body;
  // console.log(`${id} ---- ${friend}`);
  try {
    const userData = await User.findById({ _id: id }).lean();

    const acts = await Activity.findOne({ activityUserId: creatorId });
    console.log(acts);

    const index = userData.friends.findIndex((fnd) => fnd === friend);
    if (index === -1) {
      userData.friends.push(friend);
      newData = {
        userId: id,
        userImageUrl: userImageUrl,
        activityName: `${activityName} has added you to friend.`,
        type: "AddFriend",
        ownerId: creatorId,
        timestamps: new Date(),
      };
      acts.activity = acts.activity.filter((item) => {
        if (item.type === "RemoveFriend") {
          if (item.userId == id && item.ownerId == creatorId) {
            return false;
          }
        }
        return true;
      });
      acts.activity.push(newData);
    } else {
      userData.friends = userData.friends.filter((fnd) => fnd !== friend);
      newData = {
        userId: id,
        userImageUrl: userImageUrl,
        activityName: `${activityName} has removed you from friend.`,
        type: "RemoveFriend",
        ownerId: creatorId,
        timestamps: Date.now(),
      };
      acts.activity = acts.activity.filter((item) => {
        if (item.type === "AddFriend") {
          if (item.userId == id && item.ownerId == creatorId) {
            return false;
          }
        }
        return true;
      });
      acts.activity.push(newData);
    }

    const user = await User.findByIdAndUpdate({ _id: id }, userData, {
      new: true,
    });

    const activity = await Activity.findOneAndUpdate(
      { activityUserId: creatorId },
      acts,
      {
        new: true,
      }
    );

    console.log(activity);

    // if (myCache.has(`${id}`) === true) {
    //   myCache.del(`${userData._id}`);
    // }
    // if (myCache.has(`${id}friends`) === true) {
    //   myCache.del(`${userData._id}friends`);
    // }

    // console.log("user cache: " + myCache.has(`${userData._id}`));
    // console.log("user friends cache: " + myCache.has(`${id}friends`));
    // console.log(myCache.keys());
    console.log(user.friends);
    res.status(200).json({ message: "Success", data: user });
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ errMessage: err.message });
  }
};

module.exports = {
  getAllUsers,
  imageUpload,
  register,
  logout,
  login,
  editUserProfile,
  getUser,
  addUser,
  msgImageUpload,
  deleteMsgImage,
  getUserFriends,
  getOneSignalUserById,
};
