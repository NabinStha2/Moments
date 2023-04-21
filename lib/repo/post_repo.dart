import 'dart:developer';
import 'package:moment/development/console.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/services/base_client.dart';

class PostRepo {
  getPosts({page}) async {
    try {
      var response = await BaseClient().get(
          ApiConfig.userBaseUrl, "/posts?page=$page",
          isTokenHeader: false);
      consolelog(response.toString());
      return postModelFromJson(response);
    } catch (err) {
      rethrow;
    }
  }

  getAllPosts() async {
    try {
      var response = await BaseClient()
          .get(ApiConfig.userBaseUrl, "/posts/all", isTokenHeader: false);
      return postModelFromJson(response);
    } catch (err) {
      // consolelog(err.toString());
      rethrow;
    }
  }

  getSinglePost({id}) async {
    try {
      var response = await BaseClient().get(
          ApiConfig.userBaseUrl, "/posts/singlePost/$id",
          isTokenHeader: false);
      // consolelog(response);
      return postModelFromJson(response);
    } catch (err) {
      consolelog("Error: ${err.toString()}");
      rethrow;
    }
  }

  likePost(
      {id,
      token,
      userImageUrl,
      userId,
      creatorId,
      activityName,
      postUrl,
      reactionType}) async {
    try {
      Map body = {
        "userId": userId,
        "userImageUrl": userImageUrl,
        "creatorId": creatorId,
        "activityName": activityName,
        "postUrl": postUrl,
        "reactionType": reactionType,
      };
      var response = await BaseClient()
          .patch(ApiConfig.userBaseUrl, "/posts/like/$id", body);
      return postModelFromJson(response);
    } catch (err) {
      log("$err");
      rethrow;
    }
  }

  deletePost(id, token) async {
    try {
      var response =
          await BaseClient().delete(ApiConfig.userBaseUrl, "/posts/$id");
      return postModelFromJson(response);
    } catch (err) {
      // consolelog("$err");
      rethrow;
    }
  }

  commentPost(
      {postId,
      token,
      value,
      userImageUrl,
      userId,
      creatorId,
      activityName,
      postUrl,
      isReply,
      commentId,
      replyToUserId}) async {
    try {
      Map body = {
        "value": value,
        "userId": userId,
        "userImageUrl": userImageUrl,
        "creatorId": creatorId,
        "activityName": activityName,
        "postUrl": postUrl,
        "isReply": isReply,
        "commentId": commentId,
        "replyToUserId": replyToUserId,
      };
      var response = await BaseClient()
          .patch(ApiConfig.userBaseUrl, "/posts/$postId/commentPost", body);
      return postModelFromJson(response);
    } catch (err) {
      // consolelog("$err");
      rethrow;
    }
  }

  createPost(value, token, {bool isImage = true}) async {
    try {
      Map<String, String> body = {
        "name": value["name"],
        "description": value["description"],
      };
      var response = await BaseClient().postWithImage(
        ApiConfig.userBaseUrl,
        "/posts",
        payloadObj: body,
        isImage: isImage,
        file: value["selectedFile"],
        imageKey: "image",
      );
      return postModelFromJson(response);
    } catch (err) {
      consolelog("createPost: $err");
      rethrow;
    }
  }

  updatePost(id, value, token, {bool isImage = true}) async {
    try {
      Map<String, String> body = {
        "description": value["description"],
      };
      var response = await BaseClient().postWithImage(
        ApiConfig.userBaseUrl,
        "/posts/$id",
        payloadObj: body,
        method: "PATCH",
        isImage: isImage,
        file: value["selectedFile"],
        imageKey: "image",
      );
      return postModelFromJson(response);
    } catch (err) {
      // consolelog("updatePost: $err");
      rethrow;
    }
  }

  creatorPosts(creatorId) async {
    try {
      var response = await BaseClient().get(
          ApiConfig.userBaseUrl, "/posts/creators/$creatorId",
          isTokenHeader: false);
      return postModelFromJson(response);
    } catch (err) {
      // consolelog("creatorPosts: $err");
      rethrow;
    }
  }

  deleteComment({commentId, postId, activityId, token}) async {
    try {
      Map body = {
        "commentId": commentId,
        "activityId": activityId,
      };
      var response = await BaseClient()
          .patch(ApiConfig.userBaseUrl, "/posts/deleteComment/$postId", body);
      return postModelFromJson(response);
    } catch (err) {
      // consolelog("creatorPosts: $err");
      rethrow;
    }
  }
}
