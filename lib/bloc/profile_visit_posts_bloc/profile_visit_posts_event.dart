part of 'profile_visit_posts_bloc.dart';

abstract class ProfileVisitPostsEvent extends Equatable {
  const ProfileVisitPostsEvent();

  @override
  List<Object> get props => [];
}


class GetProfileVisitPostsEvent extends ProfileVisitPostsEvent {
  final String creator;
  final BuildContext context;
  const GetProfileVisitPostsEvent({
    required this.creator,
    required this.context,
  });
  @override
  List<Object> get props => [creator];
}

