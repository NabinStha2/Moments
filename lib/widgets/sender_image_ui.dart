import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/widgets/custom_extended_image_widget.dart';
import 'package:moment/widgets/custom_image_details_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:moment/widgets/video_details.dart';

class SenderImageUi extends StatelessWidget {
  const SenderImageUi({
    Key? key,
    this.msg,
    this.time,
    required this.fileUrl,
    required this.fileType,
    this.thumbnail,
  }) : super(key: key);

  final String fileUrl;
  final String fileType;
  final String? msg;
  final String? time;
  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    log("sender filePath: $fileUrl");
    log("sender fileType: $fileType");
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          // color: Colors.red,
        ),
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(10, 15),
              bottomRight: Radius.elliptical(25, 18),
              bottomLeft: Radius.elliptical(10, 15),
            ),
          ),
          color: MColors.primaryGrayColor80,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GestureDetector(
            onTap: () {
              fileType == "video"
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoDetails(
                          videoUrl: fileUrl,
                        ),
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomImageDetails(
                          isSend: true,
                          imageUrl: fileUrl,
                        ),
                      ),
                    );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.elliptical(10, 15),
                    bottomRight: Radius.elliptical(25, 18),
                    bottomLeft: Radius.elliptical(10, 15),
                  ),
                  child: Stack(children: [
                    Hero(
                      tag: "send",
                      child: CustomExtendedImageWidget(
                        imageUrl:
                            fileType == "video" ? thumbnail ?? "" : fileUrl,
                      ),
                    ),
                    fileType == "video"
                        ? Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            top: 0,
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoDetails(
                                      videoUrl: fileUrl,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(),
                  ]),
                ),
                msg != ""
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText(
                          msg!,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
