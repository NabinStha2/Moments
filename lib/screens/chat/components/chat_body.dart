import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/app/dimension/dimension.dart';
import 'package:moment/bloc/auth_bloc/auth_bloc.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/models/user_model/users_model.dart';
import 'package:moment/screens/chat/chatting_details/chatting_details_screen.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_all_shimmer_widget.dart';
import 'package:moment/widgets/custom_cached_network_image_widget.dart';
import 'package:moment/widgets/custom_error_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class ChatBody extends StatefulWidget {
  const ChatBody({Key? key}) : super(key: key);

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  List<UserData>? userFriendsList = [];
  bool showTooltip = true;
  bool emptyFriendsList = false;
  String selectedSound = "landras_dream";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.run(() {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showTooltip = false;
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (StorageServices.authStorageValues.isEmpty) {
          return Center(
            child: CustomText("First Login!"),
          );
        }
        if (state is GetUserFriendsLoading) {
          return CustomAllShimmerWidget.chatShimmerWidget();
        } else if (state is GetUserFriendsFailure) {
          return CustomErrorWidget(
            message: state.error,
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
                context: context,
                id: StorageServices.authStorageValues["id"],
              ));
            },
          );
        } else if (state is AuthLoaded) {
          userFriendsList = state.userFriends?.data;
        }
        return userFriendsList != null && userFriendsList?.isNotEmpty == true
            ? RefreshIndicator(color: Colors.white,
                onRefresh: () async {
                  BlocProvider.of<AuthBloc>(context).add(
                    GetUserFriends(
                      context: context,
                      id: StorageServices.authStorageValues["id"],
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          userFriendsList?[index] != null
                              ? RouteNavigation.navigate(
                                  context,
                                  ChattingDetailsScreen(
                                    chatDetail:
                                        userFriendsList?[index] ?? UserData(),
                                  ),
                                )
                              : null;
                        },
                        splashColor: Colors.grey[400],
                        child: ListTile(
                          title: CustomText(userFriendsList?[index].name ?? ""),
                          subtitle: Row(
                            children: [
                              const Icon(
                                Icons.keyboard_arrow_right_rounded,
                                size: 17.0,
                                color: MColors.primaryGrayColor50,
                              ),
                              hSizedBox0,
                              CustomText(
                                userFriendsList?[index].email ?? "",
                                color: MColors.primaryGrayColor50,
                              ),
                            ],
                          ),
                          trailing: SimpleTooltip(
                            backgroundColor: MColors.primaryGrayColor80,
                            tooltipTap: () {},
                            content: CustomText(
                              "Invite a Friend to come Online",
                              fontSize: 10,
                            ),
                            animationDuration:
                                const Duration(milliseconds: 700),
                            show: index == 0 && showTooltip,
                            hideOnTooltipTap: true,
                            ballonPadding: const EdgeInsets.all(1),
                            arrowLength: 10,
                            arrowBaseWidth: 8,
                            borderWidth: 1,
                            borderColor: MColors.primaryGrayColor80,
                            tooltipDirection: TooltipDirection.left,
                            child: IconButton(
                              icon: const Icon(
                                Icons.online_prediction,
                                color: MColors.primaryGrayColor50,
                              ),
                              onPressed: () async {
                                var notification = OSCreateNotification(
                                  playerIds: List<String>.from(
                                      userFriendsList?[index]
                                              .oneSignalUserId
                                              ?.map((e) => e) ??
                                          []),
                                  content:
                                      "${StorageServices.authStorageValues["name"]} has invited to you to come online.",
                                  heading: "Moments",
                                  bigPicture:
                                      userFriendsList?[index].image?.imageUrl,
                                );

                                await OneSignal.shared
                                    .postNotification(notification);
                              },
                            ),
                          ),
                          leading: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child:
                                  userFriendsList?[index].image?.imageUrl != ""
                                      ? CustomCachedNetworkImageWidget(
                                          imageUrl: userFriendsList?[index]
                                                  .image
                                                  ?.imageUrl ??
                                              "",
                                          height: 50,
                                          width: 50,
                                        )
                                      : const CustomCachedNetworkImageWidget(
                                          imageUrl:
                                              "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn3.iconfinder.com%2Fdata%2Ficons%2Fbusiness-round-flat-vol-1-1%2F36%2Fuser_account_profile_avatar_person_student_male-512.png&f=1&nofb=1",
                                          height: 50,
                                          width: 50,
                                        )),
                        ),
                      );
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
                    itemCount: userFriendsList?.length ?? 0,
                  ),
                ),
              )
            : Center(
                child: CustomText("No chat. Start a new..."),
              );
      },
    );
  }
}
