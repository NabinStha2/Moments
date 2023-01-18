import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/screens/profile/components/widgets/profile_image_card.dart';

import '../../../bloc/posts_bloc/posts_bloc.dart';
import '../../posts/post_details/post_details_screen.dart';

class ProfileVideoCard extends StatelessWidget {
  const ProfileVideoCard({
    Key? key,
    this.fileUrlThumbnail,
    this.postId,
  }) : super(key: key);
  final String? fileUrlThumbnail;
  final String? postId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProfileImageCard(
          fileUrl: fileUrlThumbnail,
        ),
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: BlocProvider.of<PostsBloc>(context),
                    child: PostDetailsScreen(
                      postId: postId ?? "",
                      isFromComment: false,
                    ),
                  ),
                ),
              );
            },
            splashRadius: 2,
            icon: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 35.0,
            ),
          ),
        )
      ],
    );
  }
}
