import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/app/dimension/dimension.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';

import '../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../widgets/custom_cached_network_image_widget.dart';
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CustomCachedNetworkImageWidget(
                  imageUrl:
                      postBloc.postModels[index].creator?.image.imageUrl ?? "",
                  height: 50,
                  width: 50,
                ),
              ),
              hSizedBox2,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    postBloc.postModels[index].name ?? "",
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  CustomText(
                    GetTimeAgo.parse(
                      DateTime.parse(post.createdAt.toString()),
                    ),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ],
              ),
            ],
          ),
          (StorageServices.authStorageValues["id"] == post.creator?.id)
              ? PopupMenuButton(
                  color: MColors.primaryGrayColor50,
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
                          token:
                              StorageServices.authStorageValues["token"] ?? "",
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 30,
                  ),
                  splashRadius: 20,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "edit",
                      child: CustomText(
                        "Edit",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: CustomText(
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
