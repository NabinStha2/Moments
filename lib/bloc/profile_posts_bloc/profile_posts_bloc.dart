import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:moment/models/post_model/post_model.dart';

import '../../development/console.dart';
import '../../repo/post_repo.dart';

part 'profile_posts_event.dart';
part 'profile_posts_state.dart';

class ProfilePostsBloc extends Bloc<ProfilePostsEvent, ProfilePostsState> {
  final PostRepo _postRepo = PostRepo();

  ProfilePostsBloc() : super(ProfilePostsInitial()) {
    on<GetProfilePostsEvent>((event, emit) async {
      await _getProfilePosts(event, emit);
    });
  }

  Future _getProfilePosts(
      GetProfilePostsEvent event, Emitter<ProfilePostsState> emit) async {
    emit(ProfilePostsLoading());
    try {
      final PostModel post = await _postRepo.creatorPosts(event.creator);

      if (post.message == "Success") {
        emit(ProfilePostsSuccess(postModel: post.data));
      }
    } catch (err) {
      consolelog("Error ---- -- -- $err");
      emit(ProfilePostsFailure(error: err.toString()));
    }
  }
}
