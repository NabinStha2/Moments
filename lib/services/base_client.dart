import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:moment/development/console.dart';
import 'package:moment/utils/storage_services.dart';

import 'api_exceptions.dart';

class BaseClient {
  // ignore: constant_identifier_names
  static const int TIME_OUT_DURATION = 60;

  final Map<String, String> _headers = {'Content-type': 'application/json', 'Accept': 'application/json'};
  final Map<String, String> _tokenHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    HttpHeaders.authorizationHeader: "Bearer ${StorageServices.authStorageValues["token"]}",
  };

  //DELETE
  Future<dynamic> delete(String baseUrl, String api, {bool isTokenHeader = true, dynamic payloadObj}) async {
    var uri = Uri.parse(baseUrl + api);
    var payload = json.encode(payloadObj ?? {});
    try {
      var response = await http
          .delete(uri, body: payload, headers: isTokenHeader ? _tokenHeaders : _headers)
          .timeout(const Duration(seconds: TIME_OUT_DURATION));
      consolelog(uri);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw ApiNotRespondingException('Something went wrong, Try again');
    }
  }

  //GET
  Future<dynamic> get(String baseUrl, String api, {bool isTokenHeader = true}) async {
    var uri = Uri.parse(baseUrl + api);
    try {
      var response = await http
          .get(
            uri,
            headers: isTokenHeader ? _tokenHeaders : _headers,
          )
          .timeout(const Duration(seconds: TIME_OUT_DURATION));
      consolelog(uri);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw ApiNotRespondingException('Something went wrong, Try again');
    }
  }

//PATCH
  Future<dynamic> patch(
    String baseUrl,
    String api,
    Map payloadObj, {
    bool isTokenHeader = true,
  }) async {
    var uri = Uri.parse(baseUrl + api);
    var payload = json.encode(payloadObj);

    try {
      var response =
          await http.patch(uri, body: payload, headers: isTokenHeader ? _tokenHeaders : _headers).timeout(const Duration(seconds: TIME_OUT_DURATION));
      consolelog(uri);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException(
        'No Internet connection',
      );
    } on TimeoutException {
      throw ApiNotRespondingException(
        'API not responding in time',
      );
    }
  }

//POST
  Future<dynamic> post(
    String baseUrl,
    String api,
    dynamic payloadObj, {
    bool isTokenHeader = true,
  }) async {
    var uri = Uri.parse(baseUrl + api);

    var payload = json.encode(payloadObj);

    try {
      var response = await http
          .post(
            uri,
            body: payload,
            headers: isTokenHeader ? _tokenHeaders : _headers,
          )
          .timeout(const Duration(seconds: TIME_OUT_DURATION));
      consolelog(uri);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException(
        'No Internet Connection',
      );
    } on TimeoutException {
      throw ApiNotRespondingException(
        'API not responded in time',
      );
    }
  }

  // // file
  // Future<dynamic> postWithFile(
  //   String baseUrl,
  //   String api,
  //   Map<String, String> payloadObj, {
  //   File? file,
  //   String method = 'POST',
  //   String? imageKey,
  //   bool isTokenHeader = true,
  // }) async {
  //   var uri = Uri.parse(
  //     baseUrl + api,
  //   );
  //   try {
  //     var request = http.MultipartRequest(method, uri);
  //     request.headers.addAll(isTokenHeader ? _tokenHeaders : _headers);

  //     if (file != null) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           "$imageKey",
  //           file.path,
  //           // contentType: MediaType(
  //           //   UserController.instance.pickedFile?.extension?.contains('pdf') ==
  //           //           true
  //           //       ? 'application'
  //           //       : 'image',
  //           //   UserController.instance.pickedFile?.extension?.contains('pdf') ==
  //           //           true
  //           //       ? 'pdf'
  //           //       : 'jpg',
  //           // ),
  //         ),
  //       );
  //     }
  //     request.fields.addAll(payloadObj);
  //     var data = await request.send();
  //     var response =
  //         await http.Response.fromStream(data).timeout(const Duration(
  //       seconds: TIME_OUT_DURATION,
  //     ));

  //     return _processResponse(response);
  //   } on SocketException {
  //     throw FetchDataException(
  //       'No Internet connection',
  //     );
  //   } on TimeoutException {
  //     throw ApiNotRespondingException(
  //       'Something went wrong, Try again',
  //     );
  //   }
  // }

  Future<dynamic> postWithImage(
    String baseUrl,
    String api, {
    bool isImage = true,
    bool isBody = true,
    Map<String, String>? payloadObj,
    List<File>? imgFiles,
    File? file,
    String method = 'POST',
    String? imageKey,
    bool isTokenHeader = true,
  }) async {
    var uri = Uri.parse(
      baseUrl + api,
    );
    try {
      var request = http.MultipartRequest(method, uri);
      request.headers.addAll(isTokenHeader ? _tokenHeaders : _headers);
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "$imageKey",
            file.path,
            // contentType: isImage
            //     ? MediaType(
            //         'image',
            //         'jpg',
            //       )
            //     : MediaType(
            //         "video",
            //         "mp4",
            //       ),
          ),
        );
      }
      if (imgFiles?.isNotEmpty == true) {
        for (var i = 0; i < imgFiles!.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "$imageKey",
              imgFiles[i].path,
              // contentType: MediaType(
              //   'image',
              //   'jpg',
              // ),
            ),
          );
        }
      }

      if (isBody) {
        request.fields.addAll(payloadObj ?? <String, String>{});
      }
      var data = await request.send();
      var response = await http.Response.fromStream(data);
      consolelog(uri); // consoleinspect(response);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException(
        'No Internet connection',
      );
    } on TimeoutException {
      throw ApiNotRespondingException(
        'Something went wrong, Try again',
      );
    }
  }

  Future<dynamic> put(
    String baseUrl,
    String api,
    dynamic payloadObj, {
    bool isTokenHeader = true,
  }) async {
    var uri = Uri.parse(baseUrl + api);
    var payload = json.encode(payloadObj);
    try {
      var response =
          await http.put(uri, body: payload, headers: isTokenHeader ? _tokenHeaders : _headers).timeout(const Duration(seconds: TIME_OUT_DURATION));
      consolelog(uri);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException(
        'No Internet connection',
      );
    } on TimeoutException {
      throw ApiNotRespondingException(
        'Something went wrong, Try again',
      );
    }
  }

  dynamic _processResponse(http.Response response) {
    consolelog(response.statusCode.toString());
    switch (response.statusCode) {
      case 200:
        var responseJson = utf8.decode(response.bodyBytes);
        return responseJson;
      case 201:
        var responseJson = utf8.decode(response.bodyBytes);
        return responseJson;
      case 400:
        throw BadRequestException(
          (json.decode(response.body)["errMessage"] ?? "Something went wrong").toString(),
        );
      case 401:
      case 403:
        throw UnauthorisedException(
          json.decode(response.body)["errMessage"] ?? "Something went wrong",
        );
      case 422:
        throw ApiNotRespondingException(
          json.decode(response.body)["errMessage"] ?? "Something went wrong",
        );
      case 500:
      default:
        throw FetchDataException(
          json.decode(response.body)["errMessage"],
        );
    }
  }
}
