import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:moment/widgets/custom_extended_image_widget.dart';
import 'package:moment/widgets/custom_image_details_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:moment/widgets/video_details.dart';

class ReceiverImageUi extends StatelessWidget {
  const ReceiverImageUi({
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.elliptical(25, 18),
              topRight: Radius.elliptical(10, 15),
              bottomLeft: Radius.elliptical(10, 15),
            ),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                          isSend: false,
                        ),
                      ),
                    );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.elliptical(25, 18),
                        topRight: Radius.elliptical(10, 15),
                        bottomLeft: Radius.elliptical(10, 15),
                      ),
                      child: Stack(
                        fit: StackFit.loose,
                        children: [
                          Hero(
                            tag: "recieve",
                            child: CustomExtendedImageWidget(
                              imageUrl: fileType == "video"
                                  ? thumbnail ?? ""
                                  : fileUrl,
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
                        ],
                      ),
                    ),
                  ],
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
