// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import "package:http/http.dart" as http;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/bloc/activityBloc/activity_bloc.dart';
import 'package:moment/development/console.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/repo/post_repo.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_dialog_widget.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostRepo _postRepo = PostRepo();
  final List<PostModelData> postModels = <PostModelData>[];
  final List<PostModelData> allPostModels = <PostModelData>[];
  int pages = 0;
  int currentPage = 1;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController updateDescriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  File? postSelectedFile;
  File? updatePostSelectedFile;

  PostsBloc() : super(PostsInitial()) {
    on<PostFileSelectedEvent>((event, emit) async {
      emit(PostFileSelectingLoadingState());
      event.isUpdate == true ? updatePostSelectedFile = event.selectedFile : postSelectedFile = event.selectedFile;
      emit(PostFileSelectedState());
    });
    on<PostPageChangeEvent>((event, emit) async {
      emit(PostPageChangedLoadingState());
      consolelog("event: ${event.pageNumber}");
      currentPage = event.pageNumber ?? 1;
      consolelog("currentPage: $currentPage");
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
    on<GetCreatorPostsEvent>((event, emit) async {
      await _getCreatorPosts(event, emit);
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

      if (posts.message == "Success" && posts.data?.isNotEmpty == true && allPosts.data?.isNotEmpty == true) {
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
      // log("Error ---- $e.toString()");
      emit(PostError(error: e.toString()));
    }
  }

  Future _getSinglePost(GetSinglePostEvent event, Emitter<PostsState> emit) async {
    emit(PostLoading());
    try {
      final PostModel post = await _postRepo.getSinglePost(id: event.id);
      if (post.message == "Success" && post.data?.isNotEmpty == true) {
        emit(GetSinglePostLoaded(
          postModel: post.data?[0],
        ));
      }
    } catch (e) {
      print("Error from GetSinglePostEvent ---- $e");
      emit(PostError(error: e.toString()));
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
        postModels[postModels.indexWhere((element) => element.id == post.data?[0].id)] = post.data?[0] as PostModelData;
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
      emit(PostError(error: err.toString()));
    }
  }

  Future _deletePost(DeletePostEvent event, Emitter<PostsState> emit) async {
    try {
      emit(PostDeleteLoading());

      final PostModel deletedPost = await _postRepo.deletePost(event.id, event.token);
      if (deletedPost.message == "Success" && deletedPost.data?.isNotEmpty == true) {
        postModels.removeAt(postModels.indexWhere((element) => element.id == deletedPost.data?[0].id));
        emit(PostDeleted());
        emit(GetPostLoaded(
          postModel: postModels,
          allPostModel: allPostModels,
          pages: 1,
        ));
        if (event.isFromVisit) {
          BlocProvider.of<PostsBloc>(event.context).add(
            GetCreatorPostsEvent(
              context: event.context,
              creator: event.isFromVisitUserId ?? "",
            ),
          );
        } else if (event.isFromProfile) {
          BlocProvider.of<PostsBloc>(event.context).add(
            GetCreatorPostsEvent(
              context: event.context,
              creator: StorageServices.authStorageValues["id"] ?? "",
            ),
          );
          Navigator.of(event.context).pop(true);
        } else if (event.isFromActivity) {
          BlocProvider.of<ActivityBloc>(event.context).add(GetActivity(id: StorageServices.authStorageValues["id"] ?? ""));
        } else {
          // BlocProvider.of<PostsBloc>(event.context).add(RefreshPostsEvent());
          // BlocProvider.of<PostsBloc>(event.context).add(GetPostsEvent(
          //   context: event.context,
          // ));
        }
      }
    } catch (e) {
      print("Error ---- $e");
      emit(PostError(error: e.toString()));
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
        emit(GetSinglePostLoaded(
          postModel: post.data?[0],
        ));
      }
    } catch (err) {
      print("Error ---- $err");
      emit(PostError(error: err.toString()));
    }
  }

  Future _deletePostComment(DeleteCommentEvent event, Emitter<PostsState> emit) async {
    try {
      final PostModel post = await _postRepo.deleteComment(
        postId: event.postId,
        token: event.token,
        commentId: event.commentId,
        activityId: event.activityId,
      );

      if (post.message == "Success" && post.data?.isNotEmpty == true) {
        emit(GetSinglePostLoaded(
          postModel: post.data?[0],
        ));
      }
    } catch (err) {
      print("Error ---- $err");
      emit(PostError(error: err.toString()));
    }
  }

  Future _createPost(CreatePostEvent event, Emitter<PostsState> emit) async {
    emit(PostLoading());
    CustomDialogs.showCustomFullLoadingDialog(ctx: event.context, title: "Uploading...");
    try {
      final PostModel post = await _postRepo.createPost(event.data, event.token, isImage: event.isImage);
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
        BlocProvider.of<PostsBloc>(event.context).add(
          RefreshPostsEvent(),
        );
        BlocProvider.of<PostsBloc>(event.context).add(
          GetPostsEvent(context: event.context),
        );
      }
      Navigator.pop(event.context);
    } catch (err) {
      Navigator.pop(event.context);
      consolelog(err);
      emit(PostError(error: err.toString()));
    }
  }

  Future _updatePost(
    UpdatePostEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(PostUpdateLoading());
    CustomDialogs.showCustomFullLoadingDialog(ctx: event.context, title: "Uploading...");
    try {
      final PostModel post = await _postRepo.updatePost(event.id, event.data, event.token, isImage: event.isImage);
      if (post.data != null && post.message == "Success") {
        postModels[postModels.indexWhere((element) => element.id == post.data?[0].id)] = post.data![0];
        emit(PostUpdated());
        emit(GetPostLoaded(postModel: postModels));
        BlocProvider.of<PostsBloc>(event.context).add(RefreshPostsEvent());
        BlocProvider.of<PostsBloc>(event.context).add(GetPostsEvent(context: event.context));

        BlocProvider.of<PostsBloc>(event.context).add(GetSinglePostEvent(
          context: event.context,
          id: post.data?[0].id ?? "",
        ));
        Navigator.of(event.context).pop(true);
      }
      Navigator.of(event.context).pop(true);
    } catch (err) {
      Navigator.pop(event.context);
      // print("Error ---- -- -- $err");
      emit(PostError(error: err.toString()));
    }
  }

  Future _getCreatorPosts(GetCreatorPostsEvent event, Emitter<PostsState> emit) async {
    emit(PostLoading());
    try {
      final PostModel post = await _postRepo.creatorPosts(event.creator);

      if (post.message == "Success") {
        emit(CreatorPostsLoaded(postModel: post.data));
      }
    } catch (err) {
      // print("Error ---- -- -- $err");
      emit(CreatorPostError());
      emit(PostError(error: err.toString()));
    }
  }
}
