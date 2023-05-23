require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const path = require("path");
var http = require("http");
var {
  RtcTokenBuilder,
  RtmTokenBuilder,
  RtcRole,
  RtmRole,
} = require("agora-access-token");

const userRoutes = require("./routes/userRoutes");
const postRoutes = require("./routes/postRoutes");
const notificationRoutes = require("./routes/notificationRoutes");
const activityRoutes = require("./routes/activityRoutes");

const app = express();

app.use(cors());
app.use(express.json({ limit: "10000mb" }));
app.use(express.urlencoded({ limit: "10000mb", extended: true }));

// Fill the appID and appCertificate key given by Agora.io
var appID = "ea8b2f5a8acd452e88b5028f95ab55dd";
var appCertificate = "c855dea313aa4f848c1c7a7b17dd5889";
// token expire time, hardcode to 3600 seconds = 1 hour
var expirationTimeInSeconds = 3600;
var role = RtcRole.PUBLISHER;

var server = http.createServer(app);
var io = require("socket.io")(server, { cors: { origin: "*" } });

app.use("/uploads", express.static(__dirname + "/uploads"));

app.use("/posts", postRoutes);
app.use("/user", userRoutes);
app.use("/api", notificationRoutes);
app.use("/activity", activityRoutes);

app.get("/", (req, res) => {
  res.send("Hello");
});

let clients = [];

io.on("connection", (socket) => {
  console.log(socket.id, "has joined");

  socket.on("connect_error", (err) => {
    console.log(`connect_error due to ${err.message}`);
  });

  socket.on("disconnect", function () {
    console.log(`user disconnected`);
    // console.log(Object.keys(clients));
  });

  socket.on("signIn", (name, id, targetId) => {
    console.log(`${id} has enter ${targetId}`);
    // console.log(`${targetId} has signIn`);
    clients[id] = { socket, targetId };
    // clients[targetId] = { socket, targetId };
    console.log(Object.keys(clients));
    // console.log(clients[id]["targetId"]);
    if (clients[targetId] && clients[targetId]["targetId"] === id) {
      // console.log("bot received in signIn");
      io.to(clients[targetId]["socket"]["id"]).emit("user_enter", name);
    }
  });

  socket.on("user_online", (id, targetId) => {
    if (Object.keys(clients).find((key) => key === targetId) !== undefined) {
      var keys = Object.keys(clients);
      var indexOfId = keys.indexOf(id);
      if (clients[targetId]["targetId"] === keys[indexOfId])
        socket.emit("user_login", true);
    } else {
      socket.emit("user_login", false);
    }
  });

  socket.on("user_leave", (name, id, targetId) => {
    console.log(`${id} has left the ${targetId} chat!`);
    let tempClients = clients;
    clients = [];
    // console.log(tempClients);
    Object.keys(tempClients).map((keyId) => {
      // console.log(keyId);
      if (keyId !== id) {
        clients[keyId] = tempClients[keyId];
      }
    });

    console.log(Object.keys(clients));
    if (clients[targetId] && clients[targetId]["targetId"] === id) {
      // console.log("bot received");
      io.to(clients[targetId]["socket"]["id"]).emit("user_leave", name);
    }
  });

  socket.on("message", (msg) => {
    console.log(msg);
    let targetId = msg.targetId;
    if (clients[targetId] && clients[targetId]["targetId"] === msg.senderId) {
      console.log("received");
      io.to(clients[targetId]["socket"]["id"]).emit("message", msg);
    }
  });
});

// instrument(io, { auth: false });

var generateRtcToken = function (req, resp) {
  var currentTimestamp = Math.floor(Date.now() / 1000);
  var privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
  var channelName = req.params.channelName || "";
  console.log(channelName);

  // use 0 if uid is not specified
  var uid = req.query.uid || 0;
  if (channelName === "") {
    console.log("jshakj");
    return resp.status(400).json({ error: "channel name is required" }).send();
  }

  var key = RtcTokenBuilder.buildTokenWithUid(
    appID,
    appCertificate,
    channelName,
    uid,
    role,
    privilegeExpiredTs
  );

  // console.log(key);

  resp.header("Access-Control-Allow-Origin", "*");
  //resp.header("Access-Control-Allow-Origin", "http://ip:port")
  return resp.json({ key: key });
};

// var generateRtmToken = function (req, resp) {
//   var currentTimestamp = Math.floor(Date.now() / 1000);
//   var privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
//   var account = req.query.account;
//   if (!account) {
//     return resp.status(400).json({ error: "account is required" });
//   }

//   var key = RtmTokenBuilder.buildToken(
//     appID,
//     appCertificate,
//     account,
//     RtmRole,
//     privilegeExpiredTs
//   );

//   resp.header("Access-Control-Allow-Origin", "*");
//   //resp.header("Access-Control-Allow-Origin", "http://ip:port")
//   return resp.json({ key: key });
// };

app.get("/rtcToken/:channelName", generateRtcToken);
// app.get("/rtmToken", generateRtmToken);

const PORT = process.env.PORT || 4000;

mongoose
  .connect(process.env.MONGODB_URL, {
    useFindAndModify: false,
    useCreateIndex: true,
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    server.listen(PORT, (req, res) => {
      console.log(`Server has started at port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error(err);
  });
