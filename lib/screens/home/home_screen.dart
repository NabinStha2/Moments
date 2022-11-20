import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/screens/home/components/home_body.dart';
import 'package:moment/screens/home/components/widgets/navigation_post_details_widget.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_search_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../bloc/posts_bloc/posts_bloc.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarCookieText(
          MyApp.title,
        ),
        elevation: 0.0,
        actions: [
          CustomIconButtonWidget(
            icon: const Icon(
              Icons.search,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 5.0),
            iconSize: 28.0,
            width: 30,
            onPressed: () async {
              var searchSelectedPost = await showSearch(
                context: context,
                delegate: DataSearch(
                  postList: BlocProvider.of<PostsBloc>(context).allPostModels,
                ),
              );
              if (searchSelectedPost != null) {
                navigateToPostDetails(context: context, postId: searchSelectedPost.id, isFromHome: true);
              }
            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: CustomIconButtonWidget(
        elevation: 0.0,
        icon: const Icon(Icons.arrow_upward),
        isFloatingButton: true,
        floatingButtonContainerColor: Colors.blue,
        onPressed: () {
          scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        },
      ),
      body: HomeBody(
        scController: scrollController,
      ),
    );
  }
}
