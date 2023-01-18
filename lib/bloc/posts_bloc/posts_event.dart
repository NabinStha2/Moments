part of 'posts_bloc.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

class GetPostsEvent extends PostsEvent {
  final int page;
  final BuildContext context;
  const GetPostsEvent({
    this.page = 1,
    required this.context,
  });
}

class PostFileSelectedEvent extends PostsEvent {
  final File? selectedFile;
  final bool? isUpdate;
  const PostFileSelectedEvent({
    this.selectedFile,
    this.isUpdate = false,
  });
}

class PostPageChangeEvent extends PostsEvent {
  final int? pageNumber;
  final BuildContext context;
  const PostPageChangeEvent({
    this.pageNumber = 1,
    required this.context,
  });
}

class PostClearValueEvent extends PostsEvent {}

class ShowCommentDeleteEvent extends PostsEvent {
  final bool showCommentDelete;
  final Comments? cmt;
  final int? index;
  const ShowCommentDeleteEvent({
    this.showCommentDelete = false,
    this.cmt,
    this.index,
  });
}

class HideCommentDeleteEvent extends PostsEvent {}

class ShowFileDownloadLoadingEvent extends PostsEvent {
  final bool showFileDownload;
  const ShowFileDownloadLoadingEvent({
    this.showFileDownload = false,
  });
}

class HideFileDownloadLoadingEvent extends PostsEvent {}

class ShowReplyCommentEvent extends PostsEvent {
  final bool showReplyComment;
  final String? commentId;
  final String? replyToUserId;
  final String? replyTo;
  const ShowReplyCommentEvent({
    this.showReplyComment = false,
    this.commentId,
    this.replyToUserId,
    this.replyTo,
  });
}

class HideReplyCommentEvent extends PostsEvent {}

class GetSinglePostEvent extends PostsEvent {
  final String id;
  final BuildContext context;
  const GetSinglePostEvent({
    required this.id,
    required this.context,
  });

  @override
  List<Object> get props => [
        id,
      ];
}

class RefreshPostsEvent extends PostsEvent {}

class LikePostEvent extends PostsEvent {
  final String id;
  final BuildContext context;
  final String userId;
  final String token;
  final String creatorId;
  final String postUrl;
  final String activityName;
  final String userImageUrl;
  final String reactionType;
  final bool postDetails;
  const LikePostEvent({
    required this.id,
    required this.userId,
    required this.context,
    required this.token,
    required this.creatorId,
    required this.postUrl,
    required this.activityName,
    required this.userImageUrl,
    required this.reactionType,
    this.postDetails = false,
  });

  @override
  List<Object> get props => [id, token];
}

class DeletePostEvent extends PostsEvent {
  final String id;
  final String token;
  final bool isFromVisit;
  final String? isFromVisitUserId;
  final bool isFromProfile;
  final bool isFromActivity;
  final BuildContext context;
  const DeletePostEvent({
    required this.id,
    required this.token,
    required this.isFromVisit,
    this.isFromVisitUserId,
    required this.isFromProfile,
    required this.isFromActivity,
    required this.context,
  });
  @override
  List<Object> get props => [id, token];
}

class CommentPostEvent extends PostsEvent {
  final String id;
  final String value;
  final String token;
  final String userId;
  final String creatorId;
  final String postUrl;
  final String activityName;
  final String userImageUrl;
  final bool isReply;
  final String? commentId;
  final String? replyToUserId;
  final BuildContext context;
  const CommentPostEvent({
    required this.id,
    required this.value,
    required this.token,
    required this.userId,
    required this.creatorId,
    required this.postUrl,
    required this.activityName,
    required this.userImageUrl,
    this.isReply = false,
    this.commentId,
    this.replyToUserId,
    required this.context,
  });
  @override
  List<Object> get props => [id, value];
}

class CreatePostEvent extends PostsEvent {
  final dynamic data;
  final String token;
  final bool isImage;
  final BuildContext context;
  const CreatePostEvent({
    required this.data,
    required this.token,
    this.isImage = true,
    required this.context,
  });
  @override
  List<Object> get props => [data, token];
}

class UpdatePostEvent extends PostsEvent {
  final String id;
  final Map<String, dynamic> data;
  final String token;
  final BuildContext context;
  final bool isFromPostDetails;
  final bool isImage;
  const UpdatePostEvent({
    required this.id,
    required this.data,
    required this.token,
    required this.context,
    this.isFromPostDetails = false,
    this.isImage = true,
  });
  @override
  List<Object> get props => [id, data, token];
}

class DeleteCommentEvent extends PostsEvent {
  final String commentId;
  final String postId;
  final List<String> activityId;
  final String token;
  final BuildContext context;
  const DeleteCommentEvent({
    required this.commentId,
    required this.postId,
    required this.activityId,
    required this.token,
    required this.context,
  });
}
