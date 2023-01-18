import 'package:flutter/material.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';

DateTime? currentBackPressTime;

Future<bool> onWillPop(BuildContext context) {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null || now.difference(currentBackPressTime ?? DateTime.now()) > const Duration(seconds: 1)) {
    currentBackPressTime = now;
    CustomSnackbarWidget.showSnackbar(ctx: context, content: "Press again to exit");
    return Future.value(false);
  }
  return Future.value(true);
}
