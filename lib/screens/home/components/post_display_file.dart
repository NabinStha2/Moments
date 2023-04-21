import 'package:flutter/material.dart';
import 'package:moment/app/dimension/dimension.dart';

import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/home/components/widgets/navigation_post_details_widget.dart';
import 'package:moment/widgets/custom_cached_network_image_widget.dart';
import 'package:moment/widgets/custom_extended_image_widget.dart';
import 'package:moment/widgets/video.dart';

import '../../../widgets/custom_circular_progress_indicator_widget.dart';
import '../../../widgets/custom_text_widget.dart';

class PostDisplayFileBody extends StatelessWidget {
  final PostModelData post;
  final bool? isCachedImage;
  final double? opacity;
  const PostDisplayFileBody({
    Key? key,
    required this.post,
    this.isCachedImage = true,
    this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity ?? 1,
      child: post.fileType != null && post.fileType == "video"
          ? Video(
              url: post.file?.fileUrl ?? "",
              thumbnail: post.file?.thumbnail ?? "",
            )
          : post.file?.fileUrl != ""
              ? isCachedImage == true
                  ? GestureDetector(
                      onTap: () => {

                        navigateToPostDetails(context: context, postId: post.id)},
                      child: Image.network(
                        post.file?.fileUrl ?? "",
                        errorBuilder: (context, url, error) {
                          return Container(
                            height: 500.0,
                            alignment: Alignment.center,
                            child: Center(
                              child: PoppinsText(
                                error.toString(),
                                // ?? "Something went wrong with Image loading!",
                                color: Colors.red,
                                fontSize: 8.0,
                              ),
                            ),
                          );
                        },
                        filterQuality: FilterQuality.high,
                        frameBuilder: (BuildContext context, Widget child, int? frame, bool? wasSynchronouslyLoaded) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: child,
                          );
                        },
                        loadingBuilder: (BuildContext context, Widget? child, ImageChunkEvent? loadingProgress) {
                          return loadingProgress != null && loadingProgress.expectedTotalBytes != null
                              ? Center(
                                  child: SizedBox(
                                    height: 400,
                                    child: CustomCircularProgressIndicatorWidget(
                                      value: loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!,
                                    ),
                                  ),
                                )
                              : Center(child: child);
                        },
                        // loadingBuilder: (context, url, progress) => Center(
                        //   child: CustomCircularProgressIndicatorWidget(
                        //     value: (progress?.cumulativeBytesLoaded ?? 0) / (progress?.expectedTotalBytes ?? 1),
                        //   ),
                        // ),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    )
                  // child: CustomCachedNetworkImageWidget(imageUrl: post.file?.fileUrl ?? ""))
                  : CustomExtendedImageWidget(imageUrl: post.file?.fileUrl ?? "")
              : const CustomCachedNetworkImageWidget(
                  imageUrl:
                      "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1"),
    );
  }
}
