import 'package:flutter/material.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class CustomSnackbarWidget {
  static showSnackbar(
      {required BuildContext ctx,
      String? content,
      int? secDuration,
      int? milliDuration,
      Color? backgroundColor,
      Color? textColor,
      SnackBarBehavior? snackBarBehavior}) {
    return ScaffoldMessenger.of(ctx)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        elevation: 0.0,
        duration: secDuration != null ? Duration(seconds: secDuration.toInt()) : Duration(milliseconds: milliDuration ?? 1500),
        backgroundColor: backgroundColor ?? Colors.green,
        behavior: snackBarBehavior ?? SnackBarBehavior.fixed,
        content: PoppinsText(
          color: textColor?? Colors.white,
          content ?? "",
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ));
  }
}
