import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moment/development/console.dart';
import 'package:moment/models/activity_model/activity_model.dart';
import 'package:moment/repo/activity_repo.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final _activityRepo = ActivityRepo();
  ActivityBloc() : super(ActivityInitial()) {
    on<GetActivity>((event, emit) async {
      return _getActivity(event, emit);
    });
  }

  _getActivity(event, Emitter<ActivityState> emit) async {
    emit(ActivityLoading());
    try {
      final ActivityModel allActivity = await _activityRepo.getAllActivity(id: event.id);
      if (allActivity.message == "Success" && allActivity.data != null && allActivity.data?.activity?.isNotEmpty == true) {
        emit(ActivityLoaded(activityList: allActivity));
      }
    } catch (err) {
      consolelog("err : $err");
      emit(ActivityError(errMessage: err.toString()));
    }
  }
}
