import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import 'custom_image_error_widget.dart';

class CustomCachedNetworkImageWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String? errorText;
  final String imageUrl;
  final Color? errorTextColor;
  final Curve? curves;
  final Duration? duration;
  final Widget? placeholderWidget;
  const CustomCachedNetworkImageWidget({
    Key? key,
    this.height,
    this.width,
    this.errorText,
    required this.imageUrl,
    this.errorTextColor,
    this.curves,
    this.duration,
    this.placeholderWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: width ?? appWidth(context),
      height: height,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      errorWidget: (context, url, error) {
        return Container(
          color: Colors.grey.shade300,
          child: CustomImageErrorWidget(
            width: width ?? 50,
            height: height ?? 50,
          ),
        );
      },
      fit: BoxFit.cover,
      fadeInCurve: curves ?? Curves.fastOutSlowIn,
      fadeInDuration: duration ?? const Duration(milliseconds: 600),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CustomCircularProgressIndicatorWidget(
          value: progress.progress,
        ),
      ),
      imageUrl: imageUrl,
    );
  }
}
