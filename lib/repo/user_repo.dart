// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/development/console.dart';
import 'package:moment/models/message_model/message_model.dart';
import 'package:moment/models/user_model/individual_user_model.dart';
import 'package:moment/models/user_model/users_model.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/services/base_client.dart';
import 'package:moment/services/one_signal_services.dart';
import 'package:moment/widgets/custom_dialog_widget.dart';

class UserRepo {
  login({required Map<String, dynamic> data, required BuildContext ctx}) async {
    try {
      var deviceId = await OneSignalNotificationService.getDeviceId();
      Map body = {
        "email": data["email"],
        "password": data["password"],
        "oneSignalUserId": deviceId,
      };

      final response = await BaseClient().post(
          ApiConfig.userBaseUrl, "/user/login", body,
          isTokenHeader: false);
      return individualUserModelFromJson(response);
    } catch (err) {
      consolelog("Login Error: $err");
      RouteNavigation.back(ctx);
      CustomDialogs.showCustomActionDialog(ctx: ctx, message: err.toString());
      rethrow;
    }
  }

  register({required Map data, required BuildContext ctx}) async {
    try {
      Map body = {
        "firstName": data["firstName"],
        "lastName": data["lastName"],
        "email": data["email"],
        "password": data["password"],
        "confirmPassword": data["confirmPassword"],
      };

      final response = await BaseClient().post(
          ApiConfig.userBaseUrl, "/user/signup", body,
          isTokenHeader: false);
      return individualUserModelFromJson(response);
    } catch (err) {
      RouteNavigation.back(ctx);
      consolelog("Register Error: $err");
      CustomDialogs.showCustomActionDialog(ctx: ctx, message: err.toString());
      rethrow;
    }
  }

  logout({id, oneSignalUserId, required BuildContext ctx}) async {
    try {
      Map body = {"oneSignalUserId": oneSignalUserId};
      await BaseClient().patch(ApiConfig.userBaseUrl, "/user/logout/$id", body,
          isTokenHeader: false);
    } catch (err) {
      RouteNavigation.back(ctx);
      consolelog("Logout Error: $err");
      // CustomDialogs.showCustomActionDialog(ctx: ctx, message: err.toString());
      rethrow;
    }
  }

  uploadImage(image, id) async {
    try {
      final response = await BaseClient().postWithImage(
        ApiConfig.userBaseUrl,
        "/user/image/$id",
        isBody: false,
        file: image,
        imageKey: "image",
        method: "PATCH",
      );
      return individualUserModelFromJson(response);
    } catch (err) {
      consolelog("ERROR: $err");
      rethrow;
    }
  }

  uploadMsgImage(image, id, text) async {
    try {
      final response = await BaseClient().postWithImage(
        ApiConfig.userBaseUrl,
        "/user/msgImage/$id",
        payloadObj: {"text": text},
        file: image,
        imageKey: "image",
        method: "PATCH",
      );
      // consolelog(response);
      return messageModelFromJson(response);
    } catch (err) {
      consolelog("ERROR: $err");
      rethrow;
    }
  }

  addUser({userId, friend, userImageUrl, activityName, activityUserId}) async {
    try {
      Map body = {
        "friend": friend,
        "userImageUrl": userImageUrl,
        "creatorId": activityUserId,
        "activityName": activityName,
      };
      final response = await BaseClient().patch(
        ApiConfig.userBaseUrl,
        "/user/addUser/$userId",
        body,
      );
      // consoleinspect(response);
      return individualUserModelFromJson(response);
    } catch (err) {
      consolelog("ERROR: $err");
      rethrow;
    }
  }

  editUser(id, name, about) async {
    try {
      // final uri = Uri.https(ApiConfig.userBaseUrl, "/user/editProfile/$id");
      final uri = Uri.http(ApiConfig.userBaseUrl, "/user/editProfile/$id");
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
    } catch (err) {
      inspect(err);
    }
  }

  getUserById({String? id, required BuildContext ctx}) async {
    try {
      var response =
          await BaseClient().get(ApiConfig.userBaseUrl, "/user/getUser/$id");
      return individualUserModelFromJson(response);
    } catch (err) {
      consolelog("GetUserFriends Error: $err");
      // CustomDialogs.showCustomActionDialog(ctx: ctx, message: err.toString());
      rethrow;
    }
  }

  getUserFriends({String? id, required BuildContext ctx}) async {
    try {
      var response = await BaseClient()
          .get(ApiConfig.userBaseUrl, "/user/getUserFriends/$id");
      var userModel = userModelFromJson(response);
      return userModel;
    } catch (err) {
      consolelog("GetUserFriends Error: $err");
      // CustomDialogs.showCustomActionDialog(ctx: ctx, message: err.toString());
      rethrow;
    }
  }

  getAllUsers({required BuildContext ctx}) async {
    try {
      var response =
          await BaseClient().get(ApiConfig.userBaseUrl, "/user/getUsers");
      var userModel = userModelFromJson(response);
      return userModel;
    } catch (err) {
      consolelog("GetAllUser Error: $err");
      // CustomDialogs.showCustomActionDialog(ctx: ctx, message: err.toString());
      rethrow;
    }
  }
}
