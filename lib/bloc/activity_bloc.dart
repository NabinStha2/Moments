import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/models/activity_model.dart';
import 'package:moment/repo/activity_repo.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc() : super(ActivityInitial()) {
    final _activityRepo = ActivityRepo();

    on<GetActivity>((event, emit) async {
      emit(ActivityLoading());
      try {
        final allActivity = await _activityRepo.getAllActivity(id: event.id);
        if (allActivity != null) {
          inspect(allActivity);
          emit(ActivityLoaded(activityList: allActivity));
        }
      } catch (err) {
        // ignore: avoid_log
        log("err : $err");
        emit(const ActivityError(errMessage: "Server has been down recently"));
      }
    });
  }
}
