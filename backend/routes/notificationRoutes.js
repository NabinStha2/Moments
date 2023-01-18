const pushNotificationController = require("../controllers/push-notification");

const router = require("express").Router();

router.post("/SendNotification", pushNotificationController.SendNotification);

router.post(
  "/SendNotificationToDevice",
  pushNotificationController.SendNotificationToDevice
);

module.exports = router;
