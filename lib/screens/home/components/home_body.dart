import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/bloc/home_bloc/home_bloc.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/components/post_card_body.dart';
import 'package:moment/screens/home/components/widgets/custom_np_paginated_loading_widget.dart';
import 'package:moment/screens/home/components/widgets/custom_paginated_loading_widget.dart';
import 'package:moment/widgets/custom_all_shimmer_widget.dart';
import 'package:moment/widgets/custom_error_widget.dart';

import '../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../bloc/profile_posts_bloc/profile_posts_bloc.dart';
import '../../../utils/storage_services.dart';
import '../../../widgets/custom_snackbar_widget.dart';

class HomeBody extends StatelessWidget {
  final ScrollController scController;
  const HomeBody({
    Key? key,
    required this.scController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var postBloc = BlocProvider.of<PostsBloc>(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(listener: (context, state) {
          if (state is HomeCurrentIndexChangedState) {
            state.index == 1
                ? BlocProvider.of<PostsBloc>(context).add(PostClearValueEvent())
                : null;
          }
        }),
        BlocListener<PostsBloc, PostsState>(listener: (context, state) {
          if (state is PostPageChangedLoadedState) {
            postBloc.add(
                GetPostsEvent(context: context, page: postBloc.currentPage));
          }
          if (state is PostDeleted) {
            BlocProvider.of<ProfilePostsBloc>(context).add(
              GetProfilePostsEvent(
                context: context,
                creator: StorageServices.authStorageValues["id"] ?? "",
              ),
            );
          }
          if (state is PostUpdateFailure) {
            CustomSnackbarWidget.showSnackbar(
              ctx: context,
              content: state.error,
              backgroundColor: Colors.redAccent,
              secDuration: 2,
            );
          }
        }),
      ],
      child: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          if (state is PostLoading && postBloc.postModels.isEmpty == true) {
            return CustomAllShimmerWidget.allPostsShimmerWidget();
          }
          if (state is GetAllPostFailure) {
            return CustomErrorWidget(
              message: state.error,
              onPressed: () {
                postBloc.add(RefreshPostsEvent());
                postBloc
                    .add(PostPageChangeEvent(context: context, pageNumber: 1));
              },
            );
          }
          return postBloc.postModels.isNotEmpty
              ? NotificationListener<ScrollUpdateNotification>(
                  onNotification:
                      (ScrollUpdateNotification scrollNotification) {
                    if (scrollNotification.metrics.pixels ==
                            scrollNotification.metrics.maxScrollExtent &&
                        postBloc.currentPage + 1 <= postBloc.pages) {
                      postBloc.add(PostPageChangeEvent(
                          pageNumber: postBloc.currentPage + 1,
                          context: context));
                    }
                    return true;
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 1000), () {});
                            postBloc.add(RefreshPostsEvent());
                            postBloc.add(PostPageChangeEvent(
                                context: context, pageNumber: 1));
                          },
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            controller: scController,
                            child: Column(
                              children: [
                                ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: postBloc.postModels.length,
                                  itemBuilder: (context, index) {
                                    final PostModelData post =
                                        postBloc.postModels[index];
                                    return PostCardBody(
                                        index: index, post: post);
                                  },
                                ),
                                postBloc.currentPage < postBloc.pages
                                    ? const CustomPaginatedLoadingWidget(
                                        title: "Post",
                                      )
                                    : const CustomNoPaginatedLoadingWidget(
                                        title: "Post",
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : CustomErrorWidget(
                  message: "No Posts Yet!",
                  onPressed: () {
                    postBloc.add(RefreshPostsEvent());
                    postBloc.add(
                        PostPageChangeEvent(context: context, pageNumber: 1));
                  },
                );
        },
      ),
    );
  }
}
