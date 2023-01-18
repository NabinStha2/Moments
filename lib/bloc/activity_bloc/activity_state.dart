part of 'activity_bloc.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final ActivityModel activityList;
  const ActivityLoaded({
    required this.activityList,
  });
}

class ActivityError extends ActivityState {
  final String errMessage;
  const ActivityError({
    required this.errMessage,
  });
}
