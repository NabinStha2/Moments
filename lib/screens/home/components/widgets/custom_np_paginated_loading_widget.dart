import 'package:flutter/material.dart';

import '../../../../widgets/custom_text_widget.dart';

class CustomNoPaginatedLoadingWidget extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final String? title;

  const CustomNoPaginatedLoadingWidget({
    Key? key,
    this.margin,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 14),
      child: CustomText(
        "No more $title to Load.",
        fontSize: 14.0,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
