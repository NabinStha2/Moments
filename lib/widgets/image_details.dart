import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageDetails extends StatefulWidget {
  final String imageUrl;

  const ImageDetails({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<ImageDetails> createState() => _ImageDetailsState();
}

class _ImageDetailsState extends State<ImageDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: widget.imageUrl != ""
                ? ExtendedImage.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    enableLoadState: true,
                    filterQuality: FilterQuality.high,
                    handleLoadingProgress: true,
                    alignment: Alignment.center,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (state) {
                      return GestureConfig(
                        hitTestBehavior: HitTestBehavior.opaque,
                        minScale: 1.0,
                        animationMinScale: 0.6,
                        maxScale: 4.0,
                        animationMaxScale: 4.5,
                        speed: 1.0,
                        inertialSpeed: 100.0,
                        initialScale: 1.0,
                        inPageView: false,
                        initialAlignment: InitialAlignment.center,
                      );
                    },
                  )
                : ExtendedImage.network(
                    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                    fit: BoxFit.contain,
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
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Wait until image saved."),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.grey,
                      ),
                    );
                    _save();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.white60,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    
                      // gradient: LinearGradient(
                      //   begin: Alignment.centerLeft,
                      //   end: Alignment.centerRight,
                      //   colors: [
                      //     Colors.green.shade800,
                      //     Colors.cyan.shade800,
                      //   ],
                      // ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          "Image will be saved to gallary",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.redAccent[200]),
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _save() async {
    if (await _askPermission()) {
      var response = await Dio().get(widget.imageUrl,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
      );
      // ignore: avoid_print
      print(result);
      if (result["isSuccess"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image Saved"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Problem saving image!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("First allow access to save images!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _askPermission() async {
    if (Platform.isAndroid) {
      Permission permission = Permission.storage;
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      }
      return false;
    }
    return false;
  }
}
