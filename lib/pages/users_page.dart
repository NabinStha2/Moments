import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:http/http.dart" as http;
import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/models/chat_model.dart';
import 'package:moment/models/user_model.dart';
import 'package:moment/pages/chat_page.dart';
import 'package:moment/pages/profile_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // List<ChatModel> state.allUsers! = [];
  late Map<String, dynamic> authStorageValues;
  UserModel? ownerDetails;

  @override
  void initState() {
    super.initState();
    // ownerDetails = BlocProvider.of<AuthBloc>(context).userModel;
    getOwnerDetails();

    getAllUsers();
  }

  getOwnerDetails() async {
    authStorageValues = await storage.readAll(
      aOptions: const AndroidOptions(),
    );

    // ignore: use_build_context_synchronously
    BlocProvider.of<AuthBloc>(context).add(
      GetOwnerById(
        id: authStorageValues["id"],
      ),
    );
  }

  getAllUsers() async {
    BlocProvider.of<AuthBloc>(context).add(
      GetAllUser(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
          id: authStorageValues["id"],
        ));
        Navigator.of(context).pop(true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add User"),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: InkWell(
                onTap: () {
                  BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
                    id: authStorageValues["id"],
                  ));
                  Navigator.of(context).pop(true);
                },
                child: const Icon(Icons.arrow_back_rounded)),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              // if (state is AuthLoading) {
              //   ScaffoldMessenger.of(context)
              //     ..removeCurrentSnackBar()
              //     ..showSnackBar(
              //       const SnackBar(
              //         content: Text("Progressing..."),
              //         backgroundColor: Colors.grey,
              //         behavior: SnackBarBehavior.floating,
              //       ),
              //     );
              // }
              if (state is AddUserSuccess) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text("Progress Completed"),
                      duration: Duration(milliseconds: 400),
                      backgroundColor: Colors.grey,
                    ),
                  );
              }
            },
            builder: (context, state) {
              if (state is AuthLoaded) {
                if (state.ownerUser != null) {
                  inspect(state.ownerUser);
                }

                return state.allUsers != null && state.ownerUser != null
                    ? ListView.separated(
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProfilePage(
                                      isFromSearch: false,
                                      userId: state.allUsers![index].id!,
                                    );
                                  },
                                ),
                              );
                            },
                            splashColor: Colors.grey[400],
                            child: ListTile(
                              title: Text(state.allUsers![index].name),
                              subtitle: Row(
                                children: [
                                  const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    size: 17.0,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(state.allUsers![index].email),
                                ],
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: state.allUsers![index].imageUrl != ""
                                    ? Image.network(
                                        state.allUsers![index].imageUrl!,
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
                              trailing: IconButton(
                                splashRadius: 25.0,
                                onPressed: () async {
                                  BlocProvider.of<AuthBloc>(context)
                                      .add(AddUserEvent(
                                    userId: authStorageValues["id"],
                                    friend: state.allUsers![index].id!,
                                    creatorId: state.allUsers![index].id!,
                                    userImageUrl:
                                        authStorageValues["imageUrl"] ?? "",
                                    activityName: authStorageValues["name"],
                                  ));

                                  var notification = OSCreateNotification(
                                    playerIds: state
                                        .allUsers![index].oneSignalUserId!
                                        .map((e) => e.toString())
                                        .toList(),
                                    content: state.ownerUser!.friends!.contains(
                                            state.allUsers![index].id!)
                                        ? "${authStorageValues["name"]} has removed you from friend."
                                        : "${authStorageValues["name"]} has added you to friend.",
                                    heading: "Moments",
                                    bigPicture: state.allUsers![index].imageUrl,
                                  );

                                  await OneSignal.shared
                                      .postNotification(notification);

                                  log("add Success");
                                  BlocProvider.of<AuthBloc>(context).add(
                                    GetOwnerById(
                                      id: authStorageValues["id"],
                                    ),
                                  );
                                },
                                icon: state.ownerUser!.friends!
                                        .contains(state.allUsers![index].id)
                                    ? const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      )
                                    : const Icon(Icons.add),
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
                        itemCount: state.allUsers!.length,
                      )
                    : const Center(
                        child: SpinKitCircle(
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      );
              }
              if (state is AuthError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context).add(GetAllUser());
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    const SizedBox(height: 15),
                    // Text(state.error!, textAlign: TextAlign.center),
                  ],
                );
              }
              return const Center(
                child: SpinKitCircle(
                  color: Colors.blue,
                  size: 40.0,
                ),
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
