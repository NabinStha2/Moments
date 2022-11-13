import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/screens/posts/post_details/components/post_details_body.dart';
import 'package:moment/screens/posts/post_details/components/widgets/show_bottom_text_field_widget.dart';
import 'package:moment/screens/posts/post_details/components/widgets/will_pop_scope_post_details_body.dart';
import 'package:moment/utils/file_save.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_button_widget.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  final bool isFromComment;
  final bool isFromProfile;
  final bool isFromHome;
  final bool isFromProfileVisit;
  final bool isFromActivity;
  final String? userVisitId;
  const PostDetailsScreen({
    Key? key,
    required this.postId,
    this.isFromComment = false,
    this.isFromProfile = false,
    this.isFromHome = false,
    this.isFromProfileVisit = false,
    this.isFromActivity = false,
    this.userVisitId,
  }) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
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
        WillPopScopePostDetailsBody(
          context: context,
          isFromActivity: widget.isFromActivity,
          isFromProfile: widget.isFromProfile,
          isFromProfileVisit: widget.isFromProfileVisit,
          userVisitId: widget.userVisitId,
        );
        RouteNavigation.back(context);
        return true;
      },
      child: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          if (state is ShowCommentDeleteState) {
            return Scaffold(
              appBar: AppBar(
                leading: CustomIconButtonWidget(
                  onPressed: () {
                    BlocProvider.of<PostsBloc>(context).add(HideCommentDeleteEvent());
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
                actions: [
                  CustomIconButtonWidget(
                    icon: const Icon(Icons.delete),
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
              body: PostDetailsBody(
                postId: widget.postId,
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
            appBar: AppBar(
              title: const Text("Moments"),
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
                          : IconButton(
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
                                color: Colors.white,
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
                                color: Colors.white,
                              ),
                            )
              ],
              leading: CustomIconButtonWidget(
                onPressed: () {
                  WillPopScopePostDetailsBody(
                    context: context,
                    isFromActivity: widget.isFromActivity,
                    isFromProfile: widget.isFromProfile,
                    isFromProfileVisit: widget.isFromProfileVisit,
                    userVisitId: widget.userVisitId,
                  );
                  RouteNavigation.back(context);
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            body: PostDetailsBody(
              postId: widget.postId,
            ),
          );
        },
      ),
    );
  }
}
