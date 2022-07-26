import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_time_ago/get_time_ago.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';

import '../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../widgets/custom_text_widget.dart';

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
              PoppinsText(
                postBloc.postModels[index].name ?? "",
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              PoppinsText(
                GetTimeAgo.parse(
                  DateTime.parse(post.createdAt.toString()),
                ),
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w400,
                fontSize: 13,
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
                    PopupMenuItem(
                      value: "edit",
                      child: PoppinsText(
                        "Edit",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: PoppinsText(
                        "Delete",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}
