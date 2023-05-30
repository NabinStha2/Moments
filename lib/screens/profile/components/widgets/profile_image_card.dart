import 'package:flutter/material.dart';

import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';

import '../../../../widgets/custom_text_widget.dart';

class ProfileImageCard extends StatelessWidget {
  const ProfileImageCard({
    Key? key,
    this.fileUrl,
    this.height,
    this.width,
    this.boxFit,
    this.alignment,
  }) : super(key: key);
  final String? fileUrl;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        fileUrl ?? "",
        fit: boxFit ?? BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return CustomText('😢Error!');
        },
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CustomCircularProgressIndicatorWidget(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        height: height ?? 400.0,
        width: width ?? appWidth(context),
        alignment: alignment ?? Alignment.center,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
