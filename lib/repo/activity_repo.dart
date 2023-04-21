import 'package:moment/development/console.dart';
import 'package:moment/models/activity_model/activity_model.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/services/base_client.dart';

class ActivityRepo {
  getAllActivity({id}) async {
    try {
      var response = await BaseClient().get(ApiConfig.baseUrl, "/activity/$id");
      return activityModelFromJson(response);
    } catch (err) {
      consolelog("ERROR: $err");
      rethrow;
    }
  }
}
