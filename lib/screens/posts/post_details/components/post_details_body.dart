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
import 'package:moment/screens/posts/post_details/components/comment_list_body.dart';
import 'package:moment/screens/posts/post_details/components/comment_reply_body.dart';
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
import 'widgets/show_bottom_text_field_widget.dart';

class PostDetailsBody extends StatelessWidget {
  final String postId;
  const PostDetailsBody({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      CustomExpandableText(
                        text: postBloc.singlePostData!.description!,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                      vSizedBox1,
                      Text(
                        timeago.format(
                          DateTime.parse(postBloc.singlePostData?.createdAt.toString() ?? ""),
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      vSizedBox0,
                      vSizedBox1,
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: postBloc.showCommentDelete ? Colors.black12 : Colors.grey.shade200,
                        ),
                        width: double.infinity,
                        child: postBloc.singlePostData?.comments?.isNotEmpty == true ? const CommentListBody() : const Text("No Comments!"),
                      ),
                      vSizedBox3,
                      vSizedBox3,
                      vSizedBox3,
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
}
