// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api, unused_import

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/bloc/activityBloc/activity_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/development/console.dart';
import 'package:moment/main.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/components/post_display_file.dart';
import 'package:moment/screens/home/home_screen.dart';
import 'package:moment/screens/main/main_screen.dart';
import 'package:moment/screens/posts/post_add/post_add_screen.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/utils/permission.dart';
import 'package:moment/utils/user_post_signal_id.dart';
import 'package:moment/widgets/custom_all_shimmer_widget.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';
import 'package:moment/widgets/custom_reactions_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:moment/widgets/video.dart';

import '../../../../utils/storage_services.dart';

class PostDetailsBody extends StatefulWidget {
  final String postId;
  const PostDetailsBody({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  _PostdetailsState createState() => _PostdetailsState();
}

class _PostdetailsState extends State<PostDetailsBody> {
  final parentController = ScrollController();
  final childController = ScrollController();
  bool loading = false;
  bool showDeleteAppBar = false;
  int? deleteIndex;
  String? deleteCommentId;
  List<String>? deleteCommentActivityId;
  double progress = 0;
  Directory? directory;
  File? saveFile;

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    consolelog(postBloc.singlePostData);
    if (deleteCommentId != null && deleteCommentActivityId != null) {
      consolelog(deleteCommentId!);
      consolelog("$deleteCommentActivityId");
    }

    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return CustomAllShimmerWidget.postDetailsShimmerWidget(
            context: context,
          );
        }
        return postBloc.singlePostData != null
            ? Container(
                color: postBloc.showCommentDelete ? Colors.black45 : Colors.transparent,
                padding: const EdgeInsets.all(10.0),
                child: Scrollbar(
                  controller: parentController,
                  interactive: true,
                  radius: const Radius.circular(20.0),
                  thickness: 6.0,
                  child: CustomScrollView(
                    controller: parentController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            SizedBox(
                              height: 500,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: PostDisplayFileBody(
                                  post: postBloc.singlePostData ?? PostModelData(),
                                  isCachedImage: false,
                                  opacity: postBloc.showCommentDelete ? 0.3 : 1.0,
                                ),
                              ),
                            ),
                            vSizedBox2,
                            vSizedBox0,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomReactionsWidget(
                                  post: postBloc.singlePostData ?? PostModelData(),
                                  isFromPostDetails: true,
                                ),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                AutoSizeText(
                                  postBloc.singlePostData!.description!,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              timeago.format(
                                DateTime.parse(postBloc.singlePostData?.createdAt.toString() ?? ""),
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                                color: showDeleteAppBar ? Colors.black12 : Colors.grey.shade200,
                              ),
                              width: double.infinity,
                              child: postBloc.singlePostData?.comments?.isNotEmpty == true
                                  ? ListView.builder(
                                      controller: childController,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: postBloc.singlePostData?.comments?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        var cmt = postBloc.singlePostData?.comments;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(vertical: 5),
                                              color: deleteIndex != null && deleteIndex == index ? Colors.white : Colors.transparent,
                                              child: InkWell(
                                                splashColor: Colors.grey,
                                                onLongPress: () {
                                                  if (StorageServices.authStorageValues.isNotEmpty == true &&
                                                      StorageServices.authStorageValues["id"] == cmt?[index].commentUserId) {
                                                    BlocProvider.of<PostsBloc>(context).add(const ShowCommentDeleteEvent());
                                                    // setState(() {
                                                    //   showDeleteAppBar = true;
                                                    //   deleteCommentId = cmt?[index].commentId;
                                                    //   deleteCommentActivityId = cmt?[index].activityId;
                                                    //   deleteIndex = index;
                                                    // });
                                                  }
                                                },
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    AutoSizeText.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "${cmt?[index].commentName!.split(":")[0]}  ",
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontFamily: GoogleFonts.montserrat().fontFamily,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: cmt?[index].commentName!.split(":")[1],
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontFamily: GoogleFonts.montserrat().fontFamily,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        AutoSizeText(
                                                          timeago.format(
                                                            DateTime.parse(cmt?[index].timestamps ?? ""),
                                                            locale: 'en_short',
                                                          ),
                                                          style: TextStyle(
                                                            color: Colors.grey.shade700,
                                                            fontSize: 8,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10.0,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            print("Reply comment");
                                                            // _showDialog(
                                                            //   replyTo: cmt?[index].commentName!.split(":")[0],
                                                            //   commentId: cmt?[index].commentId,
                                                            //   replyToUserId: cmt?[index].commentUserId,
                                                            // );
                                                          },
                                                          child: const AutoSizeText(
                                                            "Reply",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            cmt?[index].replyComments?.isNotEmpty == true
                                                ? Row(
                                                    children: [
                                                      SizedBox(
                                                        height: cmt != null ? (38 * cmt[index].replyComments!.length).toDouble() : 0.0,
                                                        child: const VerticalDivider(
                                                          thickness: 1,
                                                          width: 30,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: cmt?[index]
                                                                  .replyComments
                                                                  ?.map(
                                                                    (replyCmt) => Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        const SizedBox(
                                                                          height: 5.0,
                                                                        ),
                                                                        AutoSizeText.rich(
                                                                          TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: "${replyCmt.commentName!.split(":")[0]}  ",
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: replyCmt.commentName!.split(":")[1],
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        AutoSizeText(
                                                                          timeago.format(
                                                                            DateTime.parse(replyCmt.timestamps!),
                                                                            locale: 'en_short',
                                                                          ),
                                                                          style: TextStyle(
                                                                            color: Colors.grey.shade700,
                                                                            fontSize: 8,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                  .toList() ??
                                                              [],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            const Divider(
                                              thickness: 1,
                                              endIndent: 30,
                                              indent: 40,
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  : const Text("No Comments!"),
                            ),
                            Container(
                              height: 70,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: PoppinsText("Something went wrong! Please try again."),
              );
      },
    );
  }

//   Future<void> _showDialog({
//     String? replyTo,
//     String? commentId,
//     String? replyToUserId,
//   }) async {
//     return await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Reply to $replyTo"),
//           content: SizedBox(
//             width: 250,
//             child: showTextField(
//               isReply: true,
//               commentId: commentId,
//               replyToUserId: replyToUserId,
//             ),
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("cancel"),
//             ),
//           ],
//         );
//       },
//     );
//   }
}
