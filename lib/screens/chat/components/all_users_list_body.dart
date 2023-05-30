import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/models/user_model/individual_user_model.dart';
import 'package:moment/models/user_model/users_model.dart';
import 'package:moment/screens/profile/components/profile_visit_page.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';
import 'package:moment/widgets/custom_error_widget.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../widgets/custom_all_shimmer_widget.dart';

class AllUsersListBody extends StatefulWidget {
  const AllUsersListBody({Key? key}) : super(key: key);

  @override
  _AllUsersListBodyState createState() => _AllUsersListBodyState();
}

class _AllUsersListBodyState extends State<AllUsersListBody> {
  UserModel? allUsers;
  IndividualUserModel? ownerUser;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getOwnerDetails();
      getAllUsers();
    });
  }

  getOwnerDetails() {
    BlocProvider.of<AuthBloc>(context).add(
      GetOwnerById(
        context: context,
        id: StorageServices.authStorageValues["id"],
      ),
    );
  }

  getAllUsers() async {
    BlocProvider.of<AuthBloc>(context).add(
      GetAllUser(context: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: MColors.primaryColor,
        appBar: AppBar(
          title: AppBarCookieText("Add User"),
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
        body: Container(
          alignment: Alignment.center,
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AddUserSuccess) {
                BlocProvider.of<AuthBloc>(context).add(
                  GetOwnerById(
                    context: context,
                    id: StorageServices.authStorageValues["id"],
                  ),
                );
                BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
                  context: context,
                  id: StorageServices.authStorageValues["id"],
                ));
                CustomSnackbarWidget.showSnackbar(
                  ctx: context,
                  content: "Progress Completed",
                  milliDuration: 500,
                  backgroundColor: Colors.grey,
                );
              }
            },
            builder: (context, state) {
              if (state is GetAllUsersLoading) {
                return CustomAllShimmerWidget.chatShimmerWidget();
              } else if (state is GetAllUsersFailure ||
                  state is GetUserByIdFailure) {
                return CustomErrorWidget(
                  message: state is GetAllUsersFailure
                      ? state.error
                      : state is GetUserByIdFailure
                          ? state.error
                          : "Error",
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(
                      GetAllUser(context: context),
                    );
                    BlocProvider.of<AuthBloc>(context).add(
                      GetOwnerById(
                        context: context,
                        id: StorageServices.authStorageValues["id"],
                      ),
                    );
                  },
                );
              } else if (state is AuthLoaded) {
                allUsers = state.allUsers;
                ownerUser = state.ownerUser;
              }

              return allUsers?.data?.isNotEmpty != null && ownerUser != null
                  ? RefreshIndicator(color: Colors.white,
                      onRefresh: () async {
                        BlocProvider.of<AuthBloc>(context).add(
                          GetAllUser(context: context),
                        );
                        BlocProvider.of<AuthBloc>(context).add(
                          GetOwnerById(
                            context: context,
                            id: StorageServices.authStorageValues["id"],
                          ),
                        );
                      },
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              BlocProvider.of<AuthBloc>(context)
                                  .clearUserDetails();
                              RouteNavigation.navigate(
                                context,
                                ProfileVisitPage(
                                  isFromSearch: false,
                                  userId: allUsers?.data?[index].id ?? "",
                                ),
                              );
                            },
                            splashColor: Colors.grey[400],
                            // ignore: sort_child_properties_last
                            child: ListTile(
                              title: CustomText(
                                allUsers?.data?[index].name ?? "",
                                fontSize: 16.0,
                              ),
                              subtitle: Row(
                                children: [
                                  const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    size: 17.0,
                                    color: MColors.primaryGrayColor50,
                                  ),
                                  hSizedBox0,
                                  CustomText(
                                    allUsers?.data?[index].email ?? "",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                    color: MColors.primaryGrayColor50,
                                  ),
                                ],
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child:
                                    allUsers?.data?[index].image?.imageUrl != ""
                                        ? Image.network(
                                            allUsers?.data?[index].image
                                                    ?.imageUrl ??
                                                "",
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            height: 50,
                                            width: 50,
                                            filterQuality: FilterQuality.high,
                                            isAntiAlias: true,
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
                              trailing: state is AddUserLoading &&
                                      index == selectedIndex
                                  ? const SizedBox(
                                      width: 100,
                                      child:
                                          CustomCircularProgressIndicatorWidget())
                                  : CustomIconButtonWidget(
                                      onPressed: () async {
                                        setState(() {
                                          selectedIndex = index;
                                        });

                                        BlocProvider.of<AuthBloc>(context)
                                            .add(AddUserEvent(
                                          context: context,
                                          userId: StorageServices
                                              .authStorageValues["id"]
                                              .toString(),
                                          friend: allUsers?.data?[index].id,
                                          creatorId:
                                              allUsers?.data?[index].id ?? "",
                                          userImageUrl:
                                              StorageServices.authStorageValues[
                                                      "imageUrl"] ??
                                                  "",
                                          activityName: StorageServices
                                              .authStorageValues["name"]
                                              .toString(),
                                        ));

                                        var notification = OSCreateNotification(
                                          playerIds: List<String>.from(allUsers
                                                  ?.data?[index].oneSignalUserId
                                                  ?.map((e) => e) ??
                                              []),
                                          content: ownerUser?.data?.friends
                                                      ?.contains(allUsers
                                                          ?.data?[index].id) ??
                                                  false
                                              ? "${StorageServices.authStorageValues["name"]} has removed you from friend."
                                              : "${StorageServices.authStorageValues["name"]} has added you to friend.",
                                          heading: "Moments",
                                          bigPicture: allUsers
                                              ?.data?[index].image?.imageUrl,
                                        );

                                        await OneSignal.shared
                                            .postNotification(notification);
                                      },
                                      icon: (ownerUser?.data?.friends
                                                      ?.isNotEmpty ==
                                                  true &&
                                              ownerUser?.data?.friends
                                                      ?.contains(allUsers
                                                          ?.data?[index].id) ==
                                                  true)
                                          ? const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            )
                                          : const Icon(
                                              Icons.add,
                                              color: Colors.grey,
                                            ),
                                    ),
                            ),
                          );
                          // : Container();
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            color: Colors.grey,
                            height: 1.0,
                            endIndent: 15.0,
                            indent: 80.0,
                            thickness: 0.3,
                          );
                        },
                        itemCount: allUsers?.data?.length.toInt() ?? 0,
                      ),
                    )
                  : const Center(
                      child: CustomCircularProgressIndicatorWidget(),
                    );
            },
          ),
        ),
      ),
    );
  }
}
