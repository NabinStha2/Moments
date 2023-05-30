import 'package:flutter/material.dart';
import 'package:moment/app/colors.dart';

import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/utils/file_save.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_extended_image_widget.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class CustomImageDetails extends StatelessWidget {
  final String imageUrl;
  final bool isSend;

  const CustomImageDetails({
    Key? key,
    required this.imageUrl,
    this.isSend = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          imageUrl != ""
              ? Hero(
                  tag: isSend ? "send" : "receive",
                  child: CustomExtendedImageWidget(
                    height: appHeight(context),
                    imageUrl: imageUrl,
                  ),
                )
              : Hero(
                  tag: isSend ? "send" : "receive",
                  child: const CustomExtendedImageWidget(
                    imageUrl:
                        "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                  ),
                ),
          Container(
            height: appHeight(context),
            width: appWidth(context),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    CustomSnackbarWidget.showSnackbar(
                        content: "Wait until image saved.",
                        milliDuration: 400,
                        ctx: context,
                        backgroundColor: MColors.primaryGrayColor50);
                    saveImage(
                      ctx: context,
                      imageUrl: imageUrl,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    width: 250,
                    decoration: BoxDecoration(
                      color: MColors.primaryGrayColor80,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Column(
                      children: [
                        CustomText("Save", color: Colors.white),
                        CustomText("Image will be saved to gallary",
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
                vSizedBox1,
                CustomElevatedButtonWidget(
                  width: 250,
                  onPressed: () {
                    RouteNavigation.back(context);
                  },
                  backgroundColor: Colors.redAccent,
                  child: CustomText(
                    "Cancel",
                    color: Colors.white,
                  ),
                ),
                vSizedBox3,
                vSizedBox1,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
