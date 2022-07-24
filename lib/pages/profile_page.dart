import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/bloc/activity_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';

import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/bloc/posts_bloc.dart';
import 'package:moment/models/user_model.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:moment/screens/post_details.dart';
import 'package:moment/widgets/image_details.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final bool isFromSearch;
  final bool isFromActivity;
  const ProfilePage({
    Key? key,
    required this.userId,
    required this.isFromSearch,
    this.isFromActivity = false,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? userData;
  UserModel? ownerUserData;
  int userPosts = 0;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).add(
      GetUserById(
        id: widget.userId,
      ),
    );
    BlocProvider.of<AuthBloc>(context).add(
      GetOwnerById(
        id: authStorageValues!["id"],
      ),
    );
    BlocProvider.of<PostsBloc>(context).add(
      GetCreatorPostsEvent(
        creator: widget.userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isFromSearch) {
          BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
            id: authStorageValues!["id"],
          ));
          Navigator.of(context).pop(true);
        }

        if (widget.isFromActivity) {
          BlocProvider.of<ActivityBloc>(context)
              .add(GetActivity(id: authStorageValues!["id"]!));
          Navigator.of(context).pop(true);
        }

        return true;
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: SpinKitCircle(
                  color: Colors.blue,
                  size: 40.0,
                ),
              ),
            );
          }
          if (state is AuthLoaded) {
            log("userData loaded");
            userData = state.user;
            ownerUserData = state.ownerUser;
            // log("User Data: ${userData!.friends}");
          }
          return userData != null && ownerUserData != null
              ? Scaffold(
                  appBar: AppBar(
                    title: Text(userData!.name!),
                    centerTitle: true,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InkWell(
                          onTap: () {
                            if (widget.isFromSearch) {
                              BlocProvider.of<AuthBloc>(context)
                                  .add(GetUserFriends(
                                id: authStorageValues!["id"],
                              ));
                            }
                            if (widget.isFromActivity) {
                              BlocProvider.of<ActivityBloc>(context).add(
                                  GetActivity(id: authStorageValues!["id"]!));
                            }
                            Navigator.of(context).pop(true);
                          },
                          child: const Icon(Icons.arrow_back_rounded)),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 15.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageDetails(
                                        imageUrl: userData!.imageUrl!,
                                      ),
                                    ),
                                  );
                                },
                                child: userData!.imageUrl != ""
                                    ? CircleAvatar(
                                        radius: 35.0,
                                        backgroundImage:
                                            NetworkImage(userData!.imageUrl!),
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
                              const SizedBox(
                                width: 25.0,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData!.name!.toUpperCase(),
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
                                      userData!.email!,
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
                                                  fontFamily: GoogleFonts.lato()
                                                      .fontFamily,
                                                  fontWeight: FontWeight.w100,
                                                  fontSize: 15.0,
                                                ),
                                              );
                                            }
                                            return Text(
                                              userPosts.toString(),
                                              style: TextStyle(
                                                fontFamily: GoogleFonts.lato()
                                                    .fontFamily,
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
                                          userData!.friends!.length.toString(),
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
                          //   "userData!.about! ckabckasjc sak cjsbcajbslcbalkbcl kjsbajsbkja fs af aks sakbk",
                          //   style: TextStyle(
                          //     fontFamily:
                          //         GoogleFonts.playfairDisplay().fontFamily,
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
                          //   height: 10.0,
                          // ),
                          ElevatedButton(
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.blue.shade400),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              BlocProvider.of<AuthBloc>(context)
                                  .add(AddUserEvent(
                                userId: authStorageValues!["id"]!,
                                friend: userData!.id!,
                                creatorId: userData!.id!,
                                userImageUrl:
                                    authStorageValues!["imageUrl"] ?? "",
                                activityName: authStorageValues!["name"]!,
                              ));

                              // var notification = OSCreateNotification(
                              //   playerIds: userData!.oneSignalUserId!
                              //       .map((e) => e.toString())
                              //       .toList(),
                              //   content: userData!.friends!
                              //           .contains(userData!.id!)
                              //       ? "${authStorageValues!["name"]} has removed you from friend."
                              //       : "${authStorageValues!["name"]} has added you to friend.",
                              //   heading: "Moments",
                              //   bigPicture: userData!.imageUrl,
                              // );

                              // await OneSignal.shared
                              //     .postNotification(notification);

                              log("add Success");
                              BlocProvider.of<AuthBloc>(context).add(
                                GetOwnerById(
                                  id: authStorageValues!["id"],
                                ),
                              );
                            },
                            child:
                                ownerUserData!.friends!.contains(userData!.id!)
                                    ? const Text("Remove")
                                    : const Text("Add"),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 2.0,
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          // const SizedBox(
                          //   height: 25.0,
                          // ),
                          // Expanded(
                          //   flex: 1,
                          //   child: SingleChildScrollView(
                          //     child: Column(
                          //       children: [
                          //         ListTile(
                          //           title: Text(
                          //             "Name",
                          //             style: TextStyle(
                          //               fontFamily: GoogleFonts.snippet().fontFamily,
                          //               fontSize: 20.0,
                          //               fontWeight: FontWeight.bold,
                          //             ),
                          //           ),
                          //           subtitle: Text(
                          //             userData!.name,
                          //             style: TextStyle(
                          //               fontFamily: GoogleFonts.inknutAntiqua().fontFamily,
                          //               fontSize: 16.0,
                          //             ),
                          //           ),
                          //           tileColor: Colors.grey[200],
                          //         ),
                          //         const SizedBox(
                          //           height: 5.0,
                          //         ),
                          //         ListTile(
                          //           title: Text(
                          //             "Email",
                          //             style: TextStyle(
                          //               fontFamily: GoogleFonts.snippet().fontFamily,
                          //               fontSize: 20.0,
                          //               fontWeight: FontWeight.bold,
                          //             ),
                          //           ),
                          //           subtitle: Text(
                          //             userData!.email,
                          //             style: TextStyle(
                          //               fontFamily: GoogleFonts.inknutAntiqua().fontFamily,
                          //               fontSize: 16.0,
                          //             ),
                          //           ),
                          //           tileColor: Colors.grey[200],
                          //         ),
                          //         const SizedBox(
                          //           height: 5.0,
                          //         ),
                          //         const SizedBox(
                          //           height: 5.0,
                          //         ),
                          //         ListTile(
                          //           title: Text(
                          //             "About",
                          //             style: TextStyle(
                          //               fontFamily: GoogleFonts.snippet().fontFamily,
                          //               fontSize: 20.0,
                          //               fontWeight: FontWeight.bold,
                          //             ),
                          //           ),
                          //           subtitle: Text(
                          //             userData!.about!,
                          //             style: TextStyle(
                          //               fontFamily: GoogleFonts.inknutAntiqua().fontFamily,
                          //               fontSize: 16.0,
                          //             ),
                          //           ),
                          //           tileColor: Colors.grey[200],
                          //           // shape: ,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Expanded(
                            flex: 2,
                            child: BlocBuilder<PostsBloc, PostsState>(
                              builder: (context, state) {
                                if (state is PostLoading) {
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
                                      itemCount: 8,
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
                                          physics:
                                              const ClampingScrollPhysics(),
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
                                                          isVisit: true,
                                                          isAll: false,
                                                          isFromProfile: false,
                                                          postId:
                                                              posts![index].id!,
                                                          isFromComment: false,
                                                          userVisitId:
                                                              widget.userId,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child:
                                                    posts![index].fileType ==
                                                            "video"
                                                        ? Stack(
                                                            children: [
                                                              Image.network(
                                                                posts[index]
                                                                    .thumbnail,
                                                                height: 500,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder: (BuildContext
                                                                        context,
                                                                    Object
                                                                        exception,
                                                                    StackTrace?
                                                                        stackTrace) {
                                                                  return const Text(
                                                                      '😢Error!');
                                                                },
                                                                loadingBuilder: (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  }
                                                                  return Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      value: loadingProgress.expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              loadingProgress.expectedTotalBytes!
                                                                          : null,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              Positioned(
                                                                top: 0,
                                                                left: 0,
                                                                bottom: 0,
                                                                right: 0,
                                                                child:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                BlocProvider.value(
                                                                          value:
                                                                              BlocProvider.of<PostsBloc>(context),
                                                                          child:
                                                                              Postdetails(
                                                                            isVisit:
                                                                                true,
                                                                            isAll:
                                                                                false,
                                                                            isFromProfile:
                                                                                true,
                                                                            postId:
                                                                                state.postModel![index].id!,
                                                                            isFromComment:
                                                                                false,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  splashRadius:
                                                                      2,
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .play_arrow_rounded,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 35.0,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        : posts[index]
                                                                    .fileUrl !=
                                                                ""
                                                            ? Image.network(
                                                                posts[index]
                                                                    .fileUrl,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder: (BuildContext
                                                                        context,
                                                                    Object
                                                                        exception,
                                                                    StackTrace?
                                                                        stackTrace) {
                                                                  return const Text(
                                                                      '😢Error!');
                                                                },
                                                                loadingBuilder: (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  }
                                                                  return Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      value: loadingProgress.expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              loadingProgress.expectedTotalBytes!
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
                                                                    Alignment
                                                                        .center,
                                                                isAntiAlias:
                                                                    true,
                                                                filterQuality:
                                                                    FilterQuality
                                                                        .high,
                                                              )
                                                            : Image.network(
                                                                "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.6nCVjA0S936UiBlDUsov4QAAAA%26pid%3DApi%26h%3D160&f=1",
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: 400.0,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                isAntiAlias:
                                                                    true,
                                                                filterQuality:
                                                                    FilterQuality
                                                                        .high,
                                                              ),
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Text("No Posts Yet."));
                                }
                                return const Center(
                                    child: Text("No Posts Yet."));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: userData != null ? Text(userData!.name!) : null,
                    centerTitle: true,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InkWell(
                          onTap: () {
                            if (widget.isFromSearch) {
                              BlocProvider.of<AuthBloc>(context)
                                  .add(GetUserFriends(
                                id: authStorageValues!["id"],
                              ));
                            }
                            Navigator.of(context).pop(true);
                          },
                          child: const Icon(Icons.arrow_back_rounded)),
                    ),
                  ),
                  body: const Center(child: Text("Loading...")));
        },
      ),
    );
  }
}
