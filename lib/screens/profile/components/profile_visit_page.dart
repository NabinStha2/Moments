import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/models/user_model/individual_user_model.dart';
import 'package:moment/screens/posts/post_details/post_details_screen.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';
import 'package:moment/widgets/custom_image_details_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../bloc/profile_posts_bloc/profile_posts_bloc.dart';
import '../../../bloc/profile_visit_posts_bloc/profile_visit_posts_bloc.dart';
import '../../../widgets/custom_all_shimmer_widget.dart';
import '../../../widgets/custom_button_widget.dart';

class ProfileVisitPage extends StatefulWidget {
  final String userId;
  final bool isFromSearch;
  final bool isFromActivity;
  const ProfileVisitPage({
    Key? key,
    required this.userId,
    required this.isFromSearch,
    this.isFromActivity = false,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileVisitPage> {
  IndividualUserModel? userData;
  IndividualUserModel? ownerUserData;
  List<PostModelData>? posts;
  int userPostsLength = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BlocProvider.of<AuthBloc>(context).add(
        GetUserById(
          id: widget.userId,
          context: context,
        ),
      );
      BlocProvider.of<AuthBloc>(context).add(
        GetOwnerById(
          context: context,
          id: StorageServices.authStorageValues["id"],
        ),
      );
      BlocProvider.of<ProfileVisitPostsBloc>(context).add(
        GetProfileVisitPostsEvent(
          context: context,
          creator: widget.userId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<ProfilePostsBloc>(context).add(
          GetProfilePostsEvent(
            context: context,
            creator: StorageServices.authStorageValues["id"] ?? "",
          ),
        );
        return true;
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoaded) {
            // log("userData loaded");
            userData = BlocProvider.of<AuthBloc>(context).userModel;
            ownerUserData = BlocProvider.of<AuthBloc>(context).ownerUserModel;
          }
          return userData?.data != null && ownerUserData?.data != null
              ? scaffoldWhenDataIsNotEmpty(context)
              : scaffoldWhenDataEmpty(context);
        },
      ),
    );
  }

  Scaffold scaffoldWhenDataEmpty(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.primaryColor,
      appBar: AppBar(
        title: AppBarCookieText(userData?.data?.name ?? ""),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: InkWell(
              onTap: () {
                // if (widget.isFromSearch) {
                //   BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
                //     context: context,
                //     id: StorageServices.authStorageValues["id"],
                //   ));
                // }
                RouteNavigation.back(context);
              },
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              )),
        ),
      ),
      body: const Center(
        child: SpinKitCircle(
          color: MColors.primaryGrayColor50,
          size: 40.0,
        ),
      ),
    );
  }

  Scaffold scaffoldWhenDataIsNotEmpty(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.primaryColor,
      appBar: AppBar(
        title: AppBarCookieText(userData?.data?.name ?? ""),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: InkWell(
              onTap: () {
                RouteNavigation.back(context);
              },
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              )),
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
                  Hero(
                    tag: "send",
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomImageDetails(
                              imageUrl: userData?.data?.image?.imageUrl ?? "",
                            ),
                          ),
                        );
                      },
                      child: userData?.data?.image?.imageUrl != ""
                          ? CircleAvatar(
                              radius: 35.0,
                              backgroundImage: NetworkImage(
                                  userData?.data?.image?.imageUrl ?? ""),
                              onBackgroundImageError: (object, stackTrace) {
                                // inspect(object);
                                // print(object);
                                Center(
                                  child: CustomText(
                                    "Error",
                                    color: Colors.red,
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
                  ),
                  const SizedBox(
                    width: 25.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          userData?.data?.name?.toUpperCase() ?? "",
                          isFontFamily: true,
                          fontFamily: GoogleFonts.redressed().fontFamily,
                          fontWeight: FontWeight.w900,
                          fontSize: 20.0,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        CustomText(
                          userData?.data?.email ?? "",
                          isFontFamily: true,
                          fontFamily: GoogleFonts.balthazar().fontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            BlocBuilder<ProfileVisitPostsBloc,
                                ProfileVisitPostsState>(
                              builder: (context, state) {
                                if (state.profileVisitPostsStatus ==
                                    ProfileVisitPostsStatus.success) {
                                  return CustomText(
                                    state.postModel != null
                                        ? state.postModel?.length.toString() ??
                                            "0"
                                        : userPostsLength.toString(),
                                    isFontFamily: true,
                                    fontFamily: GoogleFonts.lato().fontFamily,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 15.0,
                                  );
                                }
                                return CustomText(
                                  userPostsLength.toString(),
                                  isFontFamily: true,
                                  fontFamily: GoogleFonts.lato().fontFamily,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 15.0,
                                );
                              },
                            ),
                            CustomText(
                              "  posts",
                              isFontFamily: true,
                              fontFamily: GoogleFonts.lato().fontFamily,
                              fontWeight: FontWeight.w100,
                              fontSize: 15.0,
                            ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            CustomText(
                              userData?.data?.friends?.length.toString() ?? "0",
                              isFontFamily: true,
                              fontFamily: GoogleFonts.lato().fontFamily,
                              fontWeight: FontWeight.w100,
                              fontSize: 15.0,
                            ),
                            CustomText(
                              "  friends",
                              isFontFamily: true,
                              fontFamily: GoogleFonts.lato().fontFamily,
                              fontWeight: FontWeight.w100,
                              fontSize: 15.0,
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
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: ownerUserData?.data?.friends
                                  ?.contains(userData?.data?.id) ==
                              true
                          ? MaterialStateProperty.all(Colors.red.shade400)
                          : MaterialStateProperty.all(Colors.blue.shade400),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      BlocProvider.of<AuthBloc>(context).add(AddUserEvent(
                        context: context,
                        userId: StorageServices.authStorageValues["id"]!,
                        friend: userData?.data?.id,
                        creatorId: userData?.data?.id ?? "",
                        userImageUrl:
                            StorageServices.authStorageValues["imageUrl"] ?? "",
                        activityName:
                            StorageServices.authStorageValues["name"] ?? "",
                      ));
                    },
                    child: state is AddUserLoading
                        ? const SizedBox(
                            width: 50,
                            child: Center(
                              child: CustomCircularProgressIndicatorWidget(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ownerUserData?.data?.friends
                                    ?.contains(userData?.data?.id) ==
                                true
                            ? CustomText("Remove")
                            : CustomText("Add"),
                  );
                },
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
                child:
                    BlocBuilder<ProfileVisitPostsBloc, ProfileVisitPostsState>(
                  builder: (context, state) {
                    if (state.profileVisitPostsStatus ==
                        ProfileVisitPostsStatus.loading) {
                      return CustomAllShimmerWidget.creatorPostsShimmerWidget(
                          userPostsLength: userPostsLength);
                    } else if (state.profileVisitPostsStatus ==
                        ProfileVisitPostsStatus.failure) {
                      return Center(
                        child: CustomIconButtonWidget(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            BlocProvider.of<ProfileVisitPostsBloc>(context).add(
                              GetProfileVisitPostsEvent(
                                context: context,
                                creator: widget.userId,
                              ),
                            );
                          },
                          color: Colors.black,
                          iconSize: 40,
                          elevation: 0.0,
                        ),
                      );
                    } else if (state.profileVisitPostsStatus ==
                        ProfileVisitPostsStatus.success) {
                      if (state.postModel != null) {
                        userPostsLength = state.postModel?.length ?? 0;
                      } else {
                        userPostsLength = 0;
                      }
                      posts = state.postModel;
                      posts = posts?.reversed.toList();
                    }

                    return posts?.isNotEmpty == true
                        ? RefreshIndicator(
                            onRefresh: () async {
                              BlocProvider.of<ProfileVisitPostsBloc>(context)
                                  .add(
                                GetProfileVisitPostsEvent(
                                  context: context,
                                  creator: widget.userId,
                                ),
                              );
                            },
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    (posts?.length ?? 0) > 10 ? 3 : 2,
                                crossAxisSpacing: 5.0,
                                mainAxisSpacing: 5.0,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: posts?.length,
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
                                            value: BlocProvider.of<PostsBloc>(
                                                context),
                                            child: PostDetailsScreen(
                                              postId: posts?[index].id ?? "",
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: posts?[index].fileType == "video"
                                        ? Stack(
                                            children: [
                                              Image.network(
                                                posts?[index].file?.thumbnail ??
                                                    "",
                                                height: 500,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                fit: BoxFit.cover,
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object exception,
                                                    StackTrace? stackTrace) {
                                                  return CustomText('😢Error!');
                                                },
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                  if (loadingProgress == null) {
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
                                                        builder: (context) =>
                                                            BlocProvider.value(
                                                          value: BlocProvider
                                                              .of<ProfilePostsBloc>(
                                                                  context),
                                                          child:
                                                              PostDetailsScreen(
                                                            postId:
                                                                posts?[index]
                                                                        .id ??
                                                                    "",
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
                                        : posts?[index].file?.fileUrl != ""
                                            ? Image.network(
                                                posts?[index].file?.fileUrl ??
                                                    "",
                                                fit: BoxFit.cover,
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object exception,
                                                    StackTrace? stackTrace) {
                                                  return CustomText('😢Error!');
                                                },
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                  if (loadingProgress == null) {
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
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                alignment: Alignment.center,
                                                isAntiAlias: true,
                                                filterQuality:
                                                    FilterQuality.high,
                                              )
                                            : Image.network(
                                                "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.6nCVjA0S936UiBlDUsov4QAAAA%26pid%3DApi%26h%3D160&f=1",
                                                fit: BoxFit.cover,
                                                height: 400.0,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                alignment: Alignment.center,
                                                isAntiAlias: true,
                                                filterQuality:
                                                    FilterQuality.high,
                                              ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(child: CustomText("No Posts Yet."));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
