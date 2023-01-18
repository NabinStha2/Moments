const { ONE_SIGNAL_CONFIG } = require("../utils/oneSignalConfig");
const pushNotificationService = require("../services/pushNotificationService");

exports.SendNotification = (req, res, next) => {
  var message = {
    app_id: ONE_SIGNAL_CONFIG.APP_ID,
    contents: { en: req.body.msg },
    included_segments: ["Subscribed Users"],
    // included_segments: ["All"],
    content_available: true,
    headings: { en: req.body.headings },
    small_icon: "ic_notification_icon",
    data: {
      PushTitle: "Custom Notification",
    },
  };

  pushNotificationService.SendNotification(message, (error, results) => {
    if (error) return next(error);
    return res.status(200).send({
      message: "Success",
      data: results,
    });
  });
};

exports.SendNotificationToDevice = (req, res, next) => {
  console.log(req.body);
  var message = {
    app_id: ONE_SIGNAL_CONFIG.APP_ID,
    contents: { en: req.body.msg },
    included_segments: ["included_player_ids"],
    include_player_ids: req.body.devices,
    content_available: true,
    small_icon: "ic_notification_icon",
    data: {
      PushTitle: "Custom Notification",
    },
  };

  pushNotificationService.SendNotification(message, (error, results) => {
    if (error) return next(error);
    console.log(results);
    return res.status(200).send({
      message: "Success",
      data: results,
    });
  });
};
