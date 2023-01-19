import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/config/routes/route_navigation.dart';
import 'package:moment/screens/chat/components/all_users_list_body.dart';
import 'package:moment/screens/activity/activity_screen.dart';
import 'package:moment/screens/chat/components/chat_body.dart';
import 'package:moment/screens/profile/components/profile_visit_page.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_button_widget.dart';
import 'package:moment/widgets/custom_search_widget.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../bloc/activity_bloc/activity_bloc.dart';
import '../../bloc/auth_bloc/auth_bloc.dart';

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
          CustomIconButtonWidget(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 10.0),
            width: 30,
            onPressed: () async {
              if (StorageServices.authStorageValues.isNotEmpty == true) {
                RouteNavigation.navigate(
                  context,
                  BlocProvider.value(
                    value: BlocProvider.of<ActivityBloc>(context),
                    child: const ActivityScreen(),
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
          CustomIconButtonWidget(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 10.0),
            width: 30,
            onPressed: () async {
              var searchSelectedUser = await showSearch(
                context: context,
                delegate: DataSearch(
                  allUsersList: BlocProvider.of<AuthBloc>(context).allUsers.data ?? [],
                ),
              );
              if (searchSelectedUser != null) {
                // ignore: use_build_context_synchronously
                RouteNavigation.navigate(
                  context,
                  ProfileVisitPage(
                    isFromSearch: true,
                    userId: searchSelectedUser.id,
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.search,
              size: 28.0,
            ),
          )
        ],
      ),
      floatingActionButton: CustomIconButtonWidget(
        onPressed: () async {
          if (StorageServices.authStorageValues.isNotEmpty) {
            RouteNavigation.navigate(context, const AllUsersListBody());
          } else {
            CustomSnackbarWidget.showSnackbar(
              ctx: context,
              backgroundColor: Colors.red,
              milliDuration: 400,
              content: "Login First!",
            );
          }
        },
        isFloatingButton: true,
        floatingButtonContainerColor: Colors.blue,
        icon: const Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: const ChatBody(),
    );
  }
}
