// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class VideoDetails extends StatefulWidget {
  final String videoUrl;

  const VideoDetails({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoDetailsState createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;
  Directory? directory;
  File? saveFile;

  // static const allSpeeds = <double>[0.25, 0.5, 1, 1.5, 2, 3, 5, 10];

  @override
  void initState() {
    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) => _videoController!.play())
      ..addListener(() {
        setState(() {});
      })
      ..setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    _videoController!.dispose();
    super.dispose();
  }

  Future<bool> saveVideo(String url, String fileName) async {
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          // directory = await getExternalStorageDirectory();
          Directory? tempDir = await DownloadsPathProvider.downloadsDirectory;
          // print(tempDir.path);

          String newPath = "";
          // List<String> paths = directory.path.split("/");
          // for (int x = 1; x < paths.length; x++) {
          //   String folder = paths[x];
          //   if (folder != "Android") {
          //     newPath += "/" + folder;
          //   } else {
          //     break;
          //   }
          // }
          newPath = "${tempDir!.path}/Wallpaper";
          // print(newPath);
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      saveFile = File("${directory!.path}/$fileName");
      if (!await directory!.exists()) {
        await directory!.create(recursive: true);
      }
      if (await directory!.exists()) {
        await dio.download(url, saveFile!.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile!.path,
              isReturnPathOfIOS: true);
          return false;
        }
        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
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

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Don't go back until video is saved!"),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );

    bool downloaded = await saveVideo(widget.videoUrl, "${DateTime.now()}.mp4");
    if (downloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Video Downloaded at location ${saveFile!.path}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Problem downloading a file!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() {
      loading = false;
    });
  }

  // String getPosition() {
  //   final duration =
  //       Duration(seconds: _videoController!.value.position.inSeconds.round());
  //   // print("${duration.inMinutes}--------------------${duration.inSeconds}");
  //   return [duration.inMinutes, duration.inSeconds]
  //       .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
  //       .join(':');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: const Text("video"),
        centerTitle: true,
        actions: [
          loading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      value: progress,
                    ),
                  ),
                )
              : ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 26, 168, 228)),
                  ),
                  onPressed: () => downloadFile(),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
        ],
      ),
      body: Hero(
        tag: widget.videoUrl,
        child: _videoController!.value.isInitialized
            ? SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                    },
                    child: Stack(
                      fit: StackFit.loose,
                      // alignment: Alignment.center,
                      children: [
                        VideoPlayer(_videoController!),
                        Positioned(
                          left: 0,
                          bottom: -0.3,
                          right: 0,
                          child: VideoProgressIndicator(
                            _videoController!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              bufferedColor: Colors.white,
                              playedColor: Colors.red,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                        ),
                        // Positioned(
                        //   bottom: 10,
                        //   left: 5,
                        //   child: Text(
                        //     getPosition(),
                        //     style: const TextStyle(color: Colors.white),
                        //   ),
                        // ),
                        // Positioned(
                        //   bottom: 10,
                        //   right: 5,
                        //   child: Container(
                        //     child: widget.videoUrl.duration.toString().length == 2
                        //         ? Text(
                        //             DateFormat.ms().format(DateTime.parse(
                        //                 "2021-01-01 00:00:${widget.videoUrl.duration}")),
                        //             style: TextStyle(
                        //               color: Colors.white,
                        //             ),
                        //           )
                        //         : Text(
                        //             DateFormat.ms().format(DateTime.parse(
                        //                 "2021-01-01 00:00:0${widget.videoUrl.duration}")),
                        //             style: TextStyle(
                        //               color: Colors.white,
                        //             ),
                        //           ),
                        //   ),
                        // ),
                        _videoController!.value.isBuffering
                            ? Container(
                                color: Colors.white12,
                                alignment: Alignment.center,
                                child: const Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.black,
                                    size: 35.0,
                                  ),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: _videoController!.value.isPlaying
                                    ? Container()
                                    : const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white70,
                                        size: 34.0,
                                      ),
                              ),
                      ],
                    ),
                  ),
                ),
              )
            : const Center(
                child: SpinKitThreeBounce(
                  size: 30,
                  color: Colors.blue,
                ),
              ),
      ),
    );
  }
}
