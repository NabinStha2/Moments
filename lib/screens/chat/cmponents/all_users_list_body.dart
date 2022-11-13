import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/bloc/authBloc/auth_bloc.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/screens/profile/components/profile_page.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_circular_progress_indicator_widget.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AllUsersListBody extends StatefulWidget {
  const AllUsersListBody({Key? key}) : super(key: key);

  @override
  _AllUsersListBodyState createState() => _AllUsersListBodyState();
}

class _AllUsersListBodyState extends State<AllUsersListBody> {
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
        RouteNavigation.back(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: AppBarCookieText("Add User"),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: InkWell(
                onTap: () {
                  RouteNavigation.back(context);
                },
                child: const Icon(Icons.arrow_back_rounded)),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AddUserSuccess) {
                CustomSnackbarWidget.showSnackbar(
                  ctx: context,
                  content: "Progress Completed",
                  milliDuration: 400,
                  backgroundColor: Colors.grey,
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoaded) {
                return state.allUsers?.data?.isNotEmpty != null && state.ownerUser != null
                    ? ListView.separated(
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              BlocProvider.of<AuthBloc>(context).clearUserDetails();
                              RouteNavigation.navigate(
                                context,
                                ProfileVisitPage(
                                  isFromSearch: false,
                                  userId: state.allUsers?.data?[index].id ?? "",
                                ),
                              );
                            },
                            splashColor: Colors.grey[400],
                            child: ListTile(
                              title: PoppinsText(
                                state.allUsers?.data?[index].name ?? "",
                                fontSize: 16.0,
                              ),
                              subtitle: Row(
                                children: [
                                  const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    size: 17.0,
                                  ),
                                  hSizedBox0,
                                  PoppinsText(
                                    state.allUsers?.data?[index].email ?? "",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                  ),
                                ],
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: state.allUsers?.data?[index].image?.imageUrl != ""
                                    ? Image.network(
                                        state.allUsers?.data?[index].image?.imageUrl ?? "",
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
                              trailing: CustomIconButtonWidget(
                                onPressed: () async {
                                  BlocProvider.of<AuthBloc>(context).add(AddUserEvent(
                                    context: context,
                                    userId: StorageServices.authStorageValues["id"].toString(),
                                    friend: state.allUsers?.data?[index].id,
                                    creatorId: state.allUsers?.data?[index].id ?? "",
                                    userImageUrl: StorageServices.authStorageValues["imageUrl"] ?? "",
                                    activityName: StorageServices.authStorageValues["name"].toString(),
                                  ));

                                  var notification = OSCreateNotification(
                                    playerIds: List<String>.from(state.allUsers?.data?[index].oneSignalUserId?.map((e) => e) ?? []),
                                    content: state.ownerUser?.data?.friends?.contains(state.allUsers?.data?[index].id) != true
                                        ? "${StorageServices.authStorageValues["name"]} has removed you from friend."
                                        : "${StorageServices.authStorageValues["name"]} has added you to friend.",
                                    heading: "Moments",
                                    bigPicture: state.allUsers?.data?[index].image?.imageUrl,
                                  );

                                  await OneSignal.shared.postNotification(notification);
                                },
                                icon: (state.ownerUser?.data?.friends?.isNotEmpty == true &&
                                        state.ownerUser?.data?.friends?.contains(state.allUsers?.data?[index].id) == true)
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
                        itemCount: state.allUsers?.data?.length.toInt() ?? 0,
                      )
                    : const Center(
                        child: CustomCircularProgressIndicatorWidget(),
                      );
              }
              if (state is AuthError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomIconButtonWidget(
                        onPressed: () {
                          BlocProvider.of<AuthBloc>(context).add(
                            GetAllUser(context: context),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                      vSizedBox0,
                      vSizedBox1,
                      // Text(state.error!, textAlign: TextAlign.center),
                    ],
                  ),
                );
              }
              return const Center(
                child: CustomCircularProgressIndicatorWidget(),
              );
              // return ownerDetails != null
              //     ? ownerDetails!.friends!.contains(state.allUsers![index].id)
              //         ? const Icon(
              //             Icons.delete,
              //             color: Colors.redAccent,
              //           )
              //         : const Icon(Icons.add)
              //     : const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
