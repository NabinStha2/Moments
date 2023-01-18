import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/activity_bloc/activity_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/profile_posts_bloc/profile_posts_bloc.dart';
import '../utils/storage_services.dart';

void loadAllData({required BuildContext context}) async {
  if (StorageServices.authStorageValues.isNotEmpty == true && StorageServices.authStorageValues != {}) {
    BlocProvider.of<ProfilePostsBloc>(context).add(
      GetProfilePostsEvent(
        context: context,
        creator: StorageServices.authStorageValues["id"] ?? "",
      ),
    );
    BlocProvider.of<ActivityBloc>(context).add(
      GetActivity(id: StorageServices.authStorageValues["id"] ?? ""),
    );
    BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
      context: context,
      id: StorageServices.authStorageValues["id"],
    ));
    BlocProvider.of<AuthBloc>(context).add(
      GetAllUser(context: context),
    );
    BlocProvider.of<AuthBloc>(context).add(
      GetOwnerById(
        context: context,
        id: StorageServices.authStorageValues["id"],
      ),
    );
  }
}
