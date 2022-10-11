import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:share_plus/share_plus.dart';

import 'package:moment/development/console.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/components/widgets/navigation_post_details_widget.dart';
import 'package:moment/utils/dynamic_link.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_all_shimmer_widget.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';
import 'package:moment/widgets/custom_reactions_widget.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/video.dart';

import '../../../bloc/postsBloc/posts_bloc.dart';

class HomeBody extends StatelessWidget {
  final ScrollController scController;
  const HomeBody({
    Key? key,
    required this.scController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<PostsBloc, PostsState>(
      listener: (context, state) {
        if (state is PostCreated) {
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.grey, content: "Post created successfully", milliDuration: 400);
        }
        if (state is PostDeleted) {
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.grey, content: "Post deleted Successfully", milliDuration: 400);
        }
        if (state is PostUpdated) {
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.grey, content: "Post updated Successfully", milliDuration: 400);
        }
        if (state is PostUpdateLoading) {
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.grey, content: "Updating post... Please wait...", secDuration: 60);
        }
        if (state is PostDeleteLoading) {
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.grey, content: "Deleting post... Please wait...", secDuration: 60);
        }
        if (state is PostLoading) {
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.grey, content: "Loading Posts...", milliDuration: 400);
        }
        if (state is PostError) {
          CustomSnackbarWidget.showSnackbar(ctx: context, backgroundColor: Colors.red.shade300, content: state.error, milliDuration: 400);
        }
        if (state is PostPageChangedLoadedState) {
          postBloc.add(GetPostsEvent(context: context, page: postBloc.currentPage));
        }
      },
      builder: (context, state) {
        if (state is PostLoading && BlocProvider.of<PostsBloc>(context).postModels.isEmpty) {
          return CustomAllShimmerWidget.allPostsShimmerWidget();
        }
        if (state is PostError || BlocProvider.of<PostsBloc>(context).postModels.isEmpty == true) {
          return Center(
            child: CustomIconButtonWidget(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                postBloc.add(PostPageChangeEvent(context: context, pageNumber: 1));
              },
              color: Colors.black,
              iconSize: 40,
              elevation: 0.0,
            ),
          );
        }
        if (state is CreatorPostsLoaded || state is CreatorPostError) {
          postBloc.add(RefreshPostsEvent());
          postBloc.add(PostPageChangeEvent(context: context, pageNumber: 1));
        }
        return BlocProvider.of<PostsBloc>(context).postModels.isNotEmpty
            ? RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 1000), () {});
                  postBloc.add(RefreshPostsEvent());
                  postBloc.add(PostPageChangeEvent(context: context, pageNumber: 1));
                },
                child: NotificationListener<ScrollUpdateNotification>(
                  onNotification: (ScrollUpdateNotification scrollNotification) {
                    if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
                      if (postBloc.currentPage + 1 > BlocProvider.of<PostsBloc>(context).pages) {
                        CustomSnackbarWidget.showSnackbar(
                          ctx: context,
                          backgroundColor: Colors.grey,
                          content: "No more Posts.",
                          milliDuration: 400,
                        );
                      } else {
                        postBloc.add(PostPageChangeEvent(pageNumber: postBloc.currentPage + 1, context: context));
                      }
                    }
                    return true;
                  },
                  child: ListView.builder(
                    clipBehavior: Clip.antiAlias,
                    physics: const BouncingScrollPhysics(),
                    controller: scController,
                    primary: false,
                    itemCount: BlocProvider.of<PostsBloc>(context).postModels.length,
                    itemBuilder: (context, index) {
                      final PostModelData post = BlocProvider.of<PostsBloc>(context).postModels[index];
                      if (BlocProvider.of<PostsBloc>(context).postModels.isNotEmpty) {
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.all(10.0),
                          elevation: 2.0,
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 5.0,
                                    ),
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                BlocProvider.of<PostsBloc>(context).postModels[index].name ?? "",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                GetTimeAgo.parse(
                                                  DateTime.parse(post.createdAt.toString()),
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          (StorageServices.authStorageValues["id"] == post.creator)
                                              ? PopupMenuButton(
                                                  onSelected: (value) {
                                                    if (value as String == "edit") {
                                                      customModalBottomSheetWidget(post: post, ctx: context);
                                                    } else {
                                                      BlocProvider.of<PostsBloc>(context).add(
                                                        DeletePostEvent(
                                                          isFromActivity: false,
                                                          isFromProfile: false,
                                                          isFromVisit: false,
                                                          context: context,
                                                          id: post.id!,
                                                          token: StorageServices.authStorageValues["token"] ?? "",
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.more_vert_rounded,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  ),
                                                  splashRadius: 20,
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: "edit",
                                                      child: Text("Edit"),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: "delete",
                                                      child: Text("Delete"),
                                                    ),
                                                  ],
                                                )
                                              : Container()
                                        ]),
                                  ),
                                  Opacity(
                                    opacity: 1,
                                    child: post.fileType == "video"
                                        ? Video(
                                            url: post.file?.fileUrl ?? "",
                                            thumbnail: post.file?.thumbnail ?? "",
                                          )
                                        : post.file?.fileUrl != ""
                                            ? GestureDetector(
                                                onTap: () => {navigateToPostDetails(context: context, post: post)},
                                                child: Image.network(
                                                  post.file?.fileUrl ?? "",
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, object, stackTrace) {
                                                    // inspect(object);
                                                    // print(object);
                                                    return Container(
                                                      height: 500.0,
                                                      alignment: Alignment.center,
                                                      child: const Center(
                                                        child: Text(
                                                          "Something went wrong with Image loading!",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child;
                                                    }
                                                    return Container(
                                                      height: 500.0,
                                                      alignment: Alignment.center,
                                                      child: Center(
                                                        child: CircularProgressIndicator(
                                                          value: loadingProgress.expectedTotalBytes != null
                                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  height: 500.0,
                                                  width: size.width,
                                                  alignment: Alignment.center,
                                                  isAntiAlias: true,
                                                  filterQuality: FilterQuality.high,
                                                ),
                                              )
                                            : Image.network(
                                                "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                                                fit: BoxFit.cover,
                                                height: 500.0,
                                                width: size.width,
                                                alignment: Alignment.center,
                                                isAntiAlias: true,
                                                filterQuality: FilterQuality.high,
                                              ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: InkWell(
                                      onTap: () => {navigateToPostDetails(context: context, post: post)},
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ExpandableText(
                                              post.description!,
                                              animation: true,
                                              linkEllipsis: true,
                                              expanded: true,
                                              expandText: 'show more',
                                              collapseText: 'show less',
                                              maxLines: 3,
                                              linkColor: Colors.grey,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CustomReactionsWidget(
                                          post: post,
                                        ),
                                        Text(
                                          post.likes?.length.toString() ?? "0",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => {navigateToPostDetails(context: context, post: post, isFromComment: true)},
                                          splashColor: Colors.grey,
                                          splashRadius: 20.0,
                                          icon: const FaIcon(
                                            FontAwesomeIcons.commentDots,
                                          ),
                                        ),
                                        Text(
                                          post.comments?.length.toString() ?? "0",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            var link = await FirebaseDynamicLinkService.createDynamicLink(postId: post.id);
                                            // print("Link: $link");
                                            Share.share(link, subject: "Moments post.");
                                          },
                                          splashColor: Colors.grey,
                                          splashRadius: 20.0,
                                          icon: const FaIcon(
                                            FontAwesomeIcons.share,
                                            color: Colors.grey,
                                            size: 25.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: Text("No Posts Yet."));
                      }
                    },
                  ),
                ),
              )
            : const Center(child: Text("No Posts Yet."));
      },
    );
  }
}

// void customBlocListenerWidget(
//     {required BuildContext context,
//     required dynamic state,
//     required dynamic runningState,
//     Color? snackBarColor,
//     String? snackBarContent,
//     int? milliDuration,
//     int? secDuration}) {
//   CustomSnackbarWidget.showSnackbar(
//     ctx: context,
//     backgroundColor: snackBarColor ?? Colors.grey,
//     content: snackBarContent ?? "",
//     milliDuration: milliDuration,
//     secDuration: secDuration,
//   );
// }
