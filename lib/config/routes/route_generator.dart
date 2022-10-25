import 'package:flutter/material.dart';
import 'package:moment/config/routes/routes_path.dart';
import 'package:moment/screens/activity/activity_screen.dart';
import 'package:moment/screens/chat/chat_screen.dart';
import 'package:moment/screens/main/main_screen.dart';
import 'package:moment/screens/posts/post_add/post_add_screen.dart';
import 'package:moment/screens/profile/profile_screen.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RoutesPath.mainRoute:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case RoutesPath.homeRoute:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case RoutesPath.postAddRoute:
        return MaterialPageRoute(builder: (_) => const PostAddScreen());
      case RoutesPath.chatRoute:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case RoutesPath.activityRoute:
        return MaterialPageRoute(builder: (_) => const ActivityScreen());
      case RoutesPath.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      // case RoutesPath.chattingRoute:
      //   return MaterialPageRoute(builder: (_) => ChattingPage());
    }
    return null;
  }
}
