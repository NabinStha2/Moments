import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moment/services/api_config.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:http/http.dart" as http;

import '../app/states/states.dart';
import '../models/user_model/users_model.dart';

class VoiceScreen extends StatefulWidget {
  final UserData userDetail;
  const VoiceScreen({Key? key, required this.userDetail}) : super(key: key);

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  String token = "";
  String channelName = "";
  late RtcEngine _engine;
  bool isJoined = false,
      openMicrophone = true,
      enableSpeakerphone = true,
      playEffect = false;
  bool userJoin = false;
  int totalDuration = 0;
  int userCount = 0;
  TextEditingController? _controller;

  @override
  void initState() {
    initAgora();
    _controller = TextEditingController(text: channelName);
    Timer(
      const Duration(seconds: 2),
      () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Only share your unique channel name with those you wish to call."),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
    super.initState();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone].request();

    //create the engine
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();
    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
  }

  void _addListeners() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          log('joinChannelSuccess ${channel} ${uid} ${elapsed}');
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
                const SnackBar(
                  content: Text("Reconnecting..."),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (ConnectionStateType.Connecting == type) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text("Connecting..."),
                  backgroundColor: Colors.grey,
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (ConnectionStateType.Connected == type) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text("Connected"),
                  backgroundColor: Colors.pinkAccent,
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (ConnectionStateType.Disconnected == type) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text("Disconnected!!!"),
                  backgroundColor: Colors.pinkAccent,
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        rtcStats: (RtcStats stats) {
          log(stats.duration.toString());

          setState(() {
            totalDuration = stats.duration;
            userCount = stats.userCount;
          });
        },
        userJoined: (uid, elapsed) {
          log('userJoined  ${uid} ${elapsed}');
          setState(() {
            userJoin = true;
          });
        },
        userOffline: (uid, reason) {
          log('userOffline  ${uid} ${reason}');
          setState(() {
            userJoin = false;
          });
        },
        leaveChannel: (stats) async {
          log('leaveChannel ${stats.toJson()}');
          setState(() {
            isJoined = false;
          });
        },
      ),
    );
  }

  _joinChannel() async {
    try {
      // final uri = Uri.https(baseUrl, "/rtcToken/$channelName");
      final uri = Uri.http(ApiConfig.baseUrl, "/rtcToken/$channelName");
      final response = await http.get(
        uri,
      );
      // ignore: avoid_print
      // print(response.body);
      final key = json.decode(response.body);
      // debugPrint(key["key"]);
      setState(() {
        token = key["key"];
      });

      if (defaultTargetPlatform == TargetPlatform.android) {
        await Permission.microphone.request();
      }

      token != ""
          ? await _engine.joinChannel(token, channelName, null, 0)
          : ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text("Voice Call can't be done at this moment.Try later!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("Something went wrong!!!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    setState(() {
      isJoined = false;
      openMicrophone = true;
      enableSpeakerphone = true;
      playEffect = false;
    });
  }

  _switchMicrophone() {
    _engine.enableLocalAudio(!openMicrophone).then((value) {
      setState(() {
        openMicrophone = !openMicrophone;
      });
    }).catchError((err) {
      log('enableLocalAudio $err');
    });
  }

  _switchSpeakerphone() {
    _engine.setEnableSpeakerphone(!enableSpeakerphone).then((value) {
      setState(() {
        enableSpeakerphone = !enableSpeakerphone;
      });
    }).catchError((err) {
      log('setEnableSpeakerphone $err');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _engine.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Call'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintText: 'Channel Name',
                  ),
                  onChanged: (text) {
                    setState(() {
                      channelName = text;
                    });
                  },
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                  splashFactory: InkSplash.splashFactory,
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                onPressed: isJoined ? _leaveChannel : _joinChannel,
                child: Text('${isJoined ? 'Leave' : 'Join'} channel'),
              ),
            ],
          ),
          userJoin
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        child: Center(
                          child: Image.network(
                              widget.userDetail.image?.imageUrl ?? ""),
                        ),
                      ),
                      Text(
                        "${Duration(hours: totalDuration ~/ 3600, minutes: totalDuration ~/ 60, seconds: totalDuration % 60)} \n Number of Users on this channel: $userCount",
                        style: const TextStyle(
                          fontSize: 24.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'First Join Channel and Please wait for other user to join with the same channel name.',
                    textAlign: TextAlign.center,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _switchMicrophone,
                    icon: Icon(
                      openMicrophone ? Icons.mic : Icons.mic_off,
                      size: 24.0,
                    ),
                  ),
                  IconButton(
                    onPressed: _switchSpeakerphone,
                    icon: Icon(
                      enableSpeakerphone ? Icons.volume_up : Icons.headphones,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
