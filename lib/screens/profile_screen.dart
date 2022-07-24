// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/bloc/posts_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/models/user_model.dart';
import 'package:moment/screens/auth_screen.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:moment/screens/news_feed_screen.dart';
import 'package:moment/screens/post_details.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLogin = true;
  bool enabled = false;
  Timer? _timer;
  int? expiredToken = 1;
  List choose = ["camera", "gallery"];
  final _picker = ImagePicker();
  File? selectedFile;
  String? fileName;
  UserModel? userProfileData;
  int userPosts = 0;

  @override
  void initState() {
    getStorageItem();
    // log("hey");
    // log("Is Login: $isLogin");
    if (isLogin) {
      _timer = Timer(Duration(seconds: expiredToken!), () {
        // print("timer");
        setState(() {
          decodedToken();
        });
      });
    }
    BlocProvider.of<PostsBloc>(context).add(
      GetCreatorPostsEvent(
        creator: widget.userId,
      ),
    );

    super.initState();
  }

  getStorageItem() async {
    authStorageValues = await getStorage();
    setState(() {});
    log("Calling get storage from profile screen: $authStorageValues");
  }

  decodedToken() async {
    // print("hey");
    final authStorageValues = await storage.readAll();
    // print("Profile: $authStorageValues");
    if (authStorageValues.containsKey("token") == true) {
      String token = authStorageValues["token"]!;

      DateTime expirationDate = JwtDecoder.getExpirationDate(token);
      // print(expirationDate);
      setState(() {
        expiredToken = expirationDate.second;
      });

      bool isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        _logout();
      }
    }
  }

  _logout() async {
    var deviceState = await handleGetDeviceState();
    _timer?.cancel();
    await storage.deleteAll(
      aOptions: const AndroidOptions(),
      iOptions: IOSOptions(
        accountName: accountNameController.text.isEmpty
            ? null
            : accountNameController.text,
      ),
    );
    if (deviceState != null && deviceState.userId != null) {
      inspect(deviceState.userId!);
      BlocProvider.of<AuthBloc>(context).add(LogoutEvent(
        id: widget.userId,
        oneSignalUserId: deviceState.userId!,
      ));
    }
    setState(() {
      isLogin = false;
    });
    // log("$isLogin");
  }

  Future<void> _chooseImage(String source) async {
    final pickedFile = await _picker.pickImage(
      source: source == "camera" ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 100,
    );

    setState(() {
      if (pickedFile != null) {
        selectedFile = File(pickedFile.path);
        // inspect("From ProfileScreen 172: $selectedFile");
      }
    });

    if (pickedFile == null) {
      LostData response = await _picker.getLostData();

      if (response.isEmpty) {
        return;
      }
      if (response.file != null) {
        setState(() {
          if (pickedFile != null) {
            selectedFile = File(response.file!.path);
            // inspect("From ProfileScreen 186: $selectedFile");
          }
        });
      } else {
        print(response.file);
      }
    }

    if (selectedFile != null) {
      BlocProvider.of<AuthBloc>(context).add(UploadImageEvent(
        id: authStorageValues!["id"]!,
        image: selectedFile,
      ));
    }
  }

  Future<void> _showDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose:"),
          content: Container(
            width: 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: choose.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(choose[index]),
                  onTap: () {
                    _chooseImage(choose[index]);
                    Navigator.pop(context);
                  },
                );
              },
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

  @override
  Widget build(BuildContext context) {
    log("Build: $isLogin");
    // BlocProvider.of<AuthBloc>(context).add(
    //   GetUserById(
    //     id: authStorageValues!["id"],
    //   ),
    // );
    // print(userProfileData.image);
    if (!isLogin) {
      return const AuthScreen();
    } else {
      return WillPopScope(
        onWillPop: () async {
          // posts.clear();
          // BlocProvider.of<PostsBloc>(context).add(GetPostsEvent());
          return true;
        },
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          if (state is AuthLoaded) {
            log("${state.ownerUser!.friends}");
            return Scaffold(
              appBar: AppBar(
                title: Text(state.ownerUser!.name!),
                actions: [
                  IconButton(
                    onPressed: () {
                      showMaterialModalBottomSheet(
                        bounce: true,
                        enableDrag: true,
                        expand: false,
                        clipBehavior: Clip.antiAlias,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        context: context,
                        builder: (context) => SizedBox(
                          height: 80,
                          child: Column(
                            children: [
                              // ListTile(
                              //   title: const Text('Edit'),
                              //   leading: const Icon(Icons.edit),
                              //   onTap: () => Navigator.of(context).pop(),
                              // ),
                              ListTile(
                                title: const Text('Logout'),
                                leading: const Icon(Icons.logout),
                                onTap: () {
                                  _logout();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.menu_rounded,
                      size: 26,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showDialog();
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: state.ownerUser!.imageUrl != ""
                                      ? CircleAvatar(
                                          radius: 35.0,
                                          backgroundImage: NetworkImage(
                                            state.ownerUser!.imageUrl!,
                                          ),
                                          onBackgroundImageError:
                                              (object, stackTrace) {
                                            // inspect(object);
                                            // print(object);
                                            const Center(
                                              child: Text(
                                                "Error",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : CircleAvatar(
                                          radius: 35.0,
                                          child: Image.network(
                                            "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                                          ),
                                        ),
                                ),
                                Positioned(
                                  top: 30,
                                  left: 35,
                                  child: IconButton(
                                    splashRadius: 20.0,
                                    onPressed: () {
                                      _showDialog();
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.camera,
                                      color: Colors.blue,
                                      size: 20.0,
                                      // color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 35.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  state.ownerUser!.name!.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.redressed().fontFamily,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20.0,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  state.ownerUser!.email!,
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.balthazar().fontFamily,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20.0,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  children: [
                                    BlocBuilder<PostsBloc, PostsState>(
                                      builder: (context, state) {
                                        if (state is CreatorPostsLoaded) {
                                          return Text(
                                            state.postModel != null
                                                ? state.postModel!.length
                                                    .toString()
                                                : userPosts.toString(),
                                            style: TextStyle(
                                              fontFamily:
                                                  GoogleFonts.lato().fontFamily,
                                              fontWeight: FontWeight.w100,
                                              fontSize: 15.0,
                                            ),
                                          );
                                        }
                                        return Text(
                                          userPosts.toString(),
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.lato().fontFamily,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 15.0,
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      "  posts",
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.lato().fontFamily,
                                        fontWeight: FontWeight.w100,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    Text(
                                      state.ownerUser!.friends!.length
                                          .toString(),
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.lato().fontFamily,
                                        fontWeight: FontWeight.w100,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    Text(
                                      "  friends",
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.lato().fontFamily,
                                        fontWeight: FontWeight.w100,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // AutoSizeText(
                      //   "state.ownerUser!.about! ckabckasjc sak cjsbcajbslcbalkbcl kjsbajsbkja fs af aks sakbk",
                      //   style: TextStyle(
                      //     fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.black87,
                      //     fontStyle: FontStyle.italic,
                      //     fontSize: 16.0,
                      //   ),
                      //   minFontSize: 16,
                      //   maxLines: 10,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                      // const SizedBox(
                      //   height: 15.0,
                      // ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 2.0,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Expanded(
                        flex: 2,
                        child: BlocBuilder<PostsBloc, PostsState>(
                          builder: (context, state) {
                            if (state is PostLoading ||
                                state is PostDeleteLoading) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: GridView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: userPosts > 10 ? 3 : 2,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                  ),
                                  itemCount: 6,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      height: 400,
                                      alignment: Alignment.center,
                                      child: Image.network(
                                        "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.6nCVjA0S936UiBlDUsov4QAAAA%26pid%3DApi%26h%3D160&f=1",
                                        height: 400,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                            if (state is CreatorPostsLoaded) {
                              if (state.postModel != null) {
                                log("Creator Post Loaded");
                                userPosts = state.postModel!.length;
                              } else {
                                userPosts = 0;
                              }

                              var posts = state.postModel;
                              if (posts != null) {
                                posts = posts.reversed.toList();
                              }

                              return posts != null && posts.isNotEmpty
                                  ? GridView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      clipBehavior: Clip.antiAlias,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            posts.length > 10 ? 3 : 2,
                                        crossAxisSpacing: 8.0,
                                        mainAxisSpacing: 8.0,
                                      ),
                                      itemCount: posts.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          height: 500,
                                          alignment: Alignment.center,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BlocProvider.value(
                                                    value: BlocProvider.of<
                                                        PostsBloc>(context),
                                                    child: Postdetails(
                                                      isVisit: false,
                                                      isAll: false,
                                                      isFromProfile: true,
                                                      postId: posts![index].id!,
                                                      isFromComment: false,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: posts![index].fileType ==
                                                    "video"
                                                ? Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.network(
                                                          posts[index]
                                                              .thumbnail,
                                                          height: 500,
                                                          errorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Object
                                                                      exception,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                            return Text(
                                                                '😢Error!');
                                                          },
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return Center(
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
                                                            );
                                                          },
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        left: 0,
                                                        bottom: 0,
                                                        right: 0,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    BlocProvider
                                                                        .value(
                                                                  value: BlocProvider
                                                                      .of<PostsBloc>(
                                                                          context),
                                                                  child:
                                                                      Postdetails(
                                                                    isVisit:
                                                                        false,
                                                                    isAll:
                                                                        false,
                                                                    isFromProfile:
                                                                        true,
                                                                    postId: state
                                                                        .postModel![
                                                                            index]
                                                                        .id!,
                                                                    isFromComment:
                                                                        false,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          splashRadius: 2,
                                                          icon: const Icon(
                                                            Icons
                                                                .play_arrow_rounded,
                                                            color: Colors.white,
                                                            size: 35.0,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : posts[index].fileUrl != ""
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.network(
                                                          posts[index].fileUrl,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Object
                                                                      exception,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                            return Text(
                                                                '😢Error!');
                                                          },
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return Center(
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
                                                            );
                                                          },
                                                          height: 400.0,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          alignment:
                                                              Alignment.center,
                                                          isAntiAlias: true,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .high,
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.network(
                                                          "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.6nCVjA0S936UiBlDUsov4QAAAA%26pid%3DApi%26h%3D160&f=1",
                                                          fit: BoxFit.cover,
                                                          height: 400.0,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          alignment:
                                                              Alignment.center,
                                                          isAntiAlias: true,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .high,
                                                        ),
                                                      ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(child: Text("No Posts Yet."));
                            }
                            return const Center(child: Text("No Posts Yet."));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }),
      );
    }
  }
}
