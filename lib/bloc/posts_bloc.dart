import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moment/main.dart';
import 'package:moment/models/post_model.dart';
import 'package:moment/repo/post_repo.dart';
import "package:http/http.dart" as http;
import 'package:moment/screens/home_screen.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc() : super(PostsInitial());

  final PostRepo _postRepo = PostRepo();
  final List<PostModel>? postModels = <PostModel>[];
  final List<PostModel>? allPostModels = <PostModel>[];
  int? pages = 0;

  @override
  Stream<PostsState> mapEventToState(
    PostsEvent event,
  ) async* {
    if (event is GetPostsEvent) {
      yield PostLoading();
      try {
        print("page : ${event.page}");
        // if (postModels!.isNotEmpty) {
        //   postModels!.clear();
        // }
        if (allPostModels!.isNotEmpty) {
          allPostModels!.clear();
        }

        final posts = await _postRepo.getPosts(page: event.page);
        final allPosts = await _postRepo.getAllPosts();

        if (posts != null && allPosts != null) {
          log("wow");
          if (posts.postModel.isNotEmpty && allPosts.postModel.isNotEmpty) {
            log("wow");
            postModels?.addAll(posts.postModel);
            allPostModels?.addAll(allPosts.postModel);
            pages = posts.pages;
          }

          // if (posts.postModel[0].errMessage != "") {
          //   yield PostError(error: posts.postModel[0].errMessage);
          // } else {
          yield GetPostLoaded(
            postModel: postModels,
            allPostModel: allPostModels,
            pages: posts.pages,
          );
          // }
        }
      } catch (e) {
        print("Error ---- $e");
        // "Server has been down recently"
        yield const PostError(error: "Server has been down recently");
      }
    } else if (event is GetSinglePostEvent) {
      yield PostLoading();

      try {
        final post = await _postRepo.getSinglePost(id: event.id);

        if (post != null) {
          if (post.postModel.errMessage != "") {
            yield PostError(error: post.postModel.errMessage);
          } else {
            yield GetSinglePostLoaded(
              postModel: post.postModel,
            );
          }
        }
      } catch (e) {
        print("Error from GetSinglePostEvent ---- $e");
        // "Server has been down recently"
        yield PostError(error: "Server has been down recently");
      }
    } else if (event is RefreshPostsEvent) {
      postModels!.clear();
    } else if (event is LikePostEvent) {
      try {
        final post = await _postRepo.likePost(
          id: event.id,
          token: event.token,
          userId: event.userId,
          creatorId: event.creatorId,
          activityName: event.activityName,
          postUrl: event.postUrl,
          userImageUrl: event.userImageUrl,
          reactionType: event.reactionType,
        );
        // print(post?.likes);

        print(postModels?.length);

        if (post != null) {
          postModels![postModels!
              .indexWhere((element) => element.id == post.id)] = post;
          // print(postModels![
          //         postModels!.indexWhere((element) => element.id == post.id)]
          //     .likes);
          if (post.errMessage != "") {
            yield PostError(error: post.errMessage);
          } else {
            yield PostLiked();
            if (event.postDetails) {
              yield GetSinglePostLoaded(
                postModel: post,
              );
            } else {
              yield GetPostLoaded(postModel: postModels);
            }
          }
        }
      } catch (err) {
        print(err);
        yield PostError(error: "Server has been down recently");
      }
    } else if (event is DeletePostEvent) {
      try {
        yield PostDeleteLoading();

        final deletedPost = await _postRepo.deletePost(event.id, event.token);

        postModels?.removeAt(
            postModels!.indexWhere((element) => element.id == deletedPost!.id));
        if (deletedPost!.errMessage != "") {
          yield PostError(error: deletedPost.errMessage);
        } else {
          yield PostDeleted();
          yield GetPostLoaded(postModel: postModels);
        }
      } catch (e) {
        print("Error ---- $e");
        yield PostError(error: "Server has been down recently");
      }
    } else if (event is CommentPostEvent) {
      try {
        // isLoading = true;
        final post = await _postRepo.commentPost(
          postId: event.id,
          value: event.value,
          token: event.token,
          userId: event.userId,
          creatorId: event.creatorId,
          activityName: event.activityName,
          postUrl: event.postUrl,
          userImageUrl: event.userImageUrl,
          isReply: event.isReply,
          commentId: event.commentId,
          replyToUserId: event.replyToUserId,
        );

        // print(post?.comments);

        if (post != null) {
          // print(postModels!
          //     .indexWhere((element) => element.id == post.postModel.id));
          // postModels![postModels!
          //         .indexWhere((element) => element.id == post.postModel.id)] =
          //     post.postModel;
          if (post.postModel.errMessage != "") {
            yield PostError(error: post.postModel.errMessage);
          } else {
            yield CommentLoaded();
            yield GetSinglePostLoaded(
              postModel: post.postModel,
            );
          }
        }
      } catch (err) {
        print("Error ---- $err");
        yield PostError(error: "Server has been down recently");
      }
    } else if (event is DeleteCommentEvent) {
      try {
        final post = await _postRepo.deleteComment(
          postId: event.postId,
          token: event.token,
          commentId: event.commentId,
          activityId: event.activityId,
        );

        if (post != null) {
          if (post.postModel.errMessage != "") {
            yield PostError(error: post.postModel.errMessage);
          } else {
            yield GetSinglePostLoaded(
              postModel: post.postModel,
            );
          }
        }
      } catch (err) {
        print("Error ---- $err");
        yield PostError(error: "Server has been down recently");
      }
    } else if (event is CreatePostEvent) {
      yield PostLoading();
      try {
        // inspect(event.data);
        final post = await _postRepo.createPost(event.data, event.token);

        // print(post);

        if (post!.errMessage != "") {
          yield PostError(error: post.errMessage);
        } else {
          // final uri = Uri.https(
          //     baseUrl, "/api/SendNotification");
          final uri = Uri.http(baseUrl, "/api/SendNotification");
          final response = await http.post(
            uri,
            headers: {
              HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
            },
            body: json.encode(<String, dynamic>{
              "headings": "Moments",
              "msg": "${authStorageValues!["name"]} added a post.",
            }),
          );
          inspect(response);
          yield PostCreated();
          // yield GetPostLoaded(postModel: postModels);
        }
      } catch (err) {
        print("Error ---- $err");
        yield PostError(error: "Server has been down recently");
      }
    } else if (event is UpdatePostEvent) {
      yield PostUpdateLoading();
      try {
        // print(event);
        final post =
            await _postRepo.updatePost(event.id, event.data, event.token);

        // print(post);

        if (post != null) {
          // inspect(postModels![
          //         postModels!.indexWhere((element) => element.id == post.id)]
          //     .imageUrl);
          postModels![postModels!
              .indexWhere((element) => element.id == post.id)] = post;
          // inspect(postModels![
          //         postModels!.indexWhere((element) => element.id == post.id)]
          //     .imageUrl);
          if (post.errMessage != "") {
            yield PostError(error: post.errMessage);
          } else {
            yield PostUpdated();
            yield GetPostLoaded(postModel: postModels);
          }
        }
      } catch (err) {
        print("Error ---- -- -- $err");
        yield PostError(error: "Server has been down recently");
      }
    } else if (event is GetCreatorPostsEvent) {
      yield PostLoading();
      try {
        final post = await _postRepo.creatorPosts(event.creator);

        if (post != null) {
          // inspect(post.postModel);
          log("get creator post");
          // if (post.postModel[0].errMessage != "") {
          //   yield PostError(error: post.postModel[0].errMessage);
          // } else {
          yield CreatorPostsLoaded(postModel: post.postModel);
          // }
        }
      } catch (err) {
        print("Error ---- -- -- $err");
        yield CreatorPostError();
      }
    }
  }
}
