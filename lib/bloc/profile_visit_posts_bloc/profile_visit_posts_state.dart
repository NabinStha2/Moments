part of 'profile_visit_posts_bloc.dart';

enum ProfileVisitPostsStatus { loading, success, failure }

class ProfileVisitPostsState extends Equatable {
  final ProfileVisitPostsStatus profileVisitPostsStatus;
  final List<PostModelData>? postModel;
  final String? message;
  const ProfileVisitPostsState({
    this.profileVisitPostsStatus = ProfileVisitPostsStatus.loading,
    this.postModel,
    this.message,
  });

  ProfileVisitPostsState copyWith({
    ProfileVisitPostsStatus? profileVisitPostsStatus,
    List<PostModelData>? postModel,
    String? message,
  }) {
    return ProfileVisitPostsState(
      profileVisitPostsStatus:
          profileVisitPostsStatus ?? this.profileVisitPostsStatus,
      postModel: postModel ?? this.postModel,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [profileVisitPostsStatus, postModel, message];
}
