import 'package:flutter/material.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/screens/posts/post_add/components/post_add_body.dart';

import 'package:moment/widgets/custom_text_widget.dart';

class PostAddScreen extends StatelessWidget {
  const PostAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.primaryColor,
      appBar: AppBar(
        title: AppBarCookieText("Add Post"),
        automaticallyImplyLeading: false,
      ),
      body: const PostAddBody(),
    );
  }
}
