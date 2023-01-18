const express = require("express");
const {
  login,
  register,
  imageUpload,
  getOneSignalUserById,
  logout,
  getAllUsers,
  getUser,
  getUserFriends,
  editUserProfile,
  addUser,
  msgImageUpload,
  deleteMsgImage,
} = require("../controllers/userController.js");
const upload = require("./uploadRoutes");

const router = express.Router();

// const getAllUsersCache = (req, res, next) => {
//   // console.log(myCache.has("users"));
//   const users = myCache.get("users");
//   // console.log(users);
//   if (users != undefined) {
//     console.log("getAllUsersCache Hit...");
//     res.json({ users: JSON.parse(users) });
//   } else {
//     next();
//   }
// };
// const getOwnerDetailsCache = (req, res, next) => {
//   // console.log(myCache.has(`${req.params.id}`));
//   const users = myCache.get(`${req.params.id}`);
//   // console.log(users);
//   if (users != undefined) {
//     console.log("getOwnerDetailsCache Hit...");
//     res.json({ userProfile: JSON.parse(users) });
//   } else {
//     next();
//   }
// };
// const getUserFriendsCache = (req, res, next) => {
//   // console.log(myCache.has(`${req.params.id}friends`));
//   const users = myCache.get(`${req.params.id}friends`);
//   // console.log(users);
//   if (users != undefined) {
//     console.log("getUserFriendsCache Hit...");
//     res.json({ users: JSON.parse(users) });
//   } else {
//     next();
//   }
// };

router.get("/getUsers", getAllUsers);

router.get("/getUser/:id", getUser);

router.get("/getUserFriends/:id", getUserFriends);

router.get("/getOneSignalUserIds/:id", getOneSignalUserById);

router.post("/login", login);

router.post("/signup", register);

router.patch("/logout/:id", logout);

router.patch("/image/:id", upload.single("image"), imageUpload);

router.patch("/msgImage/:id", upload.single("image"), msgImageUpload);

router.patch("/editProfile/:id", editUserProfile);

router.patch("/addUser/:id", addUser);

router.patch("/deleteMsgImage/:id", deleteMsgImage);

module.exports = router;
