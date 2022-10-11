import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/screens/post_add/components/post_details.dart';

navigateToPostDetails({required BuildContext context, post, isFromComment = false, isFromHome = false}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<PostsBloc>(context),
        child: Postdetails(
          isFromProfileVisit: false,
          isFromProfile: false,
          postId: post.id,
          isFromHome: isFromHome,
          isFromComment: isFromComment,
        ),
      ),
    ),
  );
}
