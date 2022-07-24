import 'dart:convert';
import 'dart:developer';

import "package:http/http.dart" as http;
import 'package:moment/models/activity_model.dart';

class ActivityRepo {
  final String baseUrl = "momentsapps.herokuapp.com";
  // final String baseUrl = "192.168.1.78:3000";

  Future<List<ActivityModel>?> getAllActivity({id}) async {
    try {
      final uri = Uri.https(baseUrl, "/activity/$id");
      // final uri = Uri.http(baseUrl, "/activity/$id");
      final response = await http.get(
        uri,
      );

      log("Activity: ${response.body}");

      var activity = json.decode(response.body);

      return (activity["activity"]["activity"] as List)
          .map((act) => ActivityModel.fromMap(act))
          .toList();
    } catch (err) {
      inspect(err);
    }
  }
}
