// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../app/colors.dart';

class CustomCircularProgressIndicatorWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? value;
  final double? strokeWidth;
  final Color? color;
  const CustomCircularProgressIndicatorWidget({
    Key? key,
    this.width,
    this.height,
    this.value,
    this.strokeWidth,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width ?? 15,
            height: height ?? 15,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth ?? 2,
              color: color ?? MColors.primaryGrayColor50,
            ),
          ),
        ],
      ),
    );
  }
}
