import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:moment/development/console.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/utils/user_post_signal_id.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/home_screen.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/utils/flutter_reaction.dart' as FlutterReactions;
import 'package:moment/widgets/custom_snackbar_widget.dart';

import '../bloc/posts_bloc/posts_bloc.dart';

class CustomReactionsWidget extends StatefulWidget {
  final PostModelData post;
  final bool isFromPostDetails;

  const CustomReactionsWidget({
    Key? key,
    required this.post,
    this.isFromPostDetails = false,
  }) : super(key: key);

  @override
  _ReactionsState createState() => _ReactionsState();
}

class _ReactionsState extends State<CustomReactionsWidget>
    with AutomaticKeepAliveClientMixin {
  String? reactionType = "none";
  bool isReacted = false;
  int? reactionTypeIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.post.likes?.isNotEmpty == true) {
      for (var value in widget.post.likes ?? []) {
        if (value.userId == StorageServices.authStorageValues["id"]) {
          setState(() {
            reactionType = value.reactionType;
          });
          switch (value.reactionType) {
            case "Like":
              setState(() {
                reactionTypeIndex = 0;
              });
              break;
            case "Haha":
              setState(() {
                reactionTypeIndex = 1;
              });
              break;
            case "Angry":
              setState(() {
                reactionTypeIndex = 2;
              });
              break;
            case "Love":
              setState(() {
                reactionTypeIndex = 3;
              });
              break;
            case "Sad":
              setState(() {
                reactionTypeIndex = 4;
              });
              break;
            case "Wow":
              setState(() {
                reactionTypeIndex = 5;
              });
              break;
            case "Shy":
              setState(() {
                reactionTypeIndex = 6;
              });
              break;
            default:
          }
        }
      }
    }
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .1,
          child: StorageServices.authStorageValues.isNotEmpty == true
              ? ReactionButtonToggle<String>(
                  boxPadding: const EdgeInsets.all(5.0),
                  onReactionChanged: (String? value, bool isChecked) async {
                    var postsBloc =
                        BlocProvider.of<PostsBloc>(context, listen: false);
                    if (StorageServices.authStorageValues.isNotEmpty == true) {
                      postsBloc.add(
                        LikePostEvent(
                          context: context,
                          id: widget.post.id!,
                          creatorId: widget.post.creator?.id ?? "",
                          token: StorageServices.authStorageValues["token"]!,
                          userId: StorageServices.authStorageValues["id"]!,
                          postUrl: widget.post.fileType == "video"
                              ? widget.post.file?.thumbnail ?? ""
                              : widget.post.file?.fileUrl ?? "",
                          userImageUrl:
                              StorageServices.authStorageValues["imageUrl"] ??
                                  "",
                          activityName:
                              "${StorageServices.authStorageValues["name"]} has reacted $value to your post.",
                          reactionType: value!,
                          postDetails: widget.isFromPostDetails,
                        ),
                      );

                      var resOneSignalIds = await getUserPostSignalId(
                        baseUrl: ApiConfig.baseUrl,
                        postId: widget.post.id,
                      );
                      var resData = json.decode(resOneSignalIds);
                      if (resData["message"] == "Success" &&
                          resData["data"] != []) {
                        var notification = OSCreateNotification(
                          playerIds: (resData["data"] as List)
                              .map((e) => e.toString())
                              .toList(),
                          content: (StorageServices
                                      .authStorageValues.isNotEmpty &&
                                  containLikeUserId(
                                      like: widget.post.likes, react: value))
                              ? "${StorageServices.authStorageValues["name"]} has unliked your post."
                              : "${StorageServices.authStorageValues["name"]} has reacted $value to your post.",
                          heading: "Moments",
                          bigPicture: widget.post.file?.fileUrl,
                        );
                        await OneSignal.shared.postNotification(notification);
                      }
                    } else {
                      CustomSnackbarWidget.showSnackbar(
                        ctx: context,
                        backgroundColor: Colors.red,
                        content: "Please login to react.",
                        secDuration: 2,
                        snackBarBehavior: SnackBarBehavior.floating,
                      );
                    }
                  },
                  reactions: FlutterReactions.reactions,
                  initialReaction:
                      (StorageServices.authStorageValues.isNotEmpty &&
                              containLike(like: widget.post.likes))
                          ? reactionTypeIndex != null
                              ? FlutterReactions.reactions[reactionTypeIndex!]
                              : FlutterReactions.defaultInitialReaction
                          : FlutterReactions.defaultInitialReaction,
                  selectedReaction: FlutterReactions.defaultInitialReaction,
                )
              : IconButton(
                  onPressed: () {
                    CustomSnackbarWidget.showSnackbar(
                      ctx: context,
                      backgroundColor: Colors.red,
                      content: "Please login to react.",
                      secDuration: 2,
                      snackBarBehavior: SnackBarBehavior.floating,
                    );
                  },
                  style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  )),
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.thumb_up_off_alt_rounded,
                    color: Colors.grey,
                  )),
        ),
      ),
    );
  }

  bool containLikeUserId({List<Likes>? like, String? react}) {
    for (var value in like!) {
      if (value.userId == StorageServices.authStorageValues["id"] &&
          value.reactionType == react) {
        return true;
      }
    }
    return false;
  }

  bool containLike({List<Likes>? like}) {
    for (var value in like!) {
      if (value.userId == StorageServices.authStorageValues["id"]) {
        return true;
      }
    }
    return false;
  }
}
