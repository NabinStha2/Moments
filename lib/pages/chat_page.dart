// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/bloc/activity_bloc.dart';
import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/models/chat_model.dart';
import 'package:moment/pages/activity_page.dart';
import 'package:moment/pages/chatting_page.dart';
import 'package:moment/pages/profile_page.dart';
import 'package:moment/pages/users_page.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:moment/screens/news_feed_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

List<ChatModel>? allUsersDataList;

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool emptyFriendsList = false;
  bool showTooltip = true;
  String selectedSound = "landras_dream";

  @override
  void initState() {
    super.initState();
    getStorageItem();

    log("AuthStorageValues from chat page: $authStorageValues");

    if (authStorageValues != null && authStorageValues!.isNotEmpty) {
      BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
        id: authStorageValues!["id"],
      ));
      BlocProvider.of<AuthBloc>(context).add(
        GetAllUser(),
      );
      Timer.run(() {
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            showTooltip = false;
          });
        });
      });
    }
  }

  getStorageItem() async {
    authStorageValues = await getStorage();
    log("Calling get storage from chat page: $authStorageValues");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Message",
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 10.0),
            iconSize: 24.0,
            onPressed: () async {
              if (authStorageValues != null && authStorageValues!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: BlocProvider.of<ActivityBloc>(context),
                      child: const ActivityPage(),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  content: Text("First Sign In!"),
                ));
              }
            },
            icon: const Icon(
              Icons.notifications,
            ),
          ),
          IconButton(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 10.0),
            iconSize: 24.0,
            onPressed: () async {
              ChatModel searchSelectedUser = await showSearch(
                context: context,
                delegate: UserDataSearch(),
              );
              if (searchSelectedUser != null) {
                // inspect(searchSelectedUser);
                // ignore: use_build_context_synchronously
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        isFromSearch: true,
                        userId: searchSelectedUser.id!,
                      ),
                    ));
              }
            },
            icon: const FaIcon(
              FontAwesomeIcons.search,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (authStorageValues != null && authStorageValues!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UsersPage(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text("Login First!"),
                backgroundColor: Colors.red,
                duration: Duration(milliseconds: 400),
              ));
          }
        },
        clipBehavior: Clip.antiAlias,
        child: const Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoaded) {
            allUsersDataList = BlocProvider.of<AuthBloc>(context).allUsers;

            log("All users data list: $allUsersDataList");
            return state.userFriends != null && state.userFriends!.isNotEmpty
                ? Container(
                    alignment: Alignment.center,
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChattingPage(
                                    chatDetail: state.userFriends![index],
                                  );
                                },
                              ),
                            );
                          },
                          splashColor: Colors.grey[400],
                          child: ListTile(
                            title: Text(state.userFriends![index].name),
                            subtitle: Row(
                              children: [
                                const Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 17.0,
                                ),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                Text(state.userFriends![index].email),
                              ],
                            ),
                            trailing: SimpleTooltip(
                              tooltipTap: () {
                                print("Tooltip tap");
                              },
                              content: const Text(
                                "Invite a Friend to come Online",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              animationDuration:
                                  const Duration(milliseconds: 700),
                              show: index == 0 && showTooltip,
                              hideOnTooltipTap: true,
                              ballonPadding: const EdgeInsets.all(1),
                              arrowLength: 10,
                              arrowBaseWidth: 8,
                              borderWidth: 1,
                              borderColor: Colors.grey,
                              tooltipDirection: TooltipDirection.left,
                              child: IconButton(
                                icon: const Icon(Icons.online_prediction),
                                onPressed: () async {
                                  log("requesting!!!");
                                  inspect(state
                                      .userFriends![index].oneSignalUserId);
                                  var deviceState =
                                      await OneSignal.shared.getDeviceState();

                                  if (deviceState != null &&
                                      deviceState.userId != null) {
                                    var notification = OSCreateNotification(
                                      playerIds: state
                                          .userFriends![index].oneSignalUserId!
                                          .map((e) => e.toString())
                                          .toList(),
                                      content:
                                          "${authStorageValues!["name"]} has invited to you to come online.",
                                      heading: "Moments",
                                      bigPicture:
                                          state.userFriends![index].imageUrl,
                                    );

                                    await OneSignal.shared
                                        .postNotification(notification);
                                  }
                                },
                              ),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: state.userFriends![index].imageUrl != ""
                                  ? Image.network(
                                      state.userFriends![index].imageUrl!,
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
                      itemCount: state.userFriends!.length,
                    ),
                  )
                : const Center(
                    child: Text("No chat. Start a new..."),
                  );
          }
          if (state is AuthError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
                      id: authStorageValues!["id"],
                    ));
                  },
                  icon: const Icon(Icons.refresh),
                ),
                const SizedBox(height: 15),
                // Text(state.error!, textAlign: TextAlign.center),
              ],
            );
          }
          if (authStorageValues != null && authStorageValues!.isEmpty) {
            // ScaffoldMessenger.of(context)
            //   ..hideCurrentSnackBar()
            //   ..showSnackBar(const SnackBar(
            //     content: Text("Login First!"),
            //     backgroundColor: Colors.red,
            //     duration: Duration(milliseconds: 400),
            //   ));
            return const Center(
              child: Text("First Login!"),
            );
          } else {
            return const Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 40.0,
              ),
            );
          }
        },
      ),
    );
  }
}

class UserDataSearch extends SearchDelegate {
  final allUsersList = allUsersDataList;

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
    final userInfo = query.isNotEmpty
        ? allUsersList!
            .where((element) =>
                element.name.toLowerCase().startsWith(query.toLowerCase()) ||
                element.email.toLowerCase().contains(query.toLowerCase()))
            .toList()
        : null;

    return userInfo != null
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
              title: Text(userInfo[index].name),
              subtitle: Text(userInfo[index].email),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              onTap: () {
                close(context, userInfo[index]);
              },
            ),
            itemCount: userInfo.length,
          )
        : Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // print(postList);
    final userInfo = query.isNotEmpty
        ? allUsersList!
            .where((element) =>
                element.name.toLowerCase().startsWith(query.toLowerCase()) ||
                element.email.toLowerCase().contains(query.toLowerCase()))
            .toList()
        : null;

    return userInfo != null
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
              title: Text(userInfo[index].name),
              subtitle: Text(userInfo[index].email),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              onTap: () {
                close(context, userInfo[index]);
              },
            ),
            itemCount: userInfo.length,
          )
        : Container();
  }
}
