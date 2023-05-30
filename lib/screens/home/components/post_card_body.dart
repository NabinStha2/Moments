import 'package:flutter/material.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/components/post_display_file.dart';
import 'package:moment/screens/home/components/post_footer_body.dart';
import 'package:moment/screens/home/components/post_header_widget.dart';
import 'package:moment/screens/home/components/widgets/navigation_post_details_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class PostCardBody extends StatelessWidget {
  final int index;
  final PostModelData post;
  const PostCardBody({
    Key? key,
    required this.index,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MColors.primaryGrayColor90,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(10.0),
      elevation: 2.0,
      child: Column(
        children: [
          Column(
            children: [
              PostHeaderBody(index: index, post: post),
              PostDisplayFileBody(
                post: post,
              ),
              SizedBox(
                width: appWidth(context),
                child: InkWell(
                  onTap: () {
                    navigateToPostDetails(context: context, postId: post.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomExpandableText(
                          text: post.description,
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          PostFooterBody(post: post),
        ],
      ),
    );
  }
}
