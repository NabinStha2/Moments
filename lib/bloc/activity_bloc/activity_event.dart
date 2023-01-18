part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object> get props => [];
}

class GetActivity extends ActivityEvent {
  final String id;

  const GetActivity({required this.id});
}
