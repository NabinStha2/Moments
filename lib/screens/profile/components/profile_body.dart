import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/models/post_model/post_model.dart';
import 'package:moment/screens/posts/post_details/post_details_screen.dart';
import 'package:moment/screens/profile/components/profile_header_body.dart';
import 'package:moment/screens/profile/components/profile_video_card.dart';
import 'package:moment/screens/profile/components/widgets/profile_image_card.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_all_shimmer_widget.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';
import 'package:moment/widgets/custom_modal_bottom_sheet_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../bloc/profile_posts_bloc/profile_posts_bloc.dart';
import '../../../models/user_model/individual_user_model.dart';
import '../../../services/one_signal_services.dart';
import '../../../widgets/custom_error_widget.dart';

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
  List<PostModelData>? posts;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // consolelog(StorageServices.authStorageValues);

      if (StorageServices.authStorageValues.isNotEmpty && StorageServices.authStorageValues["rememberMe"] == "true") {
        timer = Timer(Duration(seconds: expiredToken!), () {
          setState(() {
            decodedToken();
          });
        });
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
    var profilePostsBloc = BlocProvider.of<ProfilePostsBloc>(context);
    return StorageServices.authStorageValues.isNotEmpty == true
        ? Scaffold(
            appBar: AppBar(
              title: AppBarCookieText(StorageServices.authStorageValues["name"] ?? ""),
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
                                  RouteNavigation.back(context);
                                },
                              ),
                              onTap: () {
                                _logout();
                                RouteNavigation.back(context);
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
                    ProfileHeaderBody(userPostsLength: userPostsLength),
                    vSizedBox0,
                    vSizedBox1,
                    const Divider(
                      color: Colors.grey,
                      thickness: 2.0,
                    ),
                    vSizedBox0,
                    vSizedBox1,
                    Flexible(
                      child: BlocBuilder<ProfilePostsBloc, ProfilePostsState>(
                        builder: (context, state) {
                          if (state is ProfilePostsLoading || state is PostDeleteLoading) {
                            return CustomAllShimmerWidget.creatorPostsShimmerWidget(userPostsLength: userPostsLength);
                          } else if (state is ProfilePostsFailure) {
                            return CustomErrorWidget(
                              message: state.error,
                              onPressed: () {
                                profilePostsBloc.add(
                                  GetProfilePostsEvent(
                                    context: context,
                                    creator: StorageServices.authStorageValues["id"] ?? "",
                                  ),
                                );
                              },
                            );
                          } else if (state is ProfilePostsSuccess) {
                            if (state.postModel != null) {
                              userPostsLength = state.postModel!.length;
                            } else {
                              userPostsLength = 0;
                            }
                            posts = state.postModel;
                            posts = posts?.reversed.toList();
                          }
                          return posts?.isNotEmpty == true
                              ? RefreshIndicator(
                                  onRefresh: () async {
                                    profilePostsBloc.add(
                                      GetProfilePostsEvent(
                                        context: context,
                                        creator: StorageServices.authStorageValues["id"] ?? "",
                                      ),
                                    );
                                  },
                                  child: GridView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: (posts?.length ?? 0) > 10 ? 3 : 2,
                                      crossAxisSpacing: 5.0,
                                      mainAxisSpacing: 5.0,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: posts?.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => BlocProvider.value(
                                                value: BlocProvider.of<PostsBloc>(context),
                                                child: PostDetailsScreen(
                                                  postId: posts?[index].id ?? "",
                                                  isFromComment: false,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: posts?[index].fileType == "video"
                                            ? ProfileVideoCard(
                                                fileUrlThumbnail: posts?[index].file?.thumbnail,
                                                postId: posts?[index].id,
                                              )
                                            : posts?[index].file?.fileUrl != ""
                                                ? ProfileImageCard(
                                                    fileUrl: posts?[index].file?.fileUrl,
                                                  )
                                                : const ProfileImageCard(
                                                    fileUrl:
                                                        "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.6nCVjA0S936UiBlDUsov4QAAAA%26pid%3DApi%26h%3D160&f=1",
                                                  ),
                                      );
                                    },
                                  ),
                                )
                              : CustomErrorWidget(
                                  message: "No Posts Yet!",
                                  onPressed: () {
                                    profilePostsBloc.add(
                                      GetProfilePostsEvent(
                                        context: context,
                                        creator: StorageServices.authStorageValues["id"] ?? "",
                                      ),
                                    );
                                  },
                                );
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
