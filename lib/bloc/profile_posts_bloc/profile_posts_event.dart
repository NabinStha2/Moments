part of 'profile_posts_bloc.dart';

abstract class ProfilePostsEvent extends Equatable {
  const ProfilePostsEvent();

  @override
  List<Object> get props => [];
}

class GetProfilePostsEvent extends ProfilePostsEvent {
  final String creator;
  final BuildContext context;
  const GetProfilePostsEvent({
    required this.creator,
    required this.context,
  });
  @override
  List<Object> get props => [creator];
}
