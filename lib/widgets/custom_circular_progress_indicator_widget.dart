import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomCircularProgressIndicatorWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? strokeWidth;
  const CustomCircularProgressIndicatorWidget(
      {Key? key, this.width, this.height, this.strokeWidth})
      : super(key: key);

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
              strokeWidth: strokeWidth ?? 2,
            ),
          ),
        ],
      ),
    );
  }
}
