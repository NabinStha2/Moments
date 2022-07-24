// ignore_for_file: use_build_context_synchronously, avoid_print, sort_child_properties_last, library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:expandable_text/expandable_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/bloc/activity_bloc.dart';
import 'package:moment/bloc/posts_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/models/post_model.dart';
import 'package:moment/pages/activity_page.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:moment/screens/post_details.dart';
import 'package:moment/services/dynamic_link.dart';
import 'package:moment/widgets/reactions.dart';
import 'package:moment/widgets/video.dart';
// import 'package:native_notify/native_notify.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

// Open Sans,Montserrat,Roboto,Playfair Display,Proxima Nova

List<PostModel>? postData = [];

Future handleGetDeviceState() async {
  print("Getting DeviceState");
  var deviceState = await OneSignal.shared.getDeviceState();

  return deviceState;
}

Future getUserSignalId({baseUrl, postId}) async {
  // var state = await OneSignal.shared.getDeviceState();
  var state = await handleGetDeviceState();
  inspect(state);
  if (state != null && state.userId != null) {
    // final uriForOneSignalUserId =
    //     Uri.https(baseUrl, "/user/getOneSignalUserIds/$postId");
    final uriForOneSignalUserId =
        Uri.http(baseUrl, "/user/getOneSignalUserIds/$postId");
    final resOneSignalIds = await http.get(
      uriForOneSignalUserId,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
      },
    );
    print(json.decode(resOneSignalIds.body));
    return resOneSignalIds;
  }
}

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({
    Key? key,
  }) : super(key: key);

  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String>? authStorageValues;
  List choose = ["Image", "Video"];
  // final _picker = ImagePicker();
  final isUpdate = false;
  File? selectedFile;
  final ScrollController _scrollController = ScrollController();
  final ScrollController sc = ScrollController();
  int page = 1;
  bool showReaction = false;

  @override
  void initState() {
    super.initState();

    print("init state called");
    setState(() {
      postData = BlocProvider.of<PostsBloc>(context).allPostModels;
      page++;
      // inspect("PostData: $postData");
    });

    // OneSignal.shared.setNotificationWillShowInForegroundHandler(
    //     (OSNotificationReceivedEvent event) {
    //   print('FOREGROUND HANDLER CALLED WITH: $event');

    //   /// Display Notification, send null to not display
    //   // event.complete(null);

    //   // this.setState(() {
    //   //   _debugLabelString =
    //   //       "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
    //   // });
    // });

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        print("$page ${BlocProvider.of<PostsBloc>(context).pages!}");
        if (page > BlocProvider.of<PostsBloc>(context).pages!) {
          print("no more posts!");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text("No more Posts!"),
              duration: Duration(milliseconds: 400),
            ));
        } else {
          BlocProvider.of<PostsBloc>(context).add(GetPostsEvent(page: page));
          setState(() {
            page = page + 1;
          });
        }
      }
    });
    getStorageValues();
  }

  getStorageValues() async {
    authStorageValues = await getStorage();
    setState(() {
      authStorageValues = authStorageValues;
    });
    // inspect(authStorageValues);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    // inspect(result);
    setState(() {
      if (result != null) {
        selectedFile = File(result.files.single.path!);
        inspect(selectedFile);
      }
    });
  }

  // Future<void> _chooseImage(String source) async {
  //   final pickedFile = await _picker.pickImage(
  //     source: source == "camera" ? ImageSource.camera : ImageSource.gallery,
  //     imageQuality: 100,
  //   );
  //   // final bytes = await pickedFile?.readAsBytes();

  //   setState(() {
  //     if (pickedFile != null) {
  //       selectedFile = File(pickedFile.path);
  //       inspect(selectedFile);
  //     }
  //   });

  //   if (pickedFile == null) {
  //     LostData response = await _picker.getLostData();

  //     if (response.isEmpty) {
  //       return null;
  //     }
  //     if (response.file != null) {
  //       setState(() {
  //         if (pickedFile != null) {
  //           selectedFile = File(response.file!.path);
  //           // inspect(selectedFile);
  //         }
  //       });
  //     } else {
  //       print(response.file);
  //     }
  //   }
  // }

  navigateToPostDetails({post, val = false, isAll = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<PostsBloc>(context),
          child: Postdetails(
            isVisit: false,
            isFromProfile: false,
            postId: post.id,
            isAll: isAll,
            isFromComment: val,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    inspect(posts);
    // print(authStorageValues);
    // print(postModels);
    debugPrint(
        "Posts: ${BlocProvider.of<PostsBloc>(context).postModels!.length.toString()}");
    debugPrint(
        "All Posts: ${BlocProvider.of<PostsBloc>(context).allPostModels!.length.toString()}");
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MyApp.title,
          style: TextStyle(
            fontFamily: GoogleFonts.cookie().fontFamily,
            fontSize: 35,
          ),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 10.0),
            iconSize: 24.0,
            onPressed: () async {
              var searchSelectedPost = await showSearch(
                context: context,
                delegate: DataSearch(),
              );
              if (searchSelectedPost != null) {
                navigateToPostDetails(post: searchSelectedPost, isAll: true);
              }
            },
            icon: const FaIcon(
              FontAwesomeIcons.search,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: const Icon(Icons.arrow_upward),
        backgroundColor: Colors.grey,
        onPressed: () {
          print("scroll");
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        },
      ),
      body: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is PostCreated) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.grey,
                  content: Text("Post created successfully"),
                  elevation: 0.0,
                  duration: Duration(milliseconds: 400),
                ),
              );
          }
          if (state is PostDeleted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.grey,
                  content: Text("Post deleted Successfully"),
                  elevation: 0.0,
                  duration: Duration(milliseconds: 400),
                ),
              );
          }
          if (state is PostUpdated) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.grey,
                  content: Text("Post updated Successfully"),
                  elevation: 0.0,
                  duration: Duration(milliseconds: 400),
                ),
              );
          }
          if (state is PostUpdateLoading) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.grey,
                  content: Text("Updating post... Please wait..."),
                  elevation: 0.0,
                  duration: Duration(minutes: 1),
                ),
              );
          }
          if (state is PostDeleteLoading) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.grey,
                  content: Text("Deleting post... Please wait..."),
                  elevation: 0.0,
                  duration: Duration(minutes: 1),
                ),
              );
          }
          if (state is PostLoading) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.grey,
                  content: Text("Loading Posts..."),
                  elevation: 0.0,
                  duration: Duration(milliseconds: 400),
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is PostLoading && posts.isEmpty) {
            return const Center(
              child: SpinKitCubeGrid(
                color: Colors.blue,
                size: 40.0,
              ),
            );
          }

          if (state is CreatorPostsLoaded || state is CreatorPostError) {
            BlocProvider.of<PostsBloc>(context).add(RefreshPostsEvent());
            BlocProvider.of<PostsBloc>(context).add(const GetPostsEvent());
          }
          if (state is GetPostLoaded) {
            posts.clear();
            print("posts laoded");
            posts.addAll(state.postModel!);
          } else if (state is PostError && posts.isEmpty) {
            return Center(
              child: IconButton(
                onPressed: () {
                  // posts.clear();
                  setState(() {
                    page = 1;
                  });

                  BlocProvider.of<PostsBloc>(context)
                      .add(GetPostsEvent(page: page));

                  setState(() {
                    page++;
                  });
                },
                icon: const Icon(Icons.refresh),
              ),
            );
          }
          return posts.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(
                        const Duration(milliseconds: 1000), () {});

                    // posts.clear();
                    setState(() {
                      page = 1;
                    });

                    BlocProvider.of<PostsBloc>(context)
                        .add(RefreshPostsEvent());
                    BlocProvider.of<PostsBloc>(context)
                        .add(GetPostsEvent(page: page));
                    setState(() {
                      page++;
                    });
                  },
                  child: ListView.builder(
                    clipBehavior: Clip.antiAlias,
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollController,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      if (posts.isNotEmpty) {
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.all(10.0),
                          elevation: 2.0,
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 5.0,
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                posts[index].name!,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                GetTimeAgo.parse(
                                                  DateTime.parse(
                                                      post.createdAt!),
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          (authStorageValues != null &&
                                                  authStorageValues!["id"] ==
                                                      post.creator)
                                              ? PopupMenuButton(
                                                  onSelected: (value) {
                                                    if (value as String ==
                                                        "edit") {
                                                      print(value);
                                                      showBottomPanel(
                                                          post: post);
                                                    } else {
                                                      print(value);
                                                      BlocProvider.of<
                                                                  PostsBloc>(
                                                              context)
                                                          .add(
                                                        DeletePostEvent(
                                                          id: post.id!,
                                                          token:
                                                              authStorageValues![
                                                                  "token"]!,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.more_vert_rounded,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  ),
                                                  splashRadius: 20,
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
                                                )
                                              // InkWell(
                                              //     splashColor: Colors.grey,
                                              //     radius: 40.0,
                                              //     onTap: () {
                                              //       showBottomPanel(post: post);
                                              //     },
                                              //     child: const Icon(
                                              //       Icons.edit,
                                              //       color: Colors.grey,
                                              //       size: 26.0,
                                              //     ),
                                              //   )
                                              : Container()
                                        ]),
                                  ),
                                  Opacity(
                                    opacity: 1,
                                    child: post.fileType == "video"
                                        ? Video(
                                            url: post.fileUrl,
                                            thumbnail: post.thumbnail,
                                          )
                                        : post.fileUrl != ""
                                            ? GestureDetector(
                                                onTap: () => {
                                                  navigateToPostDetails(
                                                      post: post)
                                                },
                                                child: Image.network(
                                                  post.fileUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context,
                                                      object, stackTrace) {
                                                    // inspect(object);
                                                    // print(object);
                                                    return Container(
                                                      height: 500.0,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Center(
                                                        child: Text(
                                                          "Something went wrong with Image loading!",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Container(
                                                      height: 500.0,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  height: 500.0,
                                                  width: size.width,
                                                  alignment: Alignment.center,
                                                  isAntiAlias: true,
                                                  filterQuality:
                                                      FilterQuality.high,
                                                ),
                                              )
                                            : Image.network(
                                                "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                                                fit: BoxFit.cover,
                                                height: 500.0,
                                                width: size.width,
                                                alignment: Alignment.center,
                                                isAntiAlias: true,
                                                filterQuality:
                                                    FilterQuality.high,
                                              ),

                                    // Image.memory(
                                    //   Base64Decoder().convert(
                                    //     post.selectedFile
                                    //         .split(',')
                                    //         .last,
                                    //   ),
                                    //   fit: BoxFit.cover,
                                    //   height: 400.0,
                                    //   width: size.width,
                                    //   alignment: Alignment.center,
                                    //   isAntiAlias: true,
                                    //   filterQuality:
                                    //       FilterQuality.high,
                                    // ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: InkWell(
                                      onTap: () =>
                                          {navigateToPostDetails(post: post)},
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Row(
                                            //     mainAxisAlignment:
                                            //         MainAxisAlignment.start,
                                            //     children: post.tags!
                                            //         .map(
                                            //           (tag) => Text(
                                            //             "$tag ",
                                            //             style: const TextStyle(
                                            //               color: Colors.black54,
                                            //               fontWeight: FontWeight.w600,
                                            //             ),
                                            //           ),
                                            //         )
                                            //         .toList()),
                                            // const SizedBox(
                                            //   height: 10.0,
                                            // ),
                                            // Text(
                                            //   post.title!,
                                            //   maxLines: 1,
                                            //   overflow: TextOverflow.ellipsis,
                                            //   style: TextStyle(
                                            //     fontFamily:
                                            //         GoogleFonts.roboto().fontFamily,
                                            //     color: Colors.black87,
                                            //     fontSize: 20.0,
                                            //     fontWeight: FontWeight.w600,
                                            //   ),
                                            // ),
                                            // const SizedBox(
                                            //   height: 10.0,
                                            // ),
                                            ExpandableText(
                                              post.description!,
                                              animation: true,
                                              linkEllipsis: true,
                                              expanded: true,
                                              expandText: 'show more',
                                              collapseText: 'show less',
                                              maxLines: 3,
                                              linkColor: Colors.grey,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Reactions(
                                          post: post,
                                        ),
                                        Text(
                                          post.likes!.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => {
                                            navigateToPostDetails(
                                                post: post, val: true)
                                          },
                                          splashColor: Colors.grey,
                                          splashRadius: 20.0,
                                          icon: const FaIcon(
                                            FontAwesomeIcons.commentDots,
                                          ),
                                        ),
                                        Text(
                                          post.comments.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            var link =
                                                await FirebaseDynamicLinkService
                                                    .createDynamicLink(
                                                        postId: post.id);
                                            print("Link: $link");
                                            Share.share(link,
                                                subject: "Moments post.");
                                          },
                                          splashColor: Colors.grey,
                                          splashRadius: 20.0,
                                          icon: const FaIcon(
                                            FontAwesomeIcons.share,
                                            color: Colors.grey,
                                            size: 25.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: Text("No Posts Yet!"));
                      }
                    },
                  ),
                )
              : const Center(child: Text("No Posts Yet!"));
        },
      ),
    );
  }

  Future<File> urlToFile(String imageUrl) async {
// generate random number.
    var rng = Random();
// get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    File file = File('$tempPath${rng.nextInt(100)}.png');

// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }

  void showBottomPanel({required PostModel post}) async {
    // print("${post.tags?.join(" ").toString()}");
    // print(post.tags);

    selectedFile = await urlToFile(
        // "https://momentsapps.herokuapp.com/${post.imageUrl}",
        post.fileUrl);
    inspect(selectedFile);
    // titleController.text = post.title!;
    descriptionController.text = post.description!;
    // tagsController.text = post.tags!.join(" ");
    // print(selectedFile);

    showBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  // alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Update",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontFamily: GoogleFonts.courgette().fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // TextFormField(
                            //   controller: titleController,
                            //   keyboardType: TextInputType.text,
                            //   decoration: InputDecoration(
                            //     labelText: "Title",
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(20.0),
                            //     ),
                            //     hintText: 'Enter your title',
                            //   ),
                            //   validator: (String? value) {
                            //     if (value == null || value.isEmpty) {
                            //       return 'Please enter title';
                            //     }
                            //     return null;
                            //   },
                            // ),
                            const SizedBox(height: 10.0),
                            TextFormField(
                              controller: descriptionController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                hintText: 'Enter your description',
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10.0),
                            // TextFormField(
                            //   controller: tagsController,
                            //   keyboardType: TextInputType.text,
                            //   decoration: InputDecoration(
                            //     labelText: "Tags",
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(20.0),
                            //     ),
                            //     hintText:
                            //         'Enter your tags using hash and separate with spaces',
                            //     hintMaxLines: 2,
                            //   ),
                            //   validator: (String? value) {
                            //     if (value == null || value.isEmpty) {
                            //       return 'Please enter tags';
                            //     }
                            //     return null;
                            //   },
                            // ),
                            // const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  clipBehavior: Clip.antiAlias,
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.grey.shade300),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    fixedSize: MaterialStateProperty.all(
                                      Size.fromWidth(
                                          MediaQuery.of(context).size.width /
                                              2.5),
                                    ),
                                  ),
                                  onPressed: () {
                                    _chooseFile();
                                  },
                                  child: const Text(
                                    "Choose File",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                selectedFile != null
                                    ? SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: Text(
                                          selectedFile!.path,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    fixedSize: MaterialStateProperty.all(
                                      Size.fromWidth(
                                          MediaQuery.of(context).size.width /
                                              2.5),
                                    ),
                                  ),
                                  child: const Text("Update"),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (authStorageValues != null &&
                                          authStorageValues!.isNotEmpty) {
                                        if (selectedFile != null) {
                                          print("success");

                                          // posts.clear();

                                          BlocProvider.of<PostsBloc>(context)
                                              .add(
                                            UpdatePostEvent(
                                              id: post.id!,
                                              data: {
                                                // "title": titleController.text,
                                                "description":
                                                    descriptionController.text,
                                                "selectedFile": selectedFile,
                                                // "tags": tagsController.text,
                                              },
                                              token:
                                                  authStorageValues!["token"]!,
                                            ),
                                          );
                                          titleController.text = "";
                                          descriptionController.text = "";
                                          tagsController.text = "";
                                          // setModalState(() {
                                          //   selectedFile = null;
                                          // });
                                          BlocProvider.of<PostsBloc>(context)
                                              .add(RefreshPostsEvent());
                                          BlocProvider.of<PostsBloc>(context)
                                              .add(const GetPostsEvent());
                                          Navigator.of(context).pop(true);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(
                                              const SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: Text(
                                                    "File mustn't be empty"),
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
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.red,
                                              content:
                                                  Text("Required Sign In!"),
                                              elevation: 0.0,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Future<void> _showDialog() async {
  //   return await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Choose:"),
  //         content: Container(
  //           width: 250,
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: choose.length,
  //             itemBuilder: (BuildContext context, int index) {
  //               return ListTile(
  //                 title: Text(choose[index]),
  //                 onTap: () {
  //                   _chooseFile();
  //                   Navigator.pop(context);
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text("cancel"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}

class DataSearch extends SearchDelegate {
  final postList = postData;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final postInfo = query.isNotEmpty
        ? postList!
            .where((element) =>
                    element.name!.toLowerCase().startsWith(query.toLowerCase())
                // ||
                // element.title!.toLowerCase().contains(query.toLowerCase()) ||
                // element.title!.toLowerCase().startsWith(query.toLowerCase())
                )
            .toList()
        : null;

    return postInfo != null
        ? ListView.separated(
            clipBehavior: Clip.antiAlias,
            separatorBuilder: (context, index) {
              return const Divider(
                color: Colors.grey,
                thickness: 0.5,
                indent: 15.0,
                endIndent: 15.0,
              );
            },
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.feed),
              title: Text(postInfo[index].name!),
              // subtitle: Text(postInfo[index].title!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              onTap: () {
                close(context, postInfo[index]);
                // navigateToPostDetails(post: postInfo[index], context: context);
              },
            ),
            itemCount: postInfo.length,
          )
        : Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // print(postList);
    final postInfo = query.isNotEmpty
        ? postList!
            .where((element) =>
                    element.name!.toLowerCase().startsWith(query.toLowerCase())
                // ||
                // element.title!.toLowerCase().contains(query.toLowerCase()) ||
                // element.title!.toLowerCase().startsWith(query.toLowerCase())
                )
            .toList()
        : null;

    return postInfo != null
        ? ListView.separated(
            clipBehavior: Clip.antiAlias,
            separatorBuilder: (context, index) {
              return const Divider(
                color: Colors.grey,
                thickness: 0.5,
                indent: 15.0,
                endIndent: 15.0,
              );
            },
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.feed),
              title: Text(postInfo[index].name!),
              // subtitle: Text(postInfo[index].title!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              onTap: () {
                close(context, postInfo[index]);
                // navigateToPostDetails(post: postInfo[index], context: context);
              },
            ),
            itemCount: postInfo.length,
          )
        : Container();
  }
}
