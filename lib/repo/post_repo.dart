import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import "package:http/http.dart" as http;
import 'package:moment/models/post_model.dart';

class PostRepo {
  final String baseUrl = "momentsapps.herokuapp.com";
  // final String baseUrl = "192.168.1.78:3000";

  Future<PostResponse?> getPosts({page}) async {
    final queryParameters = {
      "page": "$page",
    };
    try {
      final uri = Uri.https(baseUrl, "/posts", queryParameters);
      // final uri = Uri.http(baseUrl, "/posts", queryParameters);
      final response = await http.get(uri);

      // final response = await Dio().get(
      //   // "https://momentsapps.herokuapp.com/posts",
      //   "http://192.168.1.19:3000/posts",
      //   queryParameters: queryParameters,
      // );

      // log(response.data);

      return PostResponse.fromJson(response.body);
      // return PostResponse.fromMap(response.data);
    } catch (err) {
      log(err.toString());
      // return err;
    }
    return null;
  }

  Future<PostResponse?> getAllPosts() async {
    try {
      final uri = Uri.https(baseUrl, "/posts/all");
      // final uri = Uri.http(baseUrl, "/posts/all");
      final response = await http.get(uri);

      // final response = await Dio().get(
      //   // "https://momentsapps.herokuapp.com/posts",
      //   "http://192.168.1.19:3000/posts/all",
      // );

      // log(response.data);

      return PostResponse.fromJson(response.body);
      // return PostResponse.fromMap(response.data);
    } catch (err) {
      log(err.toString());
      // return err;
    }
    return null;
  }

  Future<SinglePostModel?> getSinglePost({id}) async {
    try {
      final uri = Uri.https(baseUrl, "/posts/singlePost/$id");
      // final uri = Uri.http(baseUrl, "/posts/singlePost/$id");
      final response = await http.get(uri);

      // final response = await Dio().get(
      //   // "https://momentsapps.herokuapp.com/posts",
      //   "http://192.168.1.19:3000/posts/singlePost/$id",
      // );

      // log(response.body);

      return SinglePostModel.fromJson(response.body);
    } catch (err) {
      log("Error: ${err.toString()}");
      // return err;
    }
    return null;
  }

  Future<PostModel?> likePost({
    id,
    token,
    userImageUrl,
    userId,
    creatorId,
    activityName,
    postUrl,
    reactionType,
  }) async {
    try {
      final uri = Uri.https(baseUrl, "/posts/like/$id");
      // final uri = Uri.http(baseUrl, "/posts/like/$id");
      final response = await http.patch(uri,
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
          },
          body: json.encode(<String, dynamic>{
            "userId": userId,
            "userImageUrl": userImageUrl,
            "creatorId": creatorId,
            "activityName": activityName,
            "postUrl": postUrl,
            "reactionType": reactionType,
          }));
      // log(response.body);

      // final response = await Dio().patch(
      //   // "https://momentsapps.herokuapp.com/posts/like/$id",
      //   "http://192.168.1.19:3000/posts/like/$id",
      //   options: Options(
      //     headers: {
      //       HttpHeaders.authorizationHeader: "Bearer $token",
      //       HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
      //     },
      //   ),
      // );

      return PostModel.fromJson(response.body);
      // return PostModel.fromMap(response.data);
    } catch (err) {
      log("$err");
      // return err;
    }
    return null;
  }

  Future<PostModel?> deletePost(id, token) async {
    try {
      final uri = Uri.https(baseUrl, "/posts/$id");
      // final uri = Uri.http(baseUrl, "/posts/$id");
      final response = await http.delete(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
      );
      // log(response.body);
      return PostModel.fromJson(response.body);
    } catch (err) {
      log("$err");
      // return err;
    }
    return null;
  }

  Future<SinglePostModel?> commentPost(
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
      final uri = Uri.https(baseUrl, "/posts/$postId/commentPost");
      // final uri = Uri.http(baseUrl, "/posts/$postId/commentPost");
      final response = await http.patch(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
        body: json.encode(<String, dynamic>{
          "value": value,
          "userId": userId,
          "userImageUrl": userImageUrl,
          "creatorId": creatorId,
          "activityName": activityName,
          "postUrl": postUrl,
          "isReply": isReply,
          "commentId": commentId,
          "replyToUserId": replyToUserId,
        }),
      );
      // log(response.body);
      return SinglePostModel.fromJson(response.body);
    } catch (err) {
      log("$err");
      // return err;
    }
    return null;
  }

  Future<PostModel?> createPost(value, token) async {
    try {
      final uri = Uri.https(baseUrl, "/posts");
      // inspect("repo: " + value);
      // final uri = Uri.http(baseUrl, "/posts");
      // log(value["tags"].toString().split(" "));
      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
        body: json.encode(<String, dynamic>{
          // "title": value["title"],
          "name": value["name"],
          "description": value["description"],
          // "tags": value["tags"].toString().split(" "),
        }),
      );
      // log(json.decode(response.body));
      var data = json.decode(response.body);
      // log(data["_id"]);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("post image uploading...");
        final uri = Uri.parse(
            "https://momentsapps.herokuapp.com/posts/uploadImage/${data["_id"]}");
        // final uri = Uri.parse(
        // "http://192.168.1.78:3000/posts/uploadImage/${data["_id"]}");
        var res = http.MultipartRequest(
          "PATCH",
          uri,
        );

        res.files.add(await http.MultipartFile.fromPath(
            "image", value["selectedFile"].path));
        res.headers.addAll({
          "Content-Type": "multipart/form-data",
          "Authorization": "Bearer $token",
        });

        http.Response resData =
            await http.Response.fromStream(await res.send());
        // inspect(resData);
        if (resData.statusCode == 200 || resData.statusCode == 201) {
          return PostModel.fromJson(response.body);
        }
      }
    } catch (err) {
      log("createPost: $err");
      // return err;
    }
    return null;
  }

  Future<PostModel?> updatePost(id, value, token) async {
    try {
      // inspect(value);

      final uri = Uri.https(baseUrl, "/posts/$id");
      // final uri = Uri.http(baseUrl, "/posts/$id");
      final response = await http.patch(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
        body: json.encode(<String, dynamic>{
          // "title": value["title"],
          "description": value["description"],
          // "tags": value["tags"].toString().split(" "),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("updated post image uploading...");
        final uri = Uri.https(baseUrl, "/posts/uploadImage/$id");
        // final uri = Uri.http(baseUrl, "/posts/uploadImage/$id");
        var res = http.MultipartRequest(
          "PATCH",
          uri,
        );

        res.files.add(await http.MultipartFile.fromPath(
            "image", value["selectedFile"].path));
        res.headers.addAll({
          "Content-Type": "multipart/form-data",
          "Authorization": "Bearer $token",
        });

        http.Response resData =
            await http.Response.fromStream(await res.send());
        // inspect(resData);

        // log(value["tags"].toString().split(" "));
        if (resData.statusCode == 200 || resData.statusCode == 201) {
          return PostModel.fromJson(response.body);
        }
      }
    } catch (err) {
      log("updatePost: $err");
      // return err;
    }
    return null;
  }

  Future<PostResponse?> creatorPosts(creatorId) async {
    try {
      final uri = Uri.https(baseUrl, "/posts/creators/$creatorId");
      // final uri = Uri.http(baseUrl, "/posts/creators/$creatorId");
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
      );

      // final response = await Dio().get(
      // "https://momentsapps.herokuapp.com/posts/creators/$creatorId",
      //   "http://192.168.1.78:3000/posts/creators/$creatorId",
      //   options: Options(
      //     headers: {
      //       HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
      //     },
      //   ),
      // );PostResponse

      // log(response.body);
      return PostResponse.fromJson(response.body);
      // return PostResponse.fromMap(response.data);
    } catch (err) {
      log("creatorPosts: $err");
      // return err;
    }
    return null;
  }

  Future<SinglePostModel?> deleteComment(
      {commentId, postId, activityId, token}) async {
    try {
      final uri = Uri.https(baseUrl, "/posts/deleteComment/$postId");
      // final uri = Uri.http(baseUrl, "/posts/deleteComment/$postId");
      final response = await http.patch(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
        },
        body: json.encode(<String, dynamic>{
          "commentId": commentId,
          "activityId": activityId,
        }),
      );

      log(response.body);
      return SinglePostModel.fromJson(response.body);
    } catch (err) {
      log("creatorPosts: $err");
      // return err;
    }
    return null;
  }
}
