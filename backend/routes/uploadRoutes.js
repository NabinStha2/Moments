const express = require("express");
const multer = require("multer");
const path = require("path");

var storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads");
    // cb(null, "../uploads/");
  },
  filename: (req, file, cb) => {
    console.log(file);
    cb(
      null,
      `moments-${Date.now()}${path.extname(file.originalname)}`
      // `developingmoments-${Date.now()}${path.extname(file.originalname)}`
      // file.originalname
    );
  },
});

function checkFileType(file, cb) {
  const filetypes = /jpg|jpeg|png|mp4/;
  console.log(filetypes.test(path.extname(file.originalname).toLowerCase()));
  console.log(path.extname(file.originalname).toLowerCase());
  const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
  // const mimetype = filetypes.test(file.mimetype);

  if (extname) {
    return cb(null, true);
  } else {
    cb("Images only");
  }
}

const upload = multer({
  storage: storage,
  fileFilter: (req, file, cb) => {
    checkFileType(file, cb);
  },
});

// exports.uploadFile = (file) => {
//   return new Promise((resolve) => {
//     cloudinary.uploader.upload(
//       file,
//       (result) => {
//         resolve({ url: result.url, id: result.public_id });
//       },
//       { resource_type: "auto" }
//     );
//   });
// };

// router.post("/", upload.single("image"), (req, res) => {
//   console.log(req.file.originalname, req.file.path);
//   res.send(`${req.file.originalname}`);
// });

module.exports = upload;
