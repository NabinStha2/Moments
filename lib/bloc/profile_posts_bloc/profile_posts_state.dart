part of 'profile_posts_bloc.dart';

abstract class ProfilePostsState extends Equatable {
  const ProfilePostsState();

  @override
  List<Object> get props => [];
}

class ProfilePostsInitial extends ProfilePostsState {}

class ProfilePostsLoading extends ProfilePostsState {}

class ProfilePostsSuccess extends ProfilePostsState {
  final List<PostModelData>? postModel;
  const ProfilePostsSuccess({
    required this.postModel,
  });
  @override
  List<Object> get props => [postModel!];
}

class ProfilePostsFailure extends ProfilePostsState {
  final String? error;
  const ProfilePostsFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error!];
}
