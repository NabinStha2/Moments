import 'dart:async';
import 'dart:io';

import "package:http/http.dart" as http;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:moment/bloc/authBloc/auth_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/development/console.dart';
import 'package:moment/main.dart';
import 'package:moment/models/message_model/message_model.dart';
import 'package:moment/models/user_model/users_model.dart';
import 'package:moment/pages/camera_page.dart';
import 'package:moment/pages/camera_view_page.dart';
import 'package:moment/screens/profile/components/profile_page.dart';
import 'package:moment/pages/video_view_page.dart';
import 'package:moment/screens/video_screen.dart';
import 'package:moment/screens/voice_screen.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/receiver_image_ui.dart';
import 'package:moment/widgets/receiver_message_ui.dart';
import 'package:moment/widgets/sender_image_ui.dart';
import 'package:moment/widgets/sender_message_ui.dart';

class ChattingDetails extends StatefulWidget {
  final UserData chatDetail;
  const ChattingDetails({
    Key? key,
    required this.chatDetail,
  }) : super(key: key);

  @override
  _ChattingPageState createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingDetails> {
  final FocusNode _focusNode = FocusNode();
  // final ScrollController _scrollController = ScrollController();
  final TextEditingController messageEditingController = TextEditingController();
  bool emojiShowing = false;
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() async {
    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .setExtraHeaders({'foo': 'bar'}) // optional
          .build(),
    );
    socket!.connect();

    socket!.on("message", (msg) {
      debugPrint("Socket : $msg");
      BlocProvider.of<AuthBloc>(context).add(SendMsgDataEvent(
        context: context,
        msgData: MessageData(
          thumbnail: msg["thumbnail"],
          fileType: msg["fileType"],
          messageContent: msg["message"],
          messageType: "reciever",
          filePath: msg["filePath"],
          timeStamp: DateTime.now().toString().substring(10, 16),
        ),
      ));
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent + 100,
      //   duration: const Duration(milliseconds: 300),
      //   curve: Curves.easeOut,
      // );
    });

    socket!.on("user_login", (isLogin) {
      // debugPrint("Socket : $isLogin");
      setState(() {
        isOnline = isLogin;
      });
    });

    // debugPrint("${socket!.connected}");

    socket!.emit("signIn", [
      StorageServices.authStorageValues["name"],
      StorageServices.authStorageValues["id"],
      widget.chatDetail.id,
    ]);

    socket!.emit("user_online", [StorageServices.authStorageValues["id"], widget.chatDetail.id]);

    socket!.on("user_enter", (name) {
      // debugPrint(name);
      // debugPrint("${StorageServices.authStorageValues["name"]} has entered the chat!");
      BlocProvider.of<AuthBloc>(context).add(SendMsgDataEvent(
        context: context,
        msgData: MessageData(
          thumbnail: "",
          messageContent: "$name has entered the chat!",
          messageType: "bot",
          filePath: "",
          fileType: "",
          timeStamp: DateTime.now().toString().substring(10, 16),
        ),
      ));
    });

    socket!.on("user_leave", (name) {
      // debugPrint(botMsgId);
      // debugPrint("${StorageServices.authStorageValues["name"]} has leaved the chat!");
      BlocProvider.of<AuthBloc>(context).add(SendMsgDataEvent(
        context: context,
        msgData: MessageData(
          thumbnail: "",
          messageContent: "$name has leaved the chat!",
          messageType: "bot",
          filePath: "",
          fileType: "",
          timeStamp: DateTime.now().toString().substring(10, 16),
        ),
      ));
    });
  }

  void deleteMsgImage() async {
    consolelog("delete all msg Image");
    BlocProvider.of<AuthBloc>(context).clearMessageData();
    final uri = Uri.http(ApiConfig.baseUrl, "/user/deleteMsgImage/${StorageServices.authStorageValues["id"]}");
    await http.patch(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
      },
    );
  }

  sendFile(String filePath, String text, String fileType) async {
    consolelog("hello $filePath $fileType $text");
    BlocProvider.of<AuthBloc>(context)
        .add(UploadMsgImageEvent(image: File(filePath), context: context, id: StorageServices.authStorageValues["id"] ?? "", text: text));
  }

  @override
  void dispose() {
    socket!.dispose();
    super.dispose();
  }

  _onEmojiSelected(Emoji emoji) {
    messageEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(TextPosition(offset: messageEditingController.text.length));
  }

  _onBackspacePressed() {
    messageEditingController
      ..text = messageEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(TextPosition(offset: messageEditingController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        deleteMsgImage();
        socket!.emit(
          "user_leave",
          [
            StorageServices.authStorageValues["name"],
            StorageServices.authStorageValues["id"],
            widget.chatDetail.id,
          ],
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoScreen(),
                  ),
                );
              },
              iconSize: 18.0,
              splashRadius: 24.0,
              icon: const FaIcon(
                FontAwesomeIcons.video,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoiceScreen(
                      userDetail: widget.chatDetail,
                    ),
                  ),
                );
              },
              iconSize: 18.0,
              splashRadius: 24.0,
              icon: const FaIcon(
                FontAwesomeIcons.phoneAlt,
              ),
            ),
          ],
          leadingWidth: 70.0,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: InkWell(
              onTap: () {
                deleteMsgImage();
                socket!.emit(
                  "user_leave",
                  [
                    StorageServices.authStorageValues["name"],
                    StorageServices.authStorageValues["id"],
                    widget.chatDetail.id,
                  ],
                );

                Navigator.pop(context);
              },
              splashColor: Colors.grey[400],
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      clipBehavior: Clip.antiAlias,
                      child: widget.chatDetail.image?.imageUrl != ""
                          ? Image.network(
                              widget.chatDetail.image?.imageUrl ?? "",
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              height: 50,
                              width: 50,
                              filterQuality: FilterQuality.high,
                            )
                          : Image.network(
                              "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                              fit: BoxFit.cover,
                              height: 50.0,
                              width: 50,
                              alignment: Alignment.center,
                              isAntiAlias: true,
                              filterQuality: FilterQuality.high,
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                ],
              ),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: BlocProvider.of<PostsBloc>(context),
                    child: ProfileVisitPage(
                      isFromSearch: true,
                      userId: widget.chatDetail.id!,
                    ),
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.chatDetail.name.toString(),
                  style: TextStyle(
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  isOnline ? "online" : "offline",
                  style: TextStyle(
                    fontFamily: GoogleFonts.lato().fontFamily,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is UploadMsgImageSuccess) {
              // consolelog("DATA: ${state.msgData.data?.messageContent}");
              BlocProvider.of<AuthBloc>(context).add(SendMsgDataEvent(
                context: context,
                msgData: MessageData(
                  thumbnail: state.msgData.data?.thumbnail ?? "",
                  messageContent: state.msgData.data?.messageContent ?? "",
                  messageType: state.msgData.data?.messageType,
                  filePath: state.msgData.data?.filePath ?? "",
                  fileType: state.msgData.data?.fileType ?? "",
                  timeStamp: DateTime.now().toString().substring(10, 16),
                ),
              ));
              socket!.emit("message", {
                "message": state.msgData.data?.messageContent,
                "senderId": StorageServices.authStorageValues["id"],
                "targetId": widget.chatDetail.id,
                "filePath": state.msgData.data?.filePath ?? "",
                "fileType": state.msgData.data?.fileType ?? "",
                "thumbnail": state.msgData.data?.thumbnail ?? "",
              });
              // _scrollController.animateTo(
              //   _scrollController.position.maxScrollExtent + 200,
              //   duration: const Duration(milliseconds: 300),
              //   curve: Curves.easeOut,
              // );
            }
            if (state is AuthLoaded) {
              var msgListData = state.msgData;
              return newMethod(context, msgListData: msgListData);
            }
            return newMethod(context, msgListData: BlocProvider.of<AuthBloc>(context).messageData);
          },
        ),
      ),
    );
  }

  Padding newMethod(BuildContext context, {List<MessageData>? msgListData}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (msgListData?[index].messageType == "bot") {
                  return Center(
                    child: Text(
                      msgListData?[index].messageContent ?? "",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                        fontFamily: GoogleFonts.abel().fontFamily,
                      ),
                    ),
                  );
                }
                if (msgListData?[index].messageType == "sender") {
                  if (msgListData?[index].filePath != "") {
                    return SenderImageUi(
                      thumbnail: msgListData?[index].thumbnail ?? "",
                      fileType: msgListData?[index].fileType ?? "",
                      fileUrl: msgListData?[index].filePath ?? "",
                      msg: msgListData?[index].messageContent ?? "",
                      time: msgListData?[index].timeStamp ?? "",
                    );
                  } else {
                    return SenderMessageUi(
                      message: msgListData?[index].messageContent,
                      time: msgListData?[index].timeStamp,
                    );
                  }
                } else {
                  if (msgListData?[index].filePath != "") {
                    return ReceiverImageUi(
                      thumbnail: msgListData?[index].thumbnail ?? "",
                      fileType: msgListData?[index].fileType ?? "",
                      fileUrl: msgListData?[index].filePath ?? "",
                      msg: msgListData?[index].messageContent ?? "",
                      time: msgListData?[index].timeStamp ?? "",
                    );
                  } else {
                    return ReceiverMessageUi(
                      message: msgListData?[index].messageContent,
                      time: msgListData?[index].timeStamp,
                    );
                  }
                }
              },
              itemCount: msgListData?.length ?? 0,
              // controller: _scrollController,
              // physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  focusNode: _focusNode,
                  onTap: () {
                    setState(() => emojiShowing = false);
                    // Timer(
                    //   const Duration(milliseconds: 300),
                    //   () => _scrollController.animateTo(
                    //     _scrollController.position.maxScrollExtent + 100,
                    //     duration: const Duration(milliseconds: 200),
                    //     curve: Curves.easeInOut,
                    //   ),
                    // );
                  },
                  controller: messageEditingController,
                  maxLines: 4,
                  minLines: 1,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      onPressed: () {
                        _focusNode.unfocus();
                        _focusNode.canRequestFocus = true;
                        setState(() => {emojiShowing = !emojiShowing});
                      },
                      splashRadius: 20.0,
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: emojiShowing ? Colors.blue : Colors.black54,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (builder) => bottomSheet(),
                        );
                      },
                      splashRadius: 20.0,
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.black54,
                      ),
                    ),
                    hintText: "Type a message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  BlocProvider.of<AuthBloc>(context).add(SendMsgDataEvent(
                    context: context,
                    msgData: MessageData(
                      thumbnail: "",
                      fileType: "",
                      filePath: "",
                      messageType: "sender",
                      messageContent: messageEditingController.text,
                      timeStamp: DateTime.now().toString().substring(10, 16),
                    ),
                  ));
                  socket!.emit("message", {
                    "message": messageEditingController.text,
                    "senderId": StorageServices.authStorageValues["id"],
                    "targetId": widget.chatDetail.id,
                    "filePath": "",
                    "fileType": "",
                    "thumbnail": "",
                  });
                  messageEditingController.clear();
                  // _scrollController.animateTo(
                  //   _scrollController.position.maxScrollExtent + 100,
                  //   duration: const Duration(milliseconds: 200),
                  //   curve: Curves.easeInOut,
                  // );
                },
                splashRadius: 20.0,
                icon: const Icon(
                  Icons.send,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          WillPopScope(
            onWillPop: () async {
              if (emojiShowing) {
                setState(() {
                  emojiShowing = false;
                });
                return false;
              } else {
                return true;
              }
            },
            child: Offstage(
              offstage: !emojiShowing,
              child: SizedBox(
                height: 280,
                child: EmojiPicker(
                  onEmojiSelected: (Category category, Emoji emoji) {
                    _onEmojiSelected(emoji);
                  },
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    initCategory: Category.RECENT,
                    bgColor: const Color(0xFFF2F2F2),
                    indicatorColor: Colors.blue,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.blue,
                    progressIndicatorColor: Colors.blue,
                    backspaceColor: Colors.blue,
                    showRecentsTab: true,
                    recentsLimit: 28,
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: const CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
              const SizedBox(
                width: 50,
              ),
              iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {
        _chooseImage(text);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _chooseImage(String source) async {
    XFile? pickedFile;
    FilePickerResult? result;
    if (source == "Camera") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPage(
            sendFile: sendFile,
          ),
        ),
      );
    } else {
      result = await FilePicker.platform.pickFiles();
      consolelog("File extension: ${result?.files.single.extension}");
    }

    if (pickedFile != null || result != null) {
      result!.files.single.extension == "mp4"
          // ignore: use_build_context_synchronously
          ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builder) => VideoViewPage(
                  path: result?.files.single.path ?? "",
                  sendFile: sendFile,
                ),
              ),
            )
          :
          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraViewPage(
                  path: result?.files.single.path ?? "",
                  sendFile: sendFile,
                ),
              ),
            );
    }
  }
}
