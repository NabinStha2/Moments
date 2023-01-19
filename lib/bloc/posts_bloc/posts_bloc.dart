// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import "package:http/http.dart" as http;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/development/console.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/repo/post_repo.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_dialog_widget.dart';

import '../activity_bloc/activity_bloc.dart';
import '../profile_posts_bloc/profile_posts_bloc.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostRepo _postRepo = PostRepo();
  final List<PostModelData> postModels = <PostModelData>[];
  final List<PostModelData> allPostModels = <PostModelData>[];
  PostModelData? singlePostData;
  int pages = 0;
  int currentPage = 1;
  bool showCommentDelete = false;
  bool showFileDownload = false;
  bool showReplyComment = false;
  int? deleteIndex;
  String? deleteCommentId;
  List<String>? deleteCommentActivityId;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController updateDescriptionController =
      TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  File? postSelectedFile;
  File? updatePostSelectedFile;

  PostsBloc() : super(PostsInitial()) {
    on<PostFileSelectedEvent>((event, emit) async {
      emit(PostFileSelectingLoadingState());
      event.isUpdate == true
          ? updatePostSelectedFile = event.selectedFile
          : postSelectedFile = event.selectedFile;
      emit(PostFileSelectedState());
    });
    on<ShowCommentDeleteEvent>((event, emit) async {
      showCommentDelete = true;
      deleteCommentId = event.cmt?.commentId;
      deleteCommentActivityId = event.cmt?.activityId;
      deleteIndex = event.index;
      emit(ShowCommentDeleteState());
    });
    on<HideCommentDeleteEvent>((event, emit) async {
      showCommentDelete = false;
      deleteCommentId = null;
      deleteCommentActivityId = null;
      deleteIndex = null;
      emit(HideCommentDeleteState());
    });
    on<ShowFileDownloadLoadingEvent>((event, emit) async {
      showFileDownload = true;
      emit(ShowFileDownloadState());
    });
    on<HideFileDownloadLoadingEvent>((event, emit) async {
      showFileDownload = false;
      emit(HideFileDownloadState());
    });
    on<ShowReplyCommentEvent>((event, emit) async {
      showReplyComment = true;
      emit(ShowReplyCommentState(
        commentId: event.commentId,
        replyTo: event.replyTo,
        replyToUserId: event.replyToUserId,
      ));
    });
    on<HideReplyCommentEvent>((event, emit) async {
      showReplyComment = false;
      emit(HideReplyCommentState());
    });
    on<PostPageChangeEvent>((event, emit) async {
      emit(PostPageChangedLoadingState());
      // consolelog("event: ${event.pageNumber}");
      currentPage = event.pageNumber ?? 1;
      // consolelog("currentPage: $currentPage");
      emit(PostPageChangedLoadedState());
    });
    on<PostClearValueEvent>((event, emit) async {
      emit(PostLoading());
      descriptionController.clear();
      updateDescriptionController.clear();
      commentController.clear();
      postSelectedFile = null;
      updatePostSelectedFile = null;
      emit(PostClearValueState());
    });
    on<GetPostsEvent>((event, emit) async {
      await _getPosts(event, emit);
    });
    on<GetSinglePostEvent>((event, emit) async {
      await _getSinglePost(event, emit);
    });
    on<RefreshPostsEvent>((event, emit) {
      _refreshPosts();
    });
    on<LikePostEvent>((event, emit) async {
      await _likePost(event, emit);
    });
    on<DeletePostEvent>((event, emit) async {
      await _deletePost(event, emit);
    });
    on<CommentPostEvent>((event, emit) async {
      await _commentPost(event, emit);
    });
    on<DeleteCommentEvent>((event, emit) async {
      await _deletePostComment(event, emit);
    });
    on<CreatePostEvent>((event, emit) async {
      await _createPost(event, emit);
    });
    on<UpdatePostEvent>((event, emit) async {
      await _updatePost(event, emit);
    });
  }

  Future<void> _getPosts(GetPostsEvent event, Emitter<PostsState> emit) async {
    emit(PostLoading());
    try {
      if (allPostModels.isNotEmpty) {
        allPostModels.clear();
      }
      final PostModel posts = await _postRepo.getPosts(page: event.page);
      final PostModel allPosts = await _postRepo.getAllPosts();

      if (posts.message == "Success" &&
          posts.data?.isNotEmpty == true &&
          allPosts.data?.isNotEmpty == true) {
        postModels.addAll(posts.data ?? []);
        allPostModels.addAll(allPosts.data ?? []);
        pages = posts.pages ?? 0;
      }
      emit(GetPostLoaded(
        postModel: postModels,
        allPostModel: allPostModels,
        pages: posts.pages,
      ));
    } catch (e) {
      log("Error ---- $e.toString()");
      emit(GetAllPostFailure(error: e.toString()));
    }
  }

  Future _getSinglePost(
      GetSinglePostEvent event, Emitter<PostsState> emit) async {
    emit(PostLoading());
    try {
      final PostModel post = await _postRepo.getSinglePost(id: event.id);
      if (post.message == "Success" && post.data?.isNotEmpty == true) {
        singlePostData = post.data?[0];
        emit(GetSinglePostLoaded(
          postModel: post.data?[0],
        ));
      }
    } catch (e) {
      print("Error from GetSinglePostEvent ---- $e");
      emit(GetSinglePostFailure(error: e.toString()));
    }
  }

  void _refreshPosts() {
    postModels.clear();
  }

  Future _likePost(LikePostEvent event, Emitter<PostsState> emit) async {
    try {
      final PostModel post = await _postRepo.likePost(
        id: event.id,
        token: event.token,
        userId: event.userId,
        creatorId: event.creatorId,
        activityName: event.activityName,
        postUrl: event.postUrl,
        userImageUrl: event.userImageUrl,
        reactionType: event.reactionType,
      );
      if (post.message == "Success") {
        postModels[postModels
                .indexWhere((element) => element.id == post.data?[0].id)] =
            post.data?[0] as PostModelData;
        emit(PostLiked());
        if (event.postDetails) {
          emit(GetSinglePostLoaded(
            postModel: post.data?[0],
          ));
        } else {
          emit(GetPostLoaded(postModel: postModels));
        }
      }
    } catch (err) {
      print(err);
      emit(PostLikedFailure(error: err.toString()));
    }
  }

  Future _deletePost(DeletePostEvent event, Emitter<PostsState> emit) async {
    try {
      emit(PostDeleteLoading());
      CustomDialogs.showCustomFullLoadingDialog(
          ctx: event.context, title: "Deleting...");
      final PostModel deletedPost =
          await _postRepo.deletePost(event.id, event.token);
      if (deletedPost.message == "Success" &&
          deletedPost.data?.isNotEmpty == true) {
        postModels.removeAt(postModels
            .indexWhere((element) => element.id == deletedPost.data?[0].id));
        emit(PostDeleted());
        emit(GetPostLoaded(
          postModel: postModels,
          allPostModel: allPostModels,
          pages: 1,
        ));
        if (event.isFromVisit) {
          BlocProvider.of<ProfilePostsBloc>(event.context).add(
            GetProfilePostsEvent(
              context: event.context,
              creator: event.isFromVisitUserId ?? "",
            ),
          );
        } else if (event.isFromProfile) {
          BlocProvider.of<ProfilePostsBloc>(event.context).add(
            GetProfilePostsEvent(
              context: event.context,
              creator: StorageServices.authStorageValues["id"] ?? "",
            ),
          );
          RouteNavigation.back(event.context);
        } else if (event.isFromActivity) {
          BlocProvider.of<ActivityBloc>(event.context).add(
              GetActivity(id: StorageServices.authStorageValues["id"] ?? ""));
        } else {
          // BlocProvider.of<PostsBloc>(event.context).add(RefreshPostsEvent());
          // BlocProvider.of<PostsBloc>(event.context).add(GetPostsEvent(
          //   context: event.context,
          // ));
        }
      }
      RouteNavigation.back(event.context);
    } catch (e) {
      RouteNavigation.back(event.context);
      print("Error ---- $e");
      emit(PostDeleteFailure(error: e.toString()));
    }
  }

  Future _commentPost(CommentPostEvent event, Emitter<PostsState> emit) async {
    try {
      final PostModel post = await _postRepo.commentPost(
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
      if (post.message == "Success" && post.data?.isNotEmpty == true) {
        emit(CommentLoaded());
        inspect(post.data?[0]);
        singlePostData = post.data?[0];
        emit(GetSinglePostLoaded(
          postModel: post.data?[0],
        ));
      }
    } catch (err) {
      print("Error ---- $err");
      emit(PostCommentFailure(error: err.toString()));
    }
  }

  Future _deletePostComment(
      DeleteCommentEvent event, Emitter<PostsState> emit) async {
    try {
      final PostModel post = await _postRepo.deleteComment(
        postId: event.postId,
        token: event.token,
        commentId: event.commentId,
        activityId: event.activityId,
      );

      if (post.message == "Success" && post.data?.isNotEmpty == true) {
        singlePostData = post.data?[0];
        emit(GetSinglePostLoaded(
          postModel: post.data?[0],
        ));
      }
    } catch (err) {
      print("Error ---- $err");
      emit(PostDeleteCommentFailure(error: err.toString()));
    }
  }

  Future _createPost(CreatePostEvent event, Emitter<PostsState> emit) async {
    emit(PostLoading());
    CustomDialogs.showCustomFullLoadingDialog(
        ctx: event.context, title: "Uploading...");
    try {
      final PostModel post = await _postRepo.createPost(event.data, event.token,
          isImage: event.isImage);
      if (post.message == "Success" && post.data?.isNotEmpty == true) {
        final uri = Uri.http(ApiConfig.baseUrl, "/api/SendNotification");
        await http.post(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
          },
          body: json.encode(<String, dynamic>{
            "headings": "Moments",
            "msg": "${StorageServices.authStorageValues["name"]} added a post.",
          }),
        );
        emit(PostCreated());
      }
      RouteNavigation.back(event.context);
    } catch (err) {
      RouteNavigation.back(event.context);
      consolelog(err);
      emit(PostCreatedFailure(error: err.toString()));
    }
  }

  Future _updatePost(
    UpdatePostEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(PostUpdateLoading());
    CustomDialogs.showCustomFullLoadingDialog(
        ctx: event.context, title: "Uploading...");
    try {
      final PostModel post = await _postRepo.updatePost(
          event.id, event.data, event.token,
          isImage: event.isImage);
      if (post.data != null && post.message == "Success") {
        postModels[postModels
                .indexWhere((element) => element.id == post.data?[0].id)] =
            post.data?[0] ?? PostModelData();
        emit(PostUpdated());
        emit(GetPostLoaded(
          postModel: postModels,
          allPostModel: allPostModels,
        ));
        // BlocProvider.of<PostsBloc>(event.context).add(RefreshPostsEvent());
        // BlocProvider.of<PostsBloc>(event.context).add(GetPostsEvent(context: event.context));
        BlocProvider.of<PostsBloc>(event.context).add(GetSinglePostEvent(
          context: event.context,
          id: post.data?[0].id ?? "",
        ));
        RouteNavigation.back(event.context);
      }
      RouteNavigation.back(event.context);
    } catch (err) {
      RouteNavigation.back(event.context);
      // print("Error ---- -- -- $err");
      emit(PostUpdateFailure(error: err.toString()));
    }
  }
}
