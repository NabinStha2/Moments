import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/utils/storage_services.dart';

import '../../../../../bloc/activity_bloc/activity_bloc.dart';
import '../../../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../../../bloc/profile_posts_bloc/profile_posts_bloc.dart';

void WillPopScopePostDetailsBody({
  required BuildContext context,
  bool? isFromProfileVisit = false,
  bool? isFromProfile = false,
  bool? isFromActivity = false,
  String? userVisitId,
}) {
  if (isFromProfileVisit == true) {
    BlocProvider.of<ProfilePostsBloc>(context).add(
      GetProfilePostsEvent(
        context: context,
        creator: userVisitId!,
      ),
    );
  } else if (isFromProfile == true) {
    BlocProvider.of<ProfilePostsBloc>(context).add(
      GetProfilePostsEvent(
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
