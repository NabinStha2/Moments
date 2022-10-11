// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moment/bloc/authBloc/auth_bloc.dart';
import 'package:moment/screens/chat/cmponents/chat_body.dart';
import 'package:moment/widgets/custom_search_widget.dart';
import 'package:moment/utils/storage_services.dart';

import 'package:moment/bloc/activityBloc/activity_bloc.dart';
import 'package:moment/screens/activity/activity_screen.dart';
import 'package:moment/screens/profile/components/profile_page.dart';
import 'package:moment/pages/users_page.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarCookieText(
          "Message",
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 10.0),
            iconSize: 24.0,
            onPressed: () async {
              if (StorageServices.authStorageValues.isNotEmpty == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: BlocProvider.of<ActivityBloc>(context),
                      child: const ActivityScreen(),
                    ),
                  ),
                );
              } else {
                CustomSnackbarWidget.showSnackbar(
                  ctx: context,
                  backgroundColor: Colors.red,
                  secDuration: 2,
                  content: "First Sign In!",
                );
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
              var searchSelectedUser = await showSearch(
                context: context,
                delegate: DataSearch(
                  allUsersList: BlocProvider.of<AuthBloc>(context).allUsers.data ?? [],
                ),
              );
              if (searchSelectedUser != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileVisitPage(
                        isFromSearch: true,
                        userId: searchSelectedUser.id,
                      ),
                    ));
              }
            },
            icon: const Icon(
              Icons.search,
              size: 28.0,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (StorageServices.authStorageValues.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UsersPage(),
              ),
            );
          } else {
            CustomSnackbarWidget.showSnackbar(
              ctx: context,
              backgroundColor: Colors.red,
              milliDuration: 400,
              content: "Login First!",
            );
          }
        },
        clipBehavior: Clip.antiAlias,
        child: const Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: const ChatBody(),
    );
  }
}

// class UserDataSearch extends SearchDelegate {
//   final List<UserData> allUsersList;

//   UserDataSearch({required this.allUsersList});

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () {
//             query = "";
//           })
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//         icon: AnimatedIcon(
//           icon: AnimatedIcons.menu_arrow,
//           progress: transitionAnimation,
//         ),
//         onPressed: () {
//           close(context, null);
//         });
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     final userInfo = query.isNotEmpty
//         ? allUsersList.where((element) {
//             return element.name?.toLowerCase().startsWith(query.toLowerCase()) == true ||
//                 element.email?.toLowerCase().contains(query.toLowerCase()) == true;
//           }).toList()
//         : null;
//     return userInfo != null
//         ? ListView.separated(
//             clipBehavior: Clip.antiAlias,
//             separatorBuilder: (context, index) {
//               return const Divider(
//                 color: Colors.grey,
//                 thickness: 0.5,
//                 indent: 15.0,
//                 endIndent: 15.0,
//               );
//             },
//             physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//             itemBuilder: (context, index) => ListTile(
//               leading: const Icon(Icons.feed),
//               title: Text(userInfo[index].name ?? ""),
//               subtitle: Text(userInfo[index].email ?? ""),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.0),
//               ),
//               onTap: () {
//                 close(context, userInfo[index]);
//               },
//             ),
//             itemCount: userInfo.length,
//           )
//         : Container();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final userInfo = query.isNotEmpty
//         ? allUsersList.where((element) {
//             return element.name?.toLowerCase().startsWith(query.toLowerCase()) == true ||
//                 element.email?.toLowerCase().contains(query.toLowerCase()) == true;
//           }).toList()
//         : null;

//     return userInfo != null
//         ? ListView.separated(
//             clipBehavior: Clip.antiAlias,
//             separatorBuilder: (context, index) {
//               return const Divider(
//                 color: Colors.grey,
//                 thickness: 0.5,
//                 indent: 15.0,
//                 endIndent: 15.0,
//               );
//             },
//             physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//             itemBuilder: (context, index) => ListTile(
//               leading: const Icon(Icons.feed),
//               title: Text(userInfo[index].name ?? ""),
//               subtitle: Text(userInfo[index].email ?? ""),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.0),
//               ),
//               onTap: () {
//                 close(context, userInfo[index]);
//               },
//             ),
//             itemCount: userInfo.length,
//           )
//         : Container();
//   }
// }
