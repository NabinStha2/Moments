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
import 'package:moment/screens/posts/post_details/components/widgets/post_details_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/development/console.dart';
import 'package:moment/main.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/components/post_display_file.dart';
import 'package:moment/screens/home/home_screen.dart';
import 'package:moment/screens/main/main_screen.dart';
import 'package:moment/screens/posts/post_add/post_add_screen.dart';
import 'package:moment/screens/posts/post_details/components/comment_list_body.dart';
import 'package:moment/screens/posts/post_details/components/comment_reply_body.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/utils/permission.dart';
import 'package:moment/utils/user_post_signal_id.dart';
import 'package:moment/widgets/custom_all_shimmer_widget.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';
import 'package:moment/widgets/custom_reactions_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:moment/widgets/video.dart';

import '../../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../../utils/file_save.dart';
import '../../../../utils/storage_services.dart';
import '../../../../widgets/custom_button_widget.dart';
import '../../../../widgets/custom_circular_progress_indicator_widget.dart';
import 'widgets/show_bottom_text_field_widget.dart';

class PostDetailsBody extends StatefulWidget {
  final String postId;
  final bool isFromComment;
  const PostDetailsBody({
    Key? key,
    required this.postId,
    required this.isFromComment,
  }) : super(key: key);

  @override
  State<PostDetailsBody> createState() => _PostDetailsBodyState();
}

class _PostDetailsBodyState extends State<PostDetailsBody> {
  double? progress;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PostsBloc>(context).add(GetSinglePostEvent(
      context: context,
      id: widget.postId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        postBloc.commentController.clear();
        RouteNavigation.back(context);
        return true;
      },
      child: SafeArea(
        top: true,
        bottom: false,
        child: BlocBuilder<PostsBloc, PostsState>(
          builder: (context, state) {
            if (state is ShowCommentDeleteState) {
              return Scaffold(
                body: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, state) {
                    if (state is PostLoading) {
                      return CustomAllShimmerWidget.postDetailsShimmerWidget(
                        context: context,
                      );
                    } else if (state is PostError) {
                      return Center(
                        child: PoppinsText(state.error),
                      );
                    }
                    return CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          expandedHeight: 400,
                          backgroundColor: Colors.grey.shade400,
                          flexibleSpace: FlexibleSpaceBar(
                            background: PostDisplayFileBody(
                              post: postBloc.singlePostData ?? PostModelData(),
                              isCachedImage: false,
                              opacity: postBloc.showCommentDelete ? 0.3 : 1.0,
                            ),
                            collapseMode: CollapseMode.pin,
                          ),
                          leading: CustomIconButtonWidget(
                            padding: EdgeInsets.zero,
                            isFloatingButton: true,
                            floatingButtonContainerColor: Colors.white,
                            onPressed: () {
                              BlocProvider.of<PostsBloc>(context).add(HideCommentDeleteEvent());
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                          actions: [
                            CustomIconButtonWidget(
                              padding: EdgeInsets.zero,
                              isFloatingButton: true,
                              floatingButtonContainerColor: Colors.white,
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                BlocProvider.of<PostsBloc>(context).add(DeleteCommentEvent(
                                  context: context,
                                  activityId: BlocProvider.of<PostsBloc>(context).deleteCommentActivityId ?? [],
                                  postId: postBloc.singlePostData?.id ?? "",
                                  token: StorageServices.authStorageValues["token"] ?? "",
                                  commentId: BlocProvider.of<PostsBloc>(context).deleteCommentId ?? "",
                                ));
                                BlocProvider.of<PostsBloc>(context).add(HideCommentDeleteEvent());
                              },
                            ),
                          ],
                        ),
                        const SliverToBoxAdapter(child: PostDetailsWidget()),
                      ],
                    );
                  },
                ),
              );
            }
            return Scaffold(
              bottomSheet: state is ShowReplyCommentState
                  ? showBottomTextField(
                      isReply: true,
                      context: context,
                      replyTo: state.replyTo,
                      commentId: state.commentId,
                      replyToUserId: state.replyToUserId,
                    )
                  : showBottomTextField(isFromComment: widget.isFromComment, context: context),
              body: BlocBuilder<PostsBloc, PostsState>(
                builder: (context, state) {
                  if (state is PostLoading) {
                    return CustomAllShimmerWidget.postDetailsShimmerWidget(
                      context: context,
                    );
                  } else if (state is PostError) {
                    return Center(
                      child: PoppinsText(state.error),
                    );
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        stretch: true,
                        floating: true,
                        expandedHeight: 400,
                        backgroundColor: Colors.grey.shade400,
                        flexibleSpace: FlexibleSpaceBar(
                          background: PostDisplayFileBody(
                            post: postBloc.singlePostData ?? PostModelData(),
                            isCachedImage: false,
                            opacity: postBloc.showCommentDelete ? 0.3 : 1.0,
                          ),
                          collapseMode: CollapseMode.pin,
                        ),
                        automaticallyImplyLeading: false,
                        actions: [
                          if (StorageServices.authStorageValues.isNotEmpty == true &&
                              StorageServices.authStorageValues["id"] == postBloc.singlePostData?.creator)
                            postBloc.singlePostData?.fileType == "video"
                                ? state is ShowFileDownloadState
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            value: progress,
                                          ),
                                        ),
                                      )
                                    : CustomIconButtonWidget(
                                        padding: EdgeInsets.zero,
                                        isFloatingButton: true,
                                        floatingButtonContainerColor: Colors.white,
                                        onPressed: () {
                                          postBloc.add(const ShowFileDownloadLoadingEvent());
                                          downloadVideo(
                                            ctx: context,
                                            finalProgressChanged: (value1, value2) {
                                              setState(() {
                                                progress = value1 / value2;
                                              });
                                            },
                                            startProgressChanged: () {
                                              setState(() {
                                                progress = 0;
                                              });
                                            },
                                            fileName: postBloc.singlePostData?.file?.fileName,
                                            fileUrl: postBloc.singlePostData?.file?.fileUrl,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.download_rounded,
                                          color: Colors.black,
                                        ),
                                      )
                                : state is ShowFileDownloadState
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            value: progress,
                                          ),
                                        ),
                                      )
                                    : CustomIconButtonWidget(
                                        padding: EdgeInsets.zero,
                                        isFloatingButton: true,
                                        floatingButtonContainerColor: Colors.white,
                                        onPressed: () {
                                          postBloc.add(const ShowFileDownloadLoadingEvent());
                                          saveImage(
                                            ctx: context,
                                            isFromPostDetails: true,
                                            imageUrl: postBloc.singlePostData?.file?.fileUrl ?? "",
                                            finalProgressChanged: (value1, value2) {
                                              setState(() {
                                                progress = value1 / value2;
                                              });
                                            },
                                            startProgressChanged: () {
                                              setState(() {
                                                progress = 0;
                                              });
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.download_rounded,
                                          color: Colors.black,
                                        ),
                                      )
                        ],
                        leading: CustomIconButtonWidget(
                          padding: EdgeInsets.zero,
                          isFloatingButton: true,
                          floatingButtonContainerColor: Colors.white,
                          onPressed: () {
                            postBloc.commentController.clear();
                            RouteNavigation.back(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: PostDetailsWidget(),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
