import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalNotificationService {
  static const String oneSignalAppID = "ea8b2f5a8acd452e88b5028f95ab55dd";

  static Future getDeviceId() async {
    var deviceId = await OneSignal.shared.getDeviceState();
    return deviceId?.userId;
  }
}
