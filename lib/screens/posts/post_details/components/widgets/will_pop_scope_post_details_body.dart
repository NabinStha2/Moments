import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/bloc/activityBloc/activity_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/utils/storage_services.dart';

void WillPopScopePostDetailsBody({
  required BuildContext context,
  bool? isFromProfileVisit = false,
  bool? isFromProfile = false,
  bool? isFromActivity = false,
  String? userVisitId,
}) {
  if (isFromProfileVisit == true) {
    BlocProvider.of<PostsBloc>(context).add(
      GetCreatorPostsEvent(
        context: context,
        creator: userVisitId!,
      ),
    );
  } else if (isFromProfile == true) {
    BlocProvider.of<PostsBloc>(context).add(
      GetCreatorPostsEvent(
        context: context,
        creator: StorageServices.authStorageValues["id"] ?? "",
      ),
    );
  } else if (isFromActivity == true) {
    BlocProvider.of<ActivityBloc>(context).add(GetActivity(id: StorageServices.authStorageValues["id"] ?? ""));
  } else {
    BlocProvider.of<PostsBloc>(context).add(RefreshPostsEvent());
    BlocProvider.of<PostsBloc>(context).add(PostPageChangeEvent(pageNumber: 1, context: context));
  }
}
