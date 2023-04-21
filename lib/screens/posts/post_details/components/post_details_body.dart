import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/screens/posts/post_details/components/widgets/post_details_widget.dart';

import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/components/post_display_file.dart';
import 'package:moment/widgets/custom_all_shimmer_widget.dart';

import '../../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../../utils/file_save.dart';
import '../../../../utils/storage_services.dart';
import '../../../../widgets/custom_button_widget.dart';
import '../../../../widgets/custom_error_widget.dart';
import '../../../../widgets/custom_snackbar_widget.dart';
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
        child: MultiBlocListener(
          listeners: [
            BlocListener<PostsBloc, PostsState>(listener: (context, state) {
              if (state is PostCommentFailure) {
                CustomSnackbarWidget.showSnackbar(
                    ctx: context,
                    backgroundColor: Colors.red,
                    content: state.error,
                    secDuration: 2);
              }
              if (state is PostDeleteCommentFailure) {
                CustomSnackbarWidget.showSnackbar(
                    ctx: context,
                    backgroundColor: Colors.red,
                    content: state.error,
                    secDuration: 2);
              }
            }),
          ],
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
                      } else if (state is GetSinglePostFailure) {
                        return CustomErrorWidget(
                          message: state.error,
                          onPressed: () {
                            BlocProvider.of<PostsBloc>(context)
                                .add(GetSinglePostEvent(
                              context: context,
                              id: widget.postId,
                            ));
                          },
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
                                post:
                                    postBloc.singlePostData ?? PostModelData(),
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
                                BlocProvider.of<PostsBloc>(context)
                                    .add(HideCommentDeleteEvent());
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
                                  BlocProvider.of<PostsBloc>(context)
                                      .add(DeleteCommentEvent(
                                    context: context,
                                    activityId:
                                        BlocProvider.of<PostsBloc>(context)
                                                .deleteCommentActivityId ??
                                            [],
                                    postId: postBloc.singlePostData?.id ?? "",
                                    token: StorageServices
                                            .authStorageValues["token"] ??
                                        "",
                                    commentId:
                                        BlocProvider.of<PostsBloc>(context)
                                                .deleteCommentId ??
                                            "",
                                  ));
                                  BlocProvider.of<PostsBloc>(context)
                                      .add(HideCommentDeleteEvent());
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
                    : showBottomTextField(
                        isFromComment: widget.isFromComment, context: context),
                body: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, state) {
                    if (state is PostLoading) {
                      return CustomAllShimmerWidget.postDetailsShimmerWidget(
                        context: context,
                      );
                    } else if (state is GetSinglePostFailure) {
                      return CustomErrorWidget(
                        message: state.error,
                        onPressed: () {
                          BlocProvider.of<PostsBloc>(context)
                              .add(GetSinglePostEvent(
                            context: context,
                            id: widget.postId,
                          ));
                        },
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
                            if (StorageServices.authStorageValues.isNotEmpty ==
                                    true &&
                                StorageServices.authStorageValues["id"] ==
                                    postBloc.singlePostData?.creator)
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
                                          floatingButtonContainerColor:
                                              Colors.white,
                                          onPressed: () {
                                            postBloc.add(
                                                const ShowFileDownloadLoadingEvent());
                                            downloadVideo(
                                              ctx: context,
                                              finalProgressChanged:
                                                  (value1, value2) {
                                                setState(() {
                                                  progress = value1 / value2;
                                                });
                                              },
                                              startProgressChanged: () {
                                                setState(() {
                                                  progress = 0;
                                                });
                                              },
                                              fileName: postBloc.singlePostData
                                                  ?.file?.fileName,
                                              fileUrl: postBloc.singlePostData
                                                  ?.file?.fileUrl,
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
                                          floatingButtonContainerColor:
                                              Colors.white,
                                          onPressed: () {
                                            postBloc.add(
                                                const ShowFileDownloadLoadingEvent());
                                            saveImage(
                                              ctx: context,
                                              isFromPostDetails: true,
                                              imageUrl: postBloc.singlePostData
                                                      ?.file?.fileUrl ??
                                                  "",
                                              finalProgressChanged:
                                                  (value1, value2) {
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
      ),
    );
  }
}
