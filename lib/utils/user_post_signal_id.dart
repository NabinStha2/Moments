import "package:http/http.dart" as http;
import 'package:moment/services/api_config.dart';
import 'package:moment/services/base_client.dart';

Future getUserPostSignalId({baseUrl, postId}) async {
  final response = await BaseClient().get(ApiConfig.userBaseUrl, "/user/getOneSignalUserIds/$postId", isTokenHeader: false);
  return response;
}
