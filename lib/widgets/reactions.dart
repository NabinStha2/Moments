import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:moment/bloc/posts_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/models/post_model.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:moment/screens/news_feed_screen.dart';
import 'package:moment/widgets/flutter_reaction.dart' as FlutterReactions;

class Reactions extends StatefulWidget {
  final PostModel post;
  final bool isFromPostDetails;

  const Reactions({
    Key? key,
    required this.post,
    this.isFromPostDetails = false,
  }) : super(key: key);

  @override
  _ReactionsState createState() => _ReactionsState();
}

class _ReactionsState extends State<Reactions>
    with AutomaticKeepAliveClientMixin {
  String? reactionType = "none";
  bool isReacted = false;
  int? reactionTypeIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // for (var value in widget.post.likes!) {
    //   log("${value.userId}: ${value.reactionType}");
    // }
    if (widget.post.likes!.isNotEmpty) {
      // log("${authStorageValues!["id"]}");
      for (var value in widget.post.likes!) {
        inspect(value);
        if (value.userId == authStorageValues!["id"]) {
          log("Found: ${value.userId} ${value.reactionType}");
          setState(() {
            reactionType = value.reactionType;
          });
          switch (value.reactionType) {
            case "Like":
              log("Like");
              setState(() {
                reactionTypeIndex = 0;
              });
              break;
            case "Haha":
              log("Haha");
              setState(() {
                reactionTypeIndex = 1;
              });
              break;
            case "Angry":
              log("Angry");
              setState(() {
                reactionTypeIndex = 2;
              });
              break;
            case "Love":
              log("Love");
              setState(() {
                reactionTypeIndex = 3;
              });
              break;
            case "Sad":
              log("Sad");
              setState(() {
                reactionTypeIndex = 4;
              });
              break;
            case "Wow":
              log("Wow");
              setState(() {
                reactionTypeIndex = 5;
              });
              break;
            case "Shy":
              log("Shy");
              setState(() {
                reactionTypeIndex = 6;
              });
              break;
            default:
          }
        }
      }
    }
    log("Reaction Type: $reactionType");
    log("Reaction Type Index: $reactionTypeIndex");
    log("${widget.isFromPostDetails}");
    // super.build(context);
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .1,
          child: ReactionButtonToggle<String>(
            boxPadding: const EdgeInsets.all(5.0),
            onReactionChanged: (String? value, bool isChecked) async {
              log('Selected value: $value, isChecked: $isChecked');

              // setState(() {
              //   reactionType = value;
              // });

              if (authStorageValues != null && authStorageValues!.isNotEmpty) {
                // posts.clear();
                // NativeNotify.sendIndieNotification(
                //   831,
                //   'hsgYDUjuCgmNl9GaYuCc8I',
                //   authStorageValues!["id"]!,
                //   'Like post',
                //   'hahahahah',
                //   null,
                //   null,
                // );

                var deviceState = await OneSignal.shared.getDeviceState();

                BlocProvider.of<PostsBloc>(context).add(
                  LikePostEvent(
                    id: widget.post.id!,
                    creatorId: widget.post.creator!,
                    token: authStorageValues!["token"]!,
                    userId: authStorageValues!["id"]!,
                    postUrl: widget.post.fileType == "video"
                        ? widget.post.thumbnail
                        : widget.post.fileUrl,
                    userImageUrl: authStorageValues!["imageUrl"] ?? "",
                    activityName:
                        "${authStorageValues!["name"]} has reacted $value to your post.",
                    reactionType: value!,
                    postDetails: widget.isFromPostDetails,
                  ),
                );

                if (deviceState != null && deviceState.userId != null) {
                  var resOneSignalIds = await getUserSignalId(
                    baseUrl: baseUrl,
                    postId: widget.post.id,
                  );
                  var resData = json.decode(resOneSignalIds.body);

                  if (resOneSignalIds.statusCode == 200) {
                    var notification = OSCreateNotification(
                      playerIds: (resData["oneSignalUserId"] as List)
                          .map((e) => e.toString())
                          .toList(),
                      content: (authStorageValues != null &&
                              containLikeUserId(
                                  like: widget.post.likes, react: value))
                          ? "${authStorageValues!["name"]} has unliked your post."
                          : "${authStorageValues!["name"]} has reacted $value to your post.",
                      heading: "Moments",
                      bigPicture: widget.post.fileUrl,
                    );

                    await OneSignal.shared.postNotification(notification);

                    // final uri = Uri.https(baseUrl,
                    //     "/api/SendNotificationToDevice");
                    // final uri = Uri.http(baseUrl,
                    //     "/api/SendNotificationToDevice");
                    // final response = await http.post(
                    //   uri,
                    //   headers: {
                    //     HttpHeaders.contentTypeHeader:
                    //         "application/json ; charset=utf-8",
                    //   },
                    //   body:
                    //       json.encode(<String, dynamic>{
                    //     "devices":
                    //         resData["oneSignalUserId"],
                    //     "msg":
                    //         "${authStorageValues!["name"]} has liked your post.",
                    //   }),
                    // );
                    // inspect(response);
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  content: Text("First Sign In!"),
                ));
              }
            },
            reactions: FlutterReactions.reactions,
            initialReaction: (authStorageValues != null &&
                    containLike(like: widget.post.likes))
                ? reactionTypeIndex != null
                    ? FlutterReactions.reactions[reactionTypeIndex!]
                    : FlutterReactions.defaultInitialReaction
                : FlutterReactions.defaultInitialReaction,
            selectedReaction: FlutterReactions.defaultInitialReaction,
          ),
        ),
      ),
    );
  }

  bool containLikeUserId({List<Likes>? like, String? react}) {
    for (var value in like!) {
      // inspect(value);
      if (value.userId == authStorageValues!["id"] &&
          value.reactionType == react) {
        log("Found true");
        return true;
      }
    }
    return false;
  }

  bool containLike({List<Likes>? like}) {
    for (var value in like!) {
      if (value.userId == authStorageValues!["id"]) {
        log("Found true: ${value.userId}");
        return true;
      }
    }
    return false;
  }
}
