import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_time_ago/get_time_ago.dart';

import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_cached_network_image_widget.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';

class PostHeaderBody extends StatelessWidget {
  final PostModelData post;
  final int index;
  const PostHeaderBody({
    Key? key,
    required this.post,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                postBloc.postModels[index].name ?? "",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                GetTimeAgo.parse(
                  DateTime.parse(post.createdAt.toString()),
                ),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          (StorageServices.authStorageValues["id"] == post.creator)
              ? PopupMenuButton(
                  onSelected: (value) {
                    if (value as String == "edit") {
                      customModalBottomSheetWidget(post: post, ctx: context);
                    } else {
                      postBloc.add(
                        DeletePostEvent(
                          isFromActivity: false,
                          isFromProfile: false,
                          isFromVisit: false,
                          context: context,
                          id: post.id!,
                          token: StorageServices.authStorageValues["token"] ?? "",
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey,
                    size: 30,
                  ),
                  splashRadius: 20,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "edit",
                      child: Text("Edit"),
                    ),
                    const PopupMenuItem(
                      value: "delete",
                      child: Text("Delete"),
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}
