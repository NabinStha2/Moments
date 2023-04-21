part of 'posts_bloc.dart';

abstract class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object> get props => [];
}

class PostsInitial extends PostsState {}

class PostLoading extends PostsState {}

class PostFileSelectingLoadingState extends PostsState {}

class PostFileSelectedState extends PostsState {}

class PostPageChangedLoadingState extends PostsState {}

class PostPageChangedLoadedState extends PostsState {}

class ShowCommentDeleteState extends PostsState {}

class HideCommentDeleteState extends PostsState {}

class HideFileDownloadState extends PostsState {}

class ShowFileDownloadState extends PostsState {}

class ShowReplyCommentState extends PostsState {
  final String? commentId;
  final String? replyToUserId;
  final String? replyTo;
  const ShowReplyCommentState({
    this.commentId,
    this.replyToUserId,
    this.replyTo,
  });
}

class HideReplyCommentState extends PostsState {}

class PostClearValueState extends PostsState {}

class PostDeleteLoading extends PostsState {}

class PostDeleteFailure extends PostsState {
  final String? error;
  const PostDeleteFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class PostUpdateLoading extends PostsState {}

class PostUpdateFailure extends PostsState {
  final String? error;
  const PostUpdateFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class GetPostLoaded extends PostsState {
  final List<PostModelData>? postModel;
  final List<PostModelData>? allPostModel;
  final int? pages;
  const GetPostLoaded({
    required this.postModel,
    this.allPostModel,
    this.pages = 1,
  });
  // @override
  // List<Object> get props => [postModel!, pages!];
}

class GetPostFailure extends PostsState {
  final String? error;
  const GetPostFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class GetSinglePostLoaded extends PostsState {
  final PostModelData? postModel;
  const GetSinglePostLoaded({
    required this.postModel,
  });
  @override
  List<Object> get props => [postModel!];
}

class GetSinglePostFailure extends PostsState {
  final String? error;
  const GetSinglePostFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class GetAllPostLoaded extends PostsState {
  final List<PostModelData>? postModel;
  const GetAllPostLoaded({
    required this.postModel,
  });
  // @override
  // List<Object> get props => [postModel!, pages!];
}

class GetAllPostFailure extends PostsState {
  final String? error;
  const GetAllPostFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class CommentLoaded extends PostsState {}

class PostCommentFailure extends PostsState {
  final String? error;
  const PostCommentFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class PostDeleteCommentFailure extends PostsState {
  final String? error;
  const PostDeleteCommentFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class PostDeleted extends PostsState {}

class PostLiked extends PostsState {}

class PostLikedFailure extends PostsState {
  final String? error;
  const PostLikedFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class PostCreated extends PostsState {}

class PostCreatedFailure extends PostsState {
  final String? error;
  const PostCreatedFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}

class PostUpdated extends PostsState {}

// class PostError extends PostsState {
//   final String? error;
//   const PostError({
//     required this.error,
//   });
//   @override
//   List<Object> get props => [error!];
// }
