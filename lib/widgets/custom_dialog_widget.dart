import 'package:flutter/material.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';

import 'custom_text_widget.dart';

class CustomDialogs {
  static bool isShowDialog = true;
  static showCustomFullLoadingDialog(
      {required BuildContext ctx, String? title}) {
    return showDialog(
      context: ctx,
      useSafeArea: true,
      barrierDismissible: false,
      barrierColor: const Color(0xff141A31).withOpacity(0.6),
      builder: (_) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomCircularProgressIndicatorWidget(
                  height: 30,
                  width: 30,
                  strokeWidth: 2,
                ),
                const SizedBox(height: 10),
                PoppinsText(
                  title ?? "Processing...",
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static showCustomActionDialog(
      {required BuildContext ctx, String? message, String? imageUrl}) {
    return showDialog(
      context: ctx,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Dialog(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(ctx).size.width,
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ClipOval(
                      child: Image.network(
                        imageUrl ??
                            "https://uploads.sitepoint.com/wp-content/uploads/2015/12/1450973046wordpress-errors.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    PoppinsText(message ?? ""),
                    const SizedBox(
                      height: 10.0,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: PoppinsText(
                        "Ok",
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
