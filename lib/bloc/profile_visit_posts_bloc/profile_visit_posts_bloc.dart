import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../development/console.dart';
import '../../models/post_model/post_model.dart';
import '../../repo/post_repo.dart';

part 'profile_visit_posts_event.dart';
part 'profile_visit_posts_state.dart';

class ProfileVisitPostsBloc
    extends Bloc<ProfileVisitPostsEvent, ProfileVisitPostsState> {
  final PostRepo _postRepo = PostRepo();

  ProfileVisitPostsBloc() : super(const ProfileVisitPostsState()) {
    on<GetProfileVisitPostsEvent>((event, emit) async {
      await _getProfileVisitPosts(event, emit);
    });
  }

  Future _getProfileVisitPosts(GetProfileVisitPostsEvent event,
      Emitter<ProfileVisitPostsState> emit) async {
    emit(state.copyWith(
      profileVisitPostsStatus: ProfileVisitPostsStatus.loading,
    ));
    try {
      final PostModel post = await _postRepo.creatorPosts(event.creator);

      if (post.message == "Success") {
        emit(state.copyWith(
          postModel: post.data,
          profileVisitPostsStatus: ProfileVisitPostsStatus.success,
        ));
      }
    } catch (err) {
      consolelog("Error ---- -- -- $err");
      emit(state.copyWith(
        message: err.toString(),
        profileVisitPostsStatus: ProfileVisitPostsStatus.failure,
      ));
    }
  }
}
