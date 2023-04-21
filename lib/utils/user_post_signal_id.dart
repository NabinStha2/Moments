import 'package:moment/services/api_config.dart';
import 'package:moment/services/base_client.dart';

Future getUserPostSignalId({baseUrl, postId}) async {
  final response = await BaseClient().get(
      ApiConfig.baseUrl, "/user/getOneSignalUserByPostIds/$postId",
      isTokenHeader: false);
  return response;
}

Future getUserSignalId({baseUrl, userId}) async {
  final response = await BaseClient().get(
      ApiConfig.baseUrl, "/user/getOneSignalUserIds/$userId",
      isTokenHeader: false);
  return response;
}
