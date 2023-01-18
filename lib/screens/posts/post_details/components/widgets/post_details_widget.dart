import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/dimension/dimension.dart';
import '../../../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../../../models/post_model/post_model.dart';
import '../../../../../widgets/custom_reactions_widget.dart';
import '../../../../../widgets/custom_text_widget.dart';
import '../comment_list_body.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsWidget extends StatelessWidget {
  const PostDetailsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);

    return postBloc.singlePostData != null
        ? Container(
            color: postBloc.showCommentDelete ? Colors.black45 : Colors.transparent,
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(
                  //   height: 500,
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.circular(20.0),
                  //     child: PostDisplayFileBody(
                  //       post: postBloc.singlePostData ?? PostModelData(),
                  //       isCachedImage: false,
                  //       opacity: postBloc.showCommentDelete ? 0.3 : 1.0,
                  //     ),
                  //   ),
                  // ),
                  vSizedBox2,
                  vSizedBox0,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomReactionsWidget(
                        post: postBloc.singlePostData ?? PostModelData(),
                      ),
                      hSizedBox0,
                      Expanded(
                        child: CustomExpandableText(
                          text: postBloc.singlePostData!.description!,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                  vSizedBox1,
                  Text(
                    timeago.format(
                      DateTime.parse(postBloc.singlePostData?.createdAt.toString() ?? ""),
                    ),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  vSizedBox0,
                  vSizedBox1,
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: postBloc.showCommentDelete ? Colors.black12 : Colors.grey.shade200,
                    ),
                    width: double.infinity,
                    child: const CommentListBody(),
                  ),
                  vSizedBox3,
                  vSizedBox3,
                  vSizedBox3,
                ],
              ),
            ),
          )
        : Center(
            child: PoppinsText("Something went wrong! Please try again."),
          );
  }
}
