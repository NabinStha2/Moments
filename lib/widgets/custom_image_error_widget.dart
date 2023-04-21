import 'package:flutter/material.dart';

class CustomImageErrorWidget extends StatelessWidget {
  final double? height;
  final double? width;
  const CustomImageErrorWidget({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: const Center(
        child: Icon(
          Icons.error,
          color: Colors.red,
        ),
      ),
    );
  }
}
