import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:moment/main.dart';
import 'package:moment/pages/camera_view_page.dart';
import 'package:moment/pages/video_view_page.dart';

class CameraPage extends StatefulWidget {
  final Function? sendFile;
  const CameraPage({Key? key, this.sendFile}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? cameraController;
  Future<void>? cameraValue;
  bool? flash = false;
  bool? isRecoring = false;
  bool iscamerafront = true;
  double transform = 0;

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(
      cameras![0],
      ResolutionPreset.max,
      enableAudio: true,
    );
    cameraValue = cameraController!.initialize();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(cameraController!);
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            future: cameraValue,
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          flash! ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () async {
                          setState(() {
                            flash = !flash!;
                          });
                          flash!
                              ? await cameraController!
                                  .setFlashMode(FlashMode.torch)
                              : await cameraController!
                                  .setFlashMode(FlashMode.off);
                        },
                      ),
                      GestureDetector(
                        onLongPress: () async {
                          await cameraController!.startVideoRecording();
                          setState(() {
                            isRecoring = true;
                          });
                        },
                        onLongPressUp: () async {
                          XFile videopath =
                              await cameraController!.stopVideoRecording();
                          setState(() {
                            isRecoring = false;
                          });
                          debugPrint(videopath.path);
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => VideoViewPage(
                                path: videopath.path,
                                sendFile: widget.sendFile!,
                              ),
                            ),
                          );
                        },
                        onTap: () {
                          if (!isRecoring!) takePhoto(context);
                        },
                        child: isRecoring!
                            ? const Icon(
                                Icons.radio_button_on,
                                color: Colors.red,
                                size: 80,
                              )
                            : const Icon(
                                Icons.panorama_fish_eye,
                                color: Colors.white,
                                size: 70,
                              ),
                      ),
                      IconButton(
                        icon: Transform.rotate(
                          angle: transform,
                          child: const Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            iscamerafront = !iscamerafront;
                            transform = transform + pi;
                          });
                          int cameraPos = iscamerafront ? 0 : 1;
                          cameraController = CameraController(
                              cameras![cameraPos], ResolutionPreset.high);
                          cameraValue = cameraController!.initialize();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const Text(
                    "Hold for Video, tap for photo",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void takePhoto(BuildContext context) async {
    XFile file = await cameraController!.takePicture();
    debugPrint(file.path);
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) => CameraViewPage(
          path: file.path,
          sendFile: widget.sendFile,
        ),
      ),
    );
  }
}
