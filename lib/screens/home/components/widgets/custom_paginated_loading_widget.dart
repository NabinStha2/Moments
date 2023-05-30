import 'package:flutter/material.dart';

import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';

import '../../../../widgets/custom_text_widget.dart';

class CustomPaginatedLoadingWidget extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final String? title;

  const CustomPaginatedLoadingWidget({
    Key? key,
    this.margin,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          const CustomCircularProgressIndicatorWidget(),
          CustomText(
            "Loading for $title.",
            fontSize: 14.0,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
