import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:moment/widgets/custom_image_details_widget.dart';
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
        // height: MediaQuery.of(context).size.height / 2.5,
        width: MediaQuery.of(context).size.width / 1.75,
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
          color: Colors.white,
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
                          imageUrl: fileUrl,
                        ),
                      ),
                    );
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.elliptical(10, 15),
                    bottomRight: Radius.elliptical(25, 18),
                    bottomLeft: Radius.elliptical(10, 15),
                  ),
                  child: Stack(children: [
                    ExtendedImage.network(
                      fileType == "video" ? thumbnail! : fileUrl,
                      fit: BoxFit.cover,
                      enableLoadState: true,
                      filterQuality: FilterQuality.high,
                      alignment: Alignment.center,
                      mode: ExtendedImageMode.gesture,
                      initGestureConfigHandler: (state) {
                        return GestureConfig(
                          minScale: 0.9,
                          animationMinScale: 0.7,
                          maxScale: 3.0,
                          animationMaxScale: 3.5,
                          speed: 1.0,
                          inertialSpeed: 100.0,
                          initialScale: 1.0,
                          inPageView: false,
                          initialAlignment: InitialAlignment.center,
                        );
                      },
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
                        child: Text(msg!),
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
