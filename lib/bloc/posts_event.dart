part of 'posts_bloc.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

class GetPostsEvent extends PostsEvent {
  final int? page;
  const GetPostsEvent({
    this.page = 1,
  });
}

class GetSinglePostEvent extends PostsEvent {
  final String id;
  const GetSinglePostEvent({
    required this.id,
  });

  @override
  List<Object> get props => [
        id,
      ];
}

class RefreshPostsEvent extends PostsEvent {}

class LikePostEvent extends PostsEvent {
  final String id;
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
  const DeletePostEvent({
    required this.id,
    required this.token,
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
  });
  @override
  List<Object> get props => [id, value];
}

class CreatePostEvent extends PostsEvent {
  final dynamic data;
  final String token;
  const CreatePostEvent({
    required this.data,
    required this.token,
  });
  @override
  List<Object> get props => [data, token];
}

class UpdatePostEvent extends PostsEvent {
  final String id;
  final Map<String, dynamic> data;
  final String token;
  const UpdatePostEvent({
    required this.id,
    required this.data,
    required this.token,
  });
  @override
  List<Object> get props => [id, data, token];
}

class GetCreatorPostsEvent extends PostsEvent {
  final String creator;
  const GetCreatorPostsEvent({
    required this.creator,
  });
  @override
  List<Object> get props => [creator];
}

class DeleteCommentEvent extends PostsEvent {
  final String commentId;
  final String postId;
  final List<String> activityId;
  final String token;
  const DeleteCommentEvent({
    required this.commentId,
    required this.postId,
    required this.activityId,
    required this.token,
  });
}
