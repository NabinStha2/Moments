import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:moment/app/dimension/dimension.dart';

class CustomExtendedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit? boxFit;
  const CustomExtendedImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.boxFit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      imageUrl,
      fit: boxFit ?? BoxFit.cover,
      width: width ?? appWidth(context),
      enableLoadState: true,
      height: height,
      filterQuality: FilterQuality.high,
      handleLoadingProgress: true,
      alignment: Alignment.center,
      mode: ExtendedImageMode.gesture,
      gaplessPlayback: true,
      borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      initGestureConfigHandler: (state) {
        return GestureConfig(
          hitTestBehavior: HitTestBehavior.opaque,
          minScale: 1.0,
          animationMinScale: 0.6,
          maxScale: 4.0,
          animationMaxScale: 4.5,
          speed: 1.0,
          inertialSpeed: 100.0,
          initialScale: 1.0,
          // inPageView: true,
          cacheGesture: true,
          initialAlignment: InitialAlignment.center,
        );
      },
    );
  }
}
