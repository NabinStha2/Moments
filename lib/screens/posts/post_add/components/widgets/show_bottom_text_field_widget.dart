import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/development/console.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/utils/user_post_signal_id.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Widget showBottomTextField({
  isReply = false,
  String? commentId,
  String? replyToUserId,
  required BuildContext context,
  bool isFromComment = false,
}) {
  if (commentId != null) {
    consolelog(commentId);
  }
  var postBloc = BlocProvider.of<PostsBloc>(context);
  return Container(
    color: postBloc.showCommentDelete ? Colors.black45 : Colors.transparent,
    padding: const EdgeInsets.all(15),
    child: TextField(
      autofocus: isFromComment,
      controller: postBloc.commentController,
      decoration: InputDecoration(
        labelText: isReply ? "Reply to ..." : "Add a comment...",
        contentPadding: const EdgeInsets.all(10),
        suffixIcon: CustomIconButtonWidget(
          onPressed: () async {
            if (postBloc.commentController.text.isNotEmpty) {
              if (StorageServices.authStorageValues.isNotEmpty == true) {
                if (isReply) {
                  postBloc.add(
                    CommentPostEvent(
                      context: context,
                      id: postBloc.singlePostData?.id ?? "",
                      value: "${StorageServices.authStorageValues["name"]}:${postBloc.commentController.text}",
                      token: StorageServices.authStorageValues["token"] ?? "",
                      creatorId: postBloc.singlePostData?.creator ?? "",
                      userId: StorageServices.authStorageValues["id"] ?? "",
                      postUrl: postBloc.singlePostData?.fileType == "video"
                          ? postBloc.singlePostData?.file?.thumbnail ?? ""
                          : postBloc.singlePostData?.file?.fileUrl ?? "",
                      userImageUrl: StorageServices.authStorageValues["imageUrl"] ?? "",
                      activityName: "${StorageServices.authStorageValues["name"]} has commented on your post.",
                      isReply: true,
                      commentId: commentId,
                      replyToUserId: replyToUserId,
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  postBloc.add(
                    CommentPostEvent(
                      context: context,
                      id: postBloc.singlePostData?.id ?? "",
                      value: "${StorageServices.authStorageValues["name"]}:${postBloc.commentController.text}",
                      token: StorageServices.authStorageValues["token"] ?? "",
                      creatorId: postBloc.singlePostData?.creator ?? "",
                      userId: StorageServices.authStorageValues["id"] ?? "",
                      postUrl: postBloc.singlePostData?.fileType == "video"
                          ? postBloc.singlePostData?.file?.thumbnail ?? ""
                          : postBloc.singlePostData?.file?.fileUrl ?? "",
                      userImageUrl: StorageServices.authStorageValues["imageUrl"] ?? "",
                      activityName: "${StorageServices.authStorageValues["name"]} has commented on your post.",
                    ),
                  );
                }
                postBloc.add(PostClearValueEvent());
                var resOneSignalIds = await getUserPostSignalId(
                  baseUrl: ApiConfig.baseUrl,
                  postId: postBloc.singlePostData!.id,
                );
                var resData = json.decode(resOneSignalIds);
                if (resData["message"] == "Success" && resData["data"] != []) {
                  var notification = OSCreateNotification(
                    playerIds: (resData["data"] as List).map((e) => e.toString()).toList(),
                    androidSound: "landras_dream",
                    content: "${StorageServices.authStorageValues["name"]} has commented on your post.",
                    heading: "Moments",
                    bigPicture: postBloc.singlePostData?.file?.fileUrl,
                  );
                  await OneSignal.shared.postNotification(notification);
                }
              } else {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                      content: Text("Login to comment!"),
                      elevation: 0.0,
                      duration: Duration(seconds: 2),
                    ),
                  );
              }
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    content: Text("Comment shouldn't be empty or login"),
                    elevation: 0.0,
                    duration: Duration(seconds: 2),
                  ),
                );
            }
          },
          icon: const Icon(Icons.send),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    ),
  );
}
