import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_all_shimmer_widget.dart';

import 'package:moment/bloc/authBloc/auth_bloc.dart';
import 'package:moment/bloc/postsBloc/posts_bloc.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../../models/user_model/individual_user_model.dart';
import '../../../services/one_signal_services.dart';
import '../../../widgets/custom_image_show_dialog_widget.dart';
import '../../post_add/components/post_details.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool enabled = false;
  Timer? timer;
  int? expiredToken = 1;
  String? fileName;
  IndividualUserModel? userProfileData = IndividualUserModel();
  int userPostsLength = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (StorageServices.authStorageValues.isNotEmpty) {
        BlocProvider.of<PostsBloc>(context).add(
          GetCreatorPostsEvent(
            context: context,
            creator: StorageServices.authStorageValues["id"] ?? "",
          ),
        );
        if (StorageServices.authStorageValues["rememberMe"] == "true") {
          timer = Timer(Duration(seconds: expiredToken!), () {
            setState(() {
              decodedToken();
            });
          });
        }
      }
    });

    super.initState();
  }

  decodedToken() async {
    // final StorageServices.authStorageValues = await StorageServices.getStorage();
    if (StorageServices.authStorageValues.containsKey("token") == true) {
      String token = StorageServices.authStorageValues["token"]!;

      DateTime expirationDate = JwtDecoder.getExpirationDate(token);
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
    var authBlocProvider = BlocProvider.of<AuthBloc>(context);
    var deviceId = await OneSignalNotificationService.getDeviceId();
    timer?.cancel();
    authBlocProvider.add(LogoutEvent(
      context: context,
      id: StorageServices.authStorageValues["id"] ?? "",
      oneSignalUserId: deviceId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StorageServices.authStorageValues.isNotEmpty == true
        ? Scaffold(
            appBar: AppBar(
              title: Text(StorageServices.authStorageValues["name"] ?? ""),
              actions: [
                IconButton(
                  onPressed: () {
                    customModalBottomSheetWidget(
                      initialChildSize: 0.15,
                      maxChildSize: 0.15,
                      minChildSize: 0.1,
                      ctx: context,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: PoppinsText(
                                'Logout',
                                fontSize: 16.0,
                              ),
                              leading: CustomIconButtonWidget(
                                icon: const Icon(Icons.logout),
                                iconSize: 20.0,
                                color: Colors.black,
                                onPressed: () {
                                  _logout();
                                  Navigator.of(context).pop();
                                },
                              ),
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
                            customFileShowDialogWidget(isImageOnly: true, ctx: context);
                          },
                          child: Stack(
                            children: [
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is UploadImageLoading) {
                                    return const CircleAvatar(
                                      radius: 35.0,
                                      foregroundColor: Colors.transparent,
                                      child: Center(
                                        child: CustomCircularProgressIndicatorWidget(),
                                      ),
                                    );
                                  } else if (state is AuthLoaded) {
                                    var ownerUser = state.ownerUser;
                                    return Center(
                                      child: ownerUser?.data?.image?.imageUrl != "" && ownerUser?.data?.image?.imageUrl != null
                                          ? CircleAvatar(
                                              radius: 35.0,
                                              backgroundImage: NetworkImage(
                                                ownerUser?.data?.image?.imageUrl ?? "",
                                              ),
                                              onBackgroundImageError: (object, stackTrace) {
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
                                    );
                                  }
                                  return const CircleAvatar(
                                    radius: 35.0,
                                    foregroundColor: Colors.transparent,
                                    child: Center(
                                      child: CustomCircularProgressIndicatorWidget(),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 30,
                                left: 35,
                                child: IconButton(
                                  splashRadius: 20.0,
                                  onPressed: () {
                                    customFileShowDialogWidget(ctx: context, isImageOnly: true);
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
                                StorageServices.authStorageValues["name"] != null
                                    ? StorageServices.authStorageValues["name"]?.toUpperCase() ?? ""
                                    : "",
                                style: TextStyle(
                                  fontFamily: GoogleFonts.redressed().fontFamily,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20.0,
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                StorageServices.authStorageValues["email"] ?? "",
                                style: TextStyle(
                                  fontFamily: GoogleFonts.balthazar().fontFamily,
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
                                          state.postModel != null ? state.postModel?.length.toString() ?? "0" : userPostsLength.toString(),
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.lato().fontFamily,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 15.0,
                                          ),
                                        );
                                      }
                                      return Text(
                                        userPostsLength.toString(),
                                        style: TextStyle(
                                          fontFamily: GoogleFonts.lato().fontFamily,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 15.0,
                                        ),
                                      );
                                    },
                                  ),
                                  Text(
                                    "  posts",
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.lato().fontFamily,
                                      fontWeight: FontWeight.w100,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  Text(
                                    StorageServices.authStorageValues["friends"] != null
                                        ? StorageServices.authStorageValues["friends"]?.split(",").length.toString() ?? "0"
                                        : "0",
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.lato().fontFamily,
                                      fontWeight: FontWeight.w100,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  Text(
                                    "  friends",
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.lato().fontFamily,
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
                          if (state is PostLoading || state is PostDeleteLoading) {
                            return CustomAllShimmerWidget.creatorPostsShimmerWidget(userPostsLength: userPostsLength);
                          }
                          if (state is CreatorPostsLoaded) {
                            if (state.postModel != null) {
                              log("Creator Post Loaded");
                              userPostsLength = state.postModel!.length;
                            } else {
                              userPostsLength = 0;
                            }
                            var posts = state.postModel;
                            if (posts != null) {
                              posts = posts.reversed.toList();
                            }

                            return posts != null && posts.isNotEmpty
                                ? GridView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    clipBehavior: Clip.antiAlias,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: posts.length > 10 ? 3 : 2,
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
                                                builder: (context) => BlocProvider.value(
                                                  value: BlocProvider.of<PostsBloc>(context),
                                                  child: Postdetails(
                                                    isFromProfileVisit: false,
                                                    isFromHome: false,
                                                    isFromProfile: true,
                                                    postId: posts![index].id!,
                                                    isFromComment: false,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: posts![index].fileType == "video"
                                              ? Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Image.network(
                                                        posts[index].file?.thumbnail ?? "",
                                                        height: 500,
                                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                          return const Text('😢Error!');
                                                        },
                                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                          if (loadingProgress == null) {
                                                            return child;
                                                          }
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value: loadingProgress.expectedTotalBytes != null
                                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                  : null,
                                                            ),
                                                          );
                                                        },
                                                        width: MediaQuery.of(context).size.width,
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
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (context) => BlocProvider.value(
                                                                value: BlocProvider.of<PostsBloc>(context),
                                                                child: Postdetails(
                                                                  isFromProfileVisit: false,
                                                                  isFromHome: false,
                                                                  isFromProfile: true,
                                                                  postId: state.postModel![index].id!,
                                                                  isFromComment: false,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        splashRadius: 2,
                                                        icon: const Icon(
                                                          Icons.play_arrow_rounded,
                                                          color: Colors.white,
                                                          size: 35.0,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : posts[index].file?.fileUrl != ""
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Image.network(
                                                        posts[index].file?.fileUrl ?? "",
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                          return const Text('😢Error!');
                                                        },
                                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                          if (loadingProgress == null) {
                                                            return child;
                                                          }
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value: loadingProgress.expectedTotalBytes != null
                                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                  : null,
                                                            ),
                                                          );
                                                        },
                                                        height: 400.0,
                                                        width: MediaQuery.of(context).size.width,
                                                        alignment: Alignment.center,
                                                        isAntiAlias: true,
                                                        filterQuality: FilterQuality.high,
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Image.network(
                                                        "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.6nCVjA0S936UiBlDUsov4QAAAA%26pid%3DApi%26h%3D160&f=1",
                                                        fit: BoxFit.cover,
                                                        height: 400.0,
                                                        width: MediaQuery.of(context).size.width,
                                                        alignment: Alignment.center,
                                                        isAntiAlias: true,
                                                        filterQuality: FilterQuality.high,
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
          )
        : const CustomCircularProgressIndicatorWidget();
  }
}
