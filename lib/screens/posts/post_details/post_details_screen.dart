import 'package:flutter/material.dart';
import 'package:moment/screens/posts/post_details/components/post_details_body.dart';

class PostDetailsScreen extends StatelessWidget {
  final String postId;
  final bool isFromComment;
  const PostDetailsScreen({
    Key? key,
    required this.postId,
    this.isFromComment = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PostDetailsBody(
      postId: postId,
      isFromComment: isFromComment,
    );
  }
}
