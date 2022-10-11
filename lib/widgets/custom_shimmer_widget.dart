import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'custom_circular_progress_indicator_widget.dart';

class CustomShimmerWidget extends StatelessWidget {
  final Widget? widget;
  const CustomShimmerWidget({
    Key? key,
    this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade50,
      enabled: true,
      period: const Duration(milliseconds: 1000),
      child: widget ?? const CustomCircularProgressIndicatorWidget(),
    );
  }
}
