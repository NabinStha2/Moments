import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/screens/posts/post_details/post_details_screen.dart';

import '../../../../bloc/posts_bloc/posts_bloc.dart';

navigateToPostDetails({
  required BuildContext context,
  postId,
  userVisitId,
  isFromProfile = false,
  isFromComment = false,
  isFromHome = false,
  isFromActivity = false,
  bool isFromProfileVisit = false,
}) {
  RouteNavigation.navigate(
    context,
    BlocProvider.value(
      value: BlocProvider.of<PostsBloc>(context),
      child: PostDetailsScreen(
        postId: postId,
        isFromComment: isFromComment,
      ),
    ),
  );
}
