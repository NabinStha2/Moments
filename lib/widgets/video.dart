import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

class Video extends StatefulWidget {
  final String url;
  final String thumbnail;
  const Video({
    Key? key,
    required this.url,
    required this.thumbnail,
  }) : super(key: key);

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  VideoPlayerController? _controller;
  // String? fileName;

  @override
  void initState() {
    super.initState();

    // getThumbnail();
  }

  // getThumbnail() async {
  //   fileName = await VideoThumbnail.thumbnailFile(
  //     video: widget.url,
  //     // thumbnailPath: (await getTemporaryDirectory()).path,
  //     // imageFormat: ImageFormat.WEBP,
  //     // maxHeight:
  //     //     64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
  //     // quality: 75,
  //   );
  //   inspect("file: $fileName");

  //   setState(() {});
  // }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _controller != null
          ? Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  },
                  child: Stack(
                    fit: StackFit.loose,
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller!),
                      Positioned(
                        left: 0,
                        bottom: -0.3,
                        right: 0,
                        child: VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            bufferedColor: Colors.white,
                            playedColor: Colors.red,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),
                      _controller!.value.isBuffering
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
                              child: _controller!.value.isPlaying
                                  ? Container()
                                  : const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 45.0,
                                    ),
                            ),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(
              height: 500,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Image.network(
                    widget.thumbnail,
                    height: 500,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        _controller = VideoPlayerController.network(widget.url)
                          ..initialize().then((_) {
                            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                            setState(() {});
                            _controller!.play();
                          })
                          ..addListener(() {
                            setState(() {});
                          })
                          ..setLooping(true);
                      },
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 45.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
