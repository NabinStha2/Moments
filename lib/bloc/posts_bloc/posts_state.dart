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

class PostUpdateLoading extends PostsState {}

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

class GetSinglePostLoaded extends PostsState {
  final PostModelData? postModel;
  const GetSinglePostLoaded({
    required this.postModel,
  });
  @override
  List<Object> get props => [postModel!];
}

class GetAllPostLoaded extends PostsState {
  final List<PostModelData>? postModel;
  const GetAllPostLoaded({
    required this.postModel,
  });
  // @override
  // List<Object> get props => [postModel!, pages!];
}

class CommentLoaded extends PostsState {}

class PostDeleted extends PostsState {}

class PostLiked extends PostsState {}

class PostCreated extends PostsState {}

class PostUpdated extends PostsState {}

class PostError extends PostsState {
  final String? error;
  const PostError({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}
