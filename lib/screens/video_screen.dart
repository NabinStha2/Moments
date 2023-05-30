import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:moment/app/colors.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:http/http.dart" as http;

import '../app/states/states.dart';
import '../development/console.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late RtcEngine _engine;
  String channelName = "";
  bool isJoined = false, switchCamera = true, switchRender = true;
  List<int> remoteUid = [];
  late TextEditingController? _controller;
  final TextEditingController _controllerText = TextEditingController();
  String token = "";

  @override
  void initState() {
    initAgora();
    _controller = TextEditingController(text: channelName);
    Timer(
      const Duration(seconds: 1),
      () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
              "Only share your unique channel name with those you wish to call."),
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
    super.initState();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine.enableVideo();

    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          log('joinChannelSuccess $channel $uid $elapsed');
          setState(() {
            isJoined = true;
          });
        },
        connectionStateChanged:
            (ConnectionStateType type, ConnectionChangedReason rsn) {
          log(type.toString());

          if (ConnectionStateType.Reconnecting == type) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: CustomText("Reconnecting..."),
                  backgroundColor: Colors.grey,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (ConnectionStateType.Connecting == type) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: CustomText("Connecting..."),
                  backgroundColor: Colors.grey,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (ConnectionStateType.Connected == type) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: CustomText("Connected"),
                  backgroundColor: Colors.grey,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (ConnectionStateType.Disconnected == type) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: CustomText("Disconnected!!!"),
                  backgroundColor: Colors.grey,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        userJoined: (uid, elapsed) {
          log('userJoined  $uid $elapsed');
          setState(() {
            remoteUid.add(uid);
          });
        },
        userOffline: (uid, reason) {
          log('userOffline  $uid $reason');
          setState(() {
            remoteUid.removeWhere((element) => element == uid);
          });
        },
        leaveChannel: (stats) {
          log('leaveChannel ${stats.toJson()}');
          setState(() {
            isJoined = false;
            remoteUid.clear();
          });
        },
      ),
    );

    // await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.Communication);
    // await _engine.setClientRole(ClientRole.Broadcaster);
  }

  @override
  void dispose() {
    super.dispose();
    _engine.destroy();
  }

  _joinChannel() async {
    consolelog(channelName);

    try {
      if (channelName == "") {
        throw "channel name is required";
      }
      // final uri = Uri.https(baseUrl, "/rtcToken/$channelName");
      final uri = Uri.parse("${ApiConfig.baseUrl}/rtcToken/$channelName");
      final response = await http.get(
        uri,
      );
      // ignore: avoid_print
      // print(response.body);
      final key = json.decode(response.body);
      log(key["key"]);
      setState(() {
        token = key["key"];
      });
      if (defaultTargetPlatform == TargetPlatform.android) {
        await [Permission.microphone, Permission.camera].request();
      }
      token != ""
          ? await _engine.joinChannel(token, channelName, null, 0)
          : ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(
                    "Video Call can't be done at this moment.Try later!"),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
    } catch (e) {
      // inspect(e);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: CustomText(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
  }

  _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      log('switchCamera $err');
    });
  }

  _switchRender() {
    setState(() {
      switchRender = !switchRender;
      remoteUid = List.of(remoteUid.reversed);
    });
  }

  Future<void> _onPressSend() async {
    if (_controllerText.text.isEmpty) {
      return;
    }

    try {
      var streamId = await _engine
          .createDataStreamWithConfig(DataStreamConfig(false, false));
      if (streamId != null) {
        await _engine.sendStreamMessage(
            streamId, Uint8List.fromList(utf8.encode(_controllerText.text)));
      }
      _controllerText.clear();
    } catch (e) {
      log('sendStreamMessage error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText('Video Call'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              vSizedBox1,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  cursorColor: Colors.white,
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      hintText: 'Channel Name',
                      hintStyle: const TextStyle(
                        color: MColors.primaryGrayColor50,
                        fontWeight: FontWeight.w400,
                      )),
                  onChanged: (text) {
                    setState(() {
                      channelName = text;
                    });
                  },
                ),
              ),
              vSizedBox1,
              CustomElevatedButtonWidget(
                width: 180,
                onPressed: isJoined ? _leaveChannel : _joinChannel,
                child: CustomText('${isJoined ? 'Leave' : 'Join'} channel'),
              ),
              vSizedBox2,
              _renderVideo(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: IconButton(
                    onPressed: _switchCamera,
                    icon: const Icon(
                      Icons.flip_camera_ios_outlined,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ),
                ),
              ),
              // if (isJoined)
              //   Padding(
              //     padding:  EdgeInsets.all(10.0),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.max,
              //       children: [
              //         Expanded(
              //           child: TextField(
              //             controller: _controllerText,
              //             decoration:  InputDecoration(
              //               hintText: 'Input Message',
              //             ),
              //           ),
              //         ),
              //         ElevatedButton(
              //           onPressed: _onPressSend,
              //           child:  CustomText('Send'),
              //         ),
              //       ],
              //     ),
              //   )
            ],
          ),
        ],
      ),
    );
  }

  _renderVideo() {
    return Expanded(
      child: Stack(
        children: [
          remoteUid.isNotEmpty
              ? Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.of(
                        remoteUid.map(
                          (e) => GestureDetector(
                            onTap: _switchRender,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: RtcRemoteView.TextureView(
                                channelId: channelName,
                                uid: e,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: CustomText(
                    'Please wait for other user to join with the same channel name.',
                    textAlign: TextAlign.center,
                  ),
                ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 120,
              height: 160,
              child: RtcLocalView.SurfaceView(
                channelId: channelName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
