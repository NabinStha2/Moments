// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api, unused_import

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:moment/development/console.dart';
import 'package:moment/utils/user_post_signal_id.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:moment/bloc/activityBloc/activity_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/post_add/post_add_screen.dart';
import 'package:moment/screens/home/home_screen.dart';
import 'package:moment/screens/main/main_screen.dart';
import 'package:moment/services/api_config.dart';
import 'package:moment/widgets/custom_reactions_widget.dart';
import 'package:moment/widgets/video.dart';

import '../../../utils/storage_services.dart';

PostModelData? singlePostData;

class Postdetails extends StatefulWidget {
  final String postId;
  final bool isFromComment;
  final bool isFromProfile;
  final bool isFromHome;
  final bool isFromProfileVisit;
  final bool isFromActivity;
  final String? userVisitId;
  const Postdetails({
    Key? key,
    required this.postId,
    this.isFromComment = false,
    this.isFromProfile = false,
    this.isFromHome = false,
    this.isFromProfileVisit = false,
    this.isFromActivity = false,
    this.userVisitId,
  }) : super(key: key);

  @override
  _PostdetailsState createState() => _PostdetailsState();
}

class _PostdetailsState extends State<Postdetails> {
  // final parentController = ScrollController();
  // final childController = ScrollController();
  bool loading = false;
  bool showDeleteAppBar = false;
  int? deleteIndex;
  String? deleteCommentId;
  List<String>? deleteCommentActivityId;
  double progress = 0;
  Directory? directory;
  File? saveFile;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PostsBloc>(context).add(GetSinglePostEvent(
      context: context,
      id: widget.postId,
    ));
  }

  _save() async {
    if (await _askPermission()) {
      setState(() {
        loading = true;
        progress = 0;
      });
      var response = await Dio().get(singlePostData?.file?.fileUrl ?? "", options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (value1, value2) {
        setState(() {
          progress = value1 / value2;
        });
      });
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
      );
      if (result["isSuccess"]) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Image has been saved"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Problem saving image!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ));
      }

      // Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("First allow access to save images!"),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {
      loading = false;
    });
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

  Future<bool> saveVideo(String url, String fileName) async {
    try {
      if (await _askPermission()) {
        // directory = await getExternalStorageDirectory();
        Directory? tempDir = await DownloadsPathProvider.downloadsDirectory;
        // print(tempDir!.path);

        String newPath = "";
        // List<String> paths = directory!.path.split("/");
        // for (int x = 1; x < paths.length; x++) {
        //   String folder = paths[x];
        //   if (folder != "Android") {
        //     newPath += "/" + folder;
        //   } else {
        //     break;
        //   }
        // }
        newPath = tempDir!.path;
        // print(newPath);
        directory = Directory(newPath);
        print("Directory: $directory");
      } else {
        return false;
      }

      if (!await directory!.exists()) {
        await directory?.create(recursive: true);
      }
      saveFile = File("${directory!.path}/$fileName");
      if (await directory!.exists()) {
        await Dio().download(url, saveFile?.path, onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile!.path, isReturnPathOfIOS: true);
          return false;
        }
        return true;
      }

      return false;
    } catch (e) {
      consolelog("Err: $e");
      return false;
    }
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

    bool downloaded = await saveVideo(singlePostData?.file?.fileUrl ?? "", "${singlePostData!.file?.fileName}.mp4");
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

  @override
  Widget build(BuildContext context) {
    if (deleteCommentId != null && deleteCommentActivityId != null) {
      consolelog(deleteCommentId!);
      consolelog("$deleteCommentActivityId");
    }

    return WillPopScope(
      onWillPop: () async {
        if (widget.isFromProfileVisit) {
          BlocProvider.of<PostsBloc>(context).add(
            GetCreatorPostsEvent(
              context: context,
              creator: widget.userVisitId!,
            ),
          );
        } else if (widget.isFromProfile) {
          BlocProvider.of<PostsBloc>(context).add(
            GetCreatorPostsEvent(
              context: context,
              creator: StorageServices.authStorageValues["id"] ?? "",
            ),
          );
        } else if (widget.isFromActivity) {
          BlocProvider.of<ActivityBloc>(context).add(GetActivity(id: StorageServices.authStorageValues["id"] ?? ""));
        } else {
          BlocProvider.of<PostsBloc>(context).add(RefreshPostsEvent());
          BlocProvider.of<PostsBloc>(context).add(PostPageChangeEvent(pageNumber: 1, context: context));
          // BlocProvider.of<PostsBloc>(context).add(GetPostsEvent(
          //   context: context,
          // ));
        }
        Navigator.of(context).pop(true);
        return true;
      },
      child: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Scaffold(
              body: Center(
                child: SpinKitCircle(
                  color: Colors.blue,
                  size: 40.0,
                ),
              ),
            );
          }
          if (state is GetSinglePostLoaded) {
            singlePostData = state.postModel;
          }
          return singlePostData != null
              ? Scaffold(
                  bottomSheet: showTextField(),
                  appBar: showDeleteAppBar
                      ? AppBar(
                          leading: IconButton(
                            onPressed: () {
                              setState(() {
                                showDeleteAppBar = false;
                                deleteIndex = null;
                              });
                            },
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                          actions: [
                            IconButton(
                              onPressed: () {
                                BlocProvider.of<PostsBloc>(context).add(DeleteCommentEvent(
                                  context: context,
                                  activityId: deleteCommentActivityId!,
                                  postId: singlePostData!.id!,
                                  token: StorageServices.authStorageValues["token"] ?? "",
                                  commentId: deleteCommentId!,
                                ));
                                setState(() {
                                  showDeleteAppBar = false;
                                  deleteIndex = null;
                                });
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ],
                        )
                      : AppBar(
                          title: const Text("Moments"),
                          automaticallyImplyLeading: false,
                          actions: [
                            if (StorageServices.authStorageValues.isNotEmpty == true &&
                                StorageServices.authStorageValues["id"] == singlePostData!.creator)
                              PopupMenuButton(
                                onSelected: (value) {
                                  if (value as String == "edit") {
                                    print(value);
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) => BlocProvider.value(
                                    //       value: BlocProvider.of<PostsBloc>(context),
                                    //       child: PostAddScreen(
                                    //         isUpdate: true,
                                    //         post: singlePostData,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // );
                                  } else {
                                    print(value);
                                    BlocProvider.of<PostsBloc>(context).add(
                                      DeletePostEvent(
                                        isFromVisit: widget.isFromProfileVisit,
                                        isFromActivity: widget.isFromActivity,
                                        isFromProfile: widget.isFromProfile,
                                        isFromVisitUserId: widget.userVisitId,
                                        context: context,
                                        id: singlePostData!.id!,
                                        token: StorageServices.authStorageValues["token"] ?? "",
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white,
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: "edit",
                                    child: Text("Edit"),
                                  ),
                                  const PopupMenuItem(
                                    value: "delete",
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            singlePostData!.fileType == "video"
                                ? loading
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            value: progress,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          downloadFile();
                                        },
                                        icon: const Icon(
                                          Icons.download_rounded,
                                          color: Colors.white,
                                        ),
                                      )
                                : loading
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            value: progress,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          _save();
                                        },
                                        icon: const Icon(
                                          Icons.download_rounded,
                                          color: Colors.white,
                                        ),
                                      )
                          ],
                          leading: IconButton(
                            onPressed: () {
                              if (widget.isFromProfileVisit) {
                                BlocProvider.of<PostsBloc>(context).add(
                                  GetCreatorPostsEvent(
                                    context: context,
                                    creator: widget.userVisitId!,
                                  ),
                                );
                              } else if (widget.isFromProfile) {
                                BlocProvider.of<PostsBloc>(context).add(
                                  GetCreatorPostsEvent(
                                    context: context,
                                    creator: StorageServices.authStorageValues["id"]!,
                                  ),
                                );
                              } else if (widget.isFromActivity) {
                                BlocProvider.of<ActivityBloc>(context).add(GetActivity(id: StorageServices.authStorageValues["id"]!));
                              } else {
                                BlocProvider.of<PostsBloc>(context).add(RefreshPostsEvent());
                                BlocProvider.of<PostsBloc>(context).add(PostPageChangeEvent(pageNumber: 1, context: context));
                                // BlocProvider.of<PostsBloc>(context).add(GetPostsEvent(
                                //   context: context,
                                // ));
                              }
                              Navigator.of(context).pop(true);
                            },
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                  body: Container(
                    color: showDeleteAppBar ? Colors.black45 : Colors.transparent,
                    padding: const EdgeInsets.all(10.0),
                    child: Scrollbar(
                      // controller: parentController,
                      interactive: true,
                      radius: const Radius.circular(20.0),
                      thickness: 6.0,
                      child: CustomScrollView(
                        // controller: parentController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                SizedBox(
                                  height: 500,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: singlePostData!.fileType == "video"
                                          ? Video(
                                              url: singlePostData?.file?.fileUrl ?? "",
                                              thumbnail: singlePostData?.file?.thumbnail ?? "",
                                            )
                                          : singlePostData?.file?.fileUrl != ""
                                              ? Opacity(
                                                  opacity: showDeleteAppBar ? 0.3 : 1,
                                                  child: ExtendedImage.network(
                                                    singlePostData?.file?.fileUrl ?? "",
                                                    fit: BoxFit.cover,
                                                    width: MediaQuery.of(context).size.width,
                                                    enableLoadState: true,
                                                    filterQuality: FilterQuality.high,
                                                    alignment: Alignment.center,
                                                    mode: ExtendedImageMode.gesture,
                                                    gaplessPlayback: true,
                                                    handleLoadingProgress: true,
                                                    borderRadius: BorderRadius.circular(20.0),
                                                    initGestureConfigHandler: (state) {
                                                      return GestureConfig(
                                                        hitTestBehavior: HitTestBehavior.opaque,
                                                        minScale: 1.0,
                                                        animationMinScale: 0.6,
                                                        cacheGesture: true,
                                                        maxScale: 4.0,
                                                        animationMaxScale: 4.5,
                                                        speed: 1.0,
                                                        inertialSpeed: 100.0,
                                                        initialScale: 1.0,
                                                        inPageView: true,
                                                        initialAlignment: InitialAlignment.center,
                                                      );
                                                    },
                                                  ),
                                                )
                                              : ExtendedImage.network(
                                                  "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                                                  fit: BoxFit.cover,
                                                  printError: true,
                                                  width: MediaQuery.of(context).size.width,
                                                  enableLoadState: true,
                                                  filterQuality: FilterQuality.high,
                                                  alignment: Alignment.center,
                                                  mode: ExtendedImageMode.gesture,
                                                  gaplessPlayback: true,
                                                  borderRadius: BorderRadius.circular(20.0),
                                                  initGestureConfigHandler: (state) {
                                                    return GestureConfig(
                                                      hitTestBehavior: HitTestBehavior.opaque,
                                                      minScale: 1.0,
                                                      animationMinScale: 0.6,
                                                      cacheGesture: true,
                                                      maxScale: 4.0,
                                                      animationMaxScale: 4.5,
                                                      speed: 1.0,
                                                      inertialSpeed: 100.0,
                                                      initialScale: 1.0,
                                                      inPageView: true,
                                                      initialAlignment: InitialAlignment.center,
                                                    );
                                                  },
                                                )),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomReactionsWidget(
                                      post: singlePostData ?? PostModelData(),
                                      isFromPostDetails: true,
                                    ),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    AutoSizeText(
                                      singlePostData!.description!,
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  timeago.format(
                                    DateTime.parse(singlePostData?.createdAt.toString() ?? ""),
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: showDeleteAppBar ? Colors.black12 : Colors.grey.shade200,
                                  ),
                                  width: double.infinity,
                                  child: singlePostData?.comments?.isNotEmpty == true
                                      ? ListView.builder(
                                          // controller: childController,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: singlePostData?.comments?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            var cmt = singlePostData?.comments;
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                  color: deleteIndex != null && deleteIndex == index ? Colors.white : Colors.transparent,
                                                  child: InkWell(
                                                    splashColor: Colors.grey,
                                                    onLongPress: () {
                                                      if (StorageServices.authStorageValues.isNotEmpty == true &&
                                                          StorageServices.authStorageValues["id"] == cmt?[index].commentUserId) {
                                                        setState(() {
                                                          showDeleteAppBar = true;
                                                          deleteCommentId = cmt?[index].commentId;
                                                          deleteCommentActivityId = cmt?[index].activityId;
                                                          deleteIndex = index;
                                                        });
                                                      }
                                                    },
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        AutoSizeText.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "${cmt?[index].commentName!.split(":")[0]}  ",
                                                                style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontFamily: GoogleFonts.montserrat().fontFamily,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: cmt?[index].commentName!.split(":")[1],
                                                                style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontFamily: GoogleFonts.montserrat().fontFamily,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            AutoSizeText(
                                                              timeago.format(
                                                                DateTime.parse(cmt?[index].timestamps ?? ""),
                                                                locale: 'en_short',
                                                              ),
                                                              style: TextStyle(
                                                                color: Colors.grey.shade700,
                                                                fontSize: 8,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                print("Reply comment");
                                                                _showDialog(
                                                                  replyTo: cmt?[index].commentName!.split(":")[0],
                                                                  commentId: cmt?[index].commentId,
                                                                  replyToUserId: cmt?[index].commentUserId,
                                                                );
                                                              },
                                                              child: const AutoSizeText(
                                                                "Reply",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                cmt?[index].replyComments?.isNotEmpty == true
                                                    ? Row(
                                                        children: [
                                                          SizedBox(
                                                            height: cmt != null ? (38 * cmt[index].replyComments!.length).toDouble() : 0.0,
                                                            child: const VerticalDivider(
                                                              thickness: 1,
                                                              width: 30,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: cmt?[index]
                                                                      .replyComments
                                                                      ?.map(
                                                                        (replyCmt) => Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            const SizedBox(
                                                                              height: 5.0,
                                                                            ),
                                                                            AutoSizeText.rich(
                                                                              TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: "${replyCmt.commentName!.split(":")[0]}  ",
                                                                                    style: const TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: replyCmt.commentName!.split(":")[1],
                                                                                    style: const TextStyle(
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            AutoSizeText(
                                                                              timeago.format(
                                                                                DateTime.parse(replyCmt.timestamps!),
                                                                                locale: 'en_short',
                                                                              ),
                                                                              style: TextStyle(
                                                                                color: Colors.grey.shade700,
                                                                                fontSize: 8,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5.0,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                      .toList() ??
                                                                  [],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                                const SizedBox(
                                                  height: 8.0,
                                                ),
                                                const Divider(
                                                  thickness: 1,
                                                  endIndent: 30,
                                                  indent: 40,
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                      : const Text("No Comments!"),
                                ),
                                Container(
                                  height: 70,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text("Something went wrong! Please try again."),
                );
        },
      ),
    );
  }

  Widget showTextField({
    isReply = false,
    String? commentId,
    String? replyToUserId,
  }) {
    if (commentId != null) {
      consolelog(commentId);
    }

    return Container(
      color: showDeleteAppBar ? Colors.black45 : Colors.transparent,
      padding: const EdgeInsets.all(15),
      child: TextField(
        autofocus: widget.isFromComment,
        controller: BlocProvider.of<PostsBloc>(context).commentController,
        decoration: InputDecoration(
          labelText: isReply ? "Reply to ..." : "Add a comment...",
          contentPadding: const EdgeInsets.all(10),
          suffixIcon: IconButton(
            onPressed: () async {
              if (BlocProvider.of<PostsBloc>(context).commentController.text.isNotEmpty) {
                if (StorageServices.authStorageValues.isNotEmpty == true) {
                  if (isReply) {
                    BlocProvider.of<PostsBloc>(context).add(
                      CommentPostEvent(
                        context: context,
                        id: singlePostData?.id ?? "",
                        value: "${StorageServices.authStorageValues["name"]}:${BlocProvider.of<PostsBloc>(context).commentController.text}",
                        token: StorageServices.authStorageValues["token"] ?? "",
                        creatorId: singlePostData?.creator ?? "",
                        userId: StorageServices.authStorageValues["id"] ?? "",
                        postUrl: singlePostData?.fileType == "video" ? singlePostData?.file?.thumbnail ?? "" : singlePostData?.file?.fileUrl ?? "",
                        userImageUrl: StorageServices.authStorageValues["imageUrl"] ?? "",
                        activityName: "${StorageServices.authStorageValues["name"]} has commented on your post.",
                        isReply: true,
                        commentId: commentId,
                        replyToUserId: replyToUserId,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    BlocProvider.of<PostsBloc>(context).add(
                      CommentPostEvent(
                        context: context,
                        id: singlePostData?.id ?? "",
                        value: "${StorageServices.authStorageValues["name"]}:${BlocProvider.of<PostsBloc>(context).commentController.text}",
                        token: StorageServices.authStorageValues["token"] ?? "",
                        creatorId: singlePostData?.creator ?? "",
                        userId: StorageServices.authStorageValues["id"] ?? "",
                        postUrl: singlePostData?.fileType == "video" ? singlePostData?.file?.thumbnail ?? "" : singlePostData?.file?.fileUrl ?? "",
                        userImageUrl: StorageServices.authStorageValues["imageUrl"] ?? "",
                        activityName: "${StorageServices.authStorageValues["name"]} has commented on your post.",
                      ),
                    );
                  }
                  BlocProvider.of<PostsBloc>(context).add(PostClearValueEvent());
                  var resOneSignalIds = await getUserPostSignalId(
                    baseUrl: ApiConfig.baseUrl,
                    postId: singlePostData!.id,
                  );
                  var resData = json.decode(resOneSignalIds);
                  if (resData["message"] == "Success" && resData["data"] != []) {
                    var notification = OSCreateNotification(
                      playerIds: (resData["data"] as List).map((e) => e.toString()).toList(),
                      androidSound: "landras_dream",
                      content: "${StorageServices.authStorageValues["name"]} has commented on your post.",
                      heading: "Moments",
                      bigPicture: singlePostData?.file?.fileUrl,
                    );
                    await OneSignal.shared.postNotification(notification);
                  }
                } else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                        content: Text("Login to comment!"),
                        elevation: 0.0,
                        duration: Duration(seconds: 2),
                      ),
                    );
                }
              } else {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                      content: Text("Comment shouldn't be empty or login"),
                      elevation: 0.0,
                      duration: Duration(seconds: 2),
                    ),
                  );
              }
            },
            icon: const Icon(Icons.send),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  Future<void> _showDialog({
    String? replyTo,
    String? commentId,
    String? replyToUserId,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reply to $replyTo"),
          content: SizedBox(
            width: 250,
            child: showTextField(
              isReply: true,
              commentId: commentId,
              replyToUserId: replyToUserId,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("cancel"),
            ),
          ],
        );
      },
    );
  }
}
