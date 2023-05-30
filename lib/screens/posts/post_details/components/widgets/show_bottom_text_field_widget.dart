import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/utils/user_post_signal_id.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_text_form_field_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../../../development/console.dart';

FocusNode commentFocusNode = FocusNode();

Widget showBottomTextField({
  isReply = false,
  String? commentId,
  String? replyToUserId,
  String? replyTo,
  required BuildContext context,
  bool isFromComment = false,
}) {
  var postBloc = BlocProvider.of<PostsBloc>(context);
  return Container(
    color: MColors.primaryGrayColor90,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isReply
            ? Column(
                children: [
                  const Divider(
                    height: 15,
                    color: MColors.primaryGrayColor50,
                    thickness: 0.8,
                    endIndent: 16,
                    indent: 16,
                  ),
                  Container(
                    color: MColors.primaryGrayColor80,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          "Reply to $replyTo...",
                          color: MColors.primaryGrayColor35,
                        ),
                        GestureDetector(
                          onTap: () {
                            commentFocusNode.unfocus();
                            postBloc.add(HideReplyCommentEvent());
                          },
                          child: const Icon(
                            Icons.close,
                            color: MColors.primaryGrayColor50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
        const Divider(
          height: 15,
          color: MColors.primaryGrayColor50,
          thickness: 0.8,
          endIndent: 16,
          indent: 16,
        ),
        Container(
          color: postBloc.showCommentDelete
              ? MColors.primaryGrayColor50
              : Colors.transparent,
          child: CustomTextFormFieldWidget(
            isFilled: true,
            showSuffix: true,
            focusNode: commentFocusNode,
            fillColor: MColors.primaryGrayColor90,
            autofocus: isReply || isFromComment,
            controller: postBloc.commentController,
            labelText: isReply ? "Reply to $replyTo..." : "Add a comment...",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            suffix: CustomIconButtonWidget(
              height: 30,
              width: 30,
              color: MColors.primaryGrayColor50,
              padding: EdgeInsets.zero,
              onPressed: () async {
                if (postBloc.commentController.text.isNotEmpty) {
                  if (StorageServices.authStorageValues.isNotEmpty == true) {
                    if (isReply) {
                      postBloc.add(
                        CommentPostEvent(
                          context: context,
                          id: postBloc.singlePostData?.id ?? "",
                          value:
                              "${StorageServices.authStorageValues["name"]}:${postBloc.commentController.text}",
                          token:
                              StorageServices.authStorageValues["token"] ?? "",
                          creatorId: postBloc.singlePostData?.creator?.id ?? "",
                          userId: StorageServices.authStorageValues["id"] ?? "",
                          postUrl: postBloc.singlePostData?.fileType == "video"
                              ? postBloc.singlePostData?.file?.thumbnail ?? ""
                              : postBloc.singlePostData?.file?.fileUrl ?? "",
                          userImageUrl:
                              StorageServices.authStorageValues["imageUrl"] ??
                                  "",
                          activityName:
                              "${StorageServices.authStorageValues["name"]} has reply to comment on a post.",
                          isReply: true,
                          commentId: commentId,
                          replyToUserId: replyToUserId,
                        ),
                      );
                      postBloc.add(
                        HideReplyCommentEvent(),
                      );
                    } else {
                      postBloc.add(
                        CommentPostEvent(
                          context: context,
                          id: postBloc.singlePostData?.id ?? "",
                          value:
                              "${StorageServices.authStorageValues["name"]}:${postBloc.commentController.text}",
                          token:
                              StorageServices.authStorageValues["token"] ?? "",
                          creatorId: postBloc.singlePostData?.creator?.id ?? "",
                          userId: StorageServices.authStorageValues["id"] ?? "",
                          postUrl: postBloc.singlePostData?.fileType == "video"
                              ? postBloc.singlePostData?.file?.thumbnail ?? ""
                              : postBloc.singlePostData?.file?.fileUrl ?? "",
                          userImageUrl:
                              StorageServices.authStorageValues["imageUrl"] ??
                                  "",
                          activityName:
                              "${StorageServices.authStorageValues["name"]} has commented on your post.",
                        ),
                      );
                    }
                    postBloc.add(PostClearValueEvent());

                    if (isReply) {
                      var resOneSignalIds = await getUserSignalId(
                        baseUrl: ApiConfig.baseUrl,
                        userId: replyToUserId,
                      );
                      var resData = json.decode(resOneSignalIds);
                      consolelog(resData);
                      if (resData["message"] == "Success" &&
                          resData["data"] != []) {
                        var notifications = OSCreateNotification(
                          playerIds: (resData["data"] as List)
                              .map((e) => e.toString())
                              .toList(),
                          androidSound: "landras_dream",
                          content:
                              "${StorageServices.authStorageValues["name"]} has reply to your comment on a post.",
                          heading: "Moments",
                          bigPicture: postBloc.singlePostData?.file?.fileUrl,
                        );
                        await OneSignal.shared.postNotification(notifications);
                      } else {
                        var resOneSignalIds = await getUserPostSignalId(
                          baseUrl: ApiConfig.baseUrl,
                          postId: postBloc.singlePostData!.id,
                        );
                        var resData = json.decode(resOneSignalIds);
                        // consolelog(resData);
                        if (resData["message"] == "Success" &&
                            resData["data"] != []) {
                          var notification = OSCreateNotification(
                            playerIds: (resData["data"] as List)
                                .map((e) => e.toString())
                                .toList(),
                            androidSound: "landras_dream",
                            content:
                                "${StorageServices.authStorageValues["name"]} has commented on your post.",
                            heading: "Moments",
                            bigPicture: postBloc.singlePostData?.file?.fileUrl,
                          );
                          await OneSignal.shared.postNotification(notification);
                        }
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                          content: CustomText("Login to comment!"),
                          elevation: 0.0,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  }
                } else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                        content:
                            CustomText("Comment shouldn't be empty or login"),
                        elevation: 0.0,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                }
              },
              icon: const Icon(
                Icons.send,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
