import 'package:flutter/material.dart';

class CustomCircularProgressIndicatorWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? value;
  final double? strokeWidth;
  const CustomCircularProgressIndicatorWidget({
    Key? key,
    this.width,
    this.height,
    this.value,
    this.strokeWidth,
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
            ),
          ),
        ],
      ),
    );
  }
}
