import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/components/widgets/navigation_post_details_widget.dart';
import 'package:moment/utils/dynamic_link.dart';
import 'package:moment/widgets/custom_reactions_widget.dart';

class PostFooterBody extends StatelessWidget {
  final PostModelData post;
  const PostFooterBody({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomReactionsWidget(
                post: post,
              ),
              Text(
                post.likes?.length.toString() ?? "0",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => {
                  navigateToPostDetails(
                      context: context, postId: post.id, isFromComment: true)
                },
                splashColor: Colors.grey,
                splashRadius: 20.0,
                icon: const FaIcon(
                  FontAwesomeIcons.commentDots,
                ),
              ),
              Text(
                post.comments?.length.toString() ?? "0",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () async {
                  var link = await FirebaseDynamicLinkService.createDynamicLink(
                      postId: post.id);
                  Share.share(link, subject: "Moments post.");
                },
                splashColor: Colors.grey,
                splashRadius: 20.0,
                icon: const FaIcon(
                  FontAwesomeIcons.share,
                  color: Colors.grey,
                  size: 25.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
