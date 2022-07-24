import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:moment/models/chat_model.dart';
import 'package:moment/models/user_model.dart';
import 'package:native_notify/native_notify.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UserRepo {
  final String baseUrl = "momentsapps.herokuapp.com";
  // final String baseUrl = "192.168.1.78:3000";

  Future<UserModel?> login(data) async {
    try {
      inspect(data);
      var deviceState = await OneSignal.shared.getDeviceState();

      // print(data.runtimeType);
      if (deviceState != null) {
        if (deviceState.userId != null) {
          inspect(deviceState.userId);
          final uri = Uri.https(baseUrl, "/user/login");
          // final uri = Uri.http(baseUrl, "/user/login");
          final response = await http.post(
            uri,
            headers: {
              HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
            },
            body: json.encode(<String, dynamic>{
              "oneSignalUserId": deviceState.userId,
              "email": data["email"],
              "password": data["password"],
            }),
          );
          print(response.body);
          if (response.statusCode == 200) {
            var resData = json.decode(response.body);
            print(resData["userProfile"]["_id"]);
            // NativeNotify.registerIndieID(resData["userProfile"]["_id"]);
            OneSignal.shared
                .setExternalUserId(resData["userProfile"]["_id"])
                .then((results) {
              print("Results: $results");
            }).catchError((error) {
              print("Error : $error.toString()");
            });
          }

          return UserModel.fromJson(response.body);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<UserModel?> register(data) async {
    try {
      final uri = Uri.https(baseUrl, "/user/signup");
      // final uri = Uri.http(baseUrl, "/user/signup");
      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
        body: json.encode(<String, dynamic>{
          "firstName": data["firstName"],
          "lastName": data["lastName"],
          "email": data["email"],
          "password": data["password"],
          "confirmPassword": data["confirmPassword"],
        }),
      );

      // print(response.body);

      return UserModel.fromJson(response.body);
    } catch (err) {
      print(err);
    }
  }

  Future<UserModel?> logout({id, oneSignalUserId}) async {
    try {
      final uri = Uri.https(baseUrl, "/user/logout/$id");
      // final uri = Uri.http(baseUrl, "/user/logout/$id");
      final response = await http.patch(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
        body:
            json.encode(<String, dynamic>{"oneSignalUserId": oneSignalUserId}),
      );

      print(response.body);

      // return UserModel.fromJson(response.body);
    } catch (err) {
      print(err);
    }
  }

  Future<UserModel?> uploadImage(image, id) async {
    try {
      final uri = Uri.https(baseUrl, "/user/image/$id");

      print("user image uploading...");
      // final uri = Uri.http(baseUrl, "/user/image/$id");
      var res = http.MultipartRequest(
        "PATCH",
        uri,
      );

      res.files.add(await http.MultipartFile.fromPath("image", image.path));
      res.headers.addAll({"Content-Type": "multipart/form-data"});

      http.Response response = await http.Response.fromStream(await res.send());
      inspect(response);

      // print(response.body);

      return UserModel.fromJson(response.body);
    } catch (err) {
      inspect(err);
    }
  }

  Future<UserModel?> addUser(
      {userId, friend, userImageUrl, activityName, activityUserId}) async {
    try {
      final uri = Uri.https(baseUrl, "/user/addUser/$userId");
      // final uri = Uri.http(baseUrl, "/user/addUser/$userId");
      final response = await http.patch(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
        body: json.encode(<String, dynamic>{
          "friend": friend,
          "userImageUrl": userImageUrl,
          "creatorId": activityUserId,
          "activityName": activityName,
        }),
      );

      inspect(response.body);

      return UserModel.fromJson(response.body);
    } catch (err) {
      inspect(err);
    }
  }

  Future<UserModel?> editUser(id, name, about) async {
    try {
      final uri = Uri.https(baseUrl, "/user/editProfile/$id");
      // final uri = Uri.http(baseUrl, "/user/editProfile/$id");
      final response = await http.patch(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
        body: json.encode(<String, dynamic>{
          "name": name,
          "about": about,
        }),
      );

      debugPrint(response.body);

      return UserModel.fromJson(response.body);
    } catch (err) {
      inspect(err);
    }
  }

  Future<UserModel?> getUserById(id) async {
    try {
      final uri = Uri.https(baseUrl, "/user/getUser/$id");
      // final uri = Uri.http(baseUrl, "/user/getUser/$id");
      final response = await http.get(
        uri,
      );
      // debugPrint(response.body);

      return UserModel.fromJson(response.body);
    } catch (err) {
      inspect(err);
    }
  }

  Future<List<ChatModel>?> getUserFriends(id) async {
    try {
      log("user id getUserFriends: $id");
      final uri = Uri.https(
      baseUrl, "/user/getUserFriends/$id");
      // final uri = Uri.http(baseUrl, "/user/getUserFriends/$id");
      final response = await http.get(
        uri,
      );
      // log(response.body);
      final Map user = json.decode(response.body);

      return (user["users"] as List)
          .map((user) => ChatModel.fromMap(user))
          .toList();
    } catch (err) {
      inspect(err);
      print("hahha");
    }
  }

  Future<List<ChatModel>?> getAllUsers() async {
    try {
      final uri = Uri.https(baseUrl, "/user/getUsers");
      // final uri = Uri.http(baseUrl, "/user/getUsers");
      final response = await http.get(
        uri,
      );

      // print(response.body);
      final Map user = json.decode(response.body);

      // ignore: avoid_print
      // print(chatList.length);
      return (user["users"] as List)
          .map((user) => ChatModel.fromMap(user))
          .toList();
    } catch (err) {
      inspect(err);
    }
  }
}
