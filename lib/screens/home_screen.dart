// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/bloc/internet_bloc.dart';
import 'package:moment/main.dart';
import 'package:moment/models/post_model.dart';
import 'package:moment/pages/chat_page.dart';
import 'package:moment/screens/add_screen.dart';
import 'package:moment/screens/auth_screen.dart';
import 'package:moment/screens/news_feed_screen.dart';
import 'package:moment/services/dynamic_link.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;

final List<PostModel> posts = [];
Map<String, String>? authStorageValues;

getStorage() async {
  return await storage.readAll(
    aOptions: const AndroidOptions(),
    iOptions: IOSOptions(
      accountName: accountNameController.text.isEmpty
          ? null
          : accountNameController.text,
    ),
  );
  // print(authStorageValues);
}

notifiedOnline() async {
  authStorageValues = await getStorage();
  var deviceState = await handleGetDeviceState();

  if (deviceState != null && deviceState.userId != null) {
    print("Add: ${deviceState.userId}");
    // final uri = Uri.https(baseUrl, "/api/SendNotification");
    final uri = Uri.http(baseUrl, "/api/SendNotification");
    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json ; charset=utf-8",
      },
      body: json.encode(<String, dynamic>{
        "headings": "Moments",
        "msg": "${authStorageValues!["name"]} is online.",
      }),
    );
    inspect(response);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  int currentIndex = 0;

  final List _screens = [
    const NewsFeedScreen(),
    const AddScreen(),
    const ChatPage(),
    const AuthScreen(),
  ];

  @override
  void initState() {
    super.initState();
    getStorageItem();

    OneSignal.shared.setNotificationOpenedHandler((result) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });

    final internetBloc = BlocProvider.of<InternetBloc>(context);

    _connectivity.checkConnectivity().then((result) =>
        internetBloc.add(GetInternetStatus(connectivityResult: result)));

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      internetBloc.add(GetInternetStatus(connectivityResult: result));
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  getStorageItem() async {
    await FirebaseDynamicLinkService.initDynamicLink(context);
    authStorageValues = await getStorage();
    log("Home: $authStorageValues");

    if (authStorageValues != null && authStorageValues!.isNotEmpty) {
      BlocProvider.of<AuthBloc>(context)
          .add(LoginEvent(data: authStorageValues));
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(currentIndex);
    // print(postData);
    // print(authStorageValues);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.black26,
        key: _bottomNavigationKey,
        buttonBackgroundColor: Colors.white,
        height: 60.0,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        index: 0,
        letIndexChange: (index) => true,
        items: <Widget>[
          const Icon(Icons.home, size: 30),
          const Icon(Icons.add_circle, size: 30),
          const Icon(Icons.chat_rounded, size: 30),
          const Icon(Icons.account_circle, size: 30),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: BlocConsumer<InternetBloc, InternetState>(
        listener: (context, state) {
          if (state is InternetDisconnected) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text("Disconnected to Internet"),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ));
          }
        },
        builder: (context, state) {
          if (state is InternetDisconnected) {
            return Center(
              child: Text(
                "It looks as though you're offline.",
                style: TextStyle(
                  fontFamily: GoogleFonts.nunitoSans().fontFamily,
                ),
              ),
            );
          }
          return _screens[currentIndex];
        },
      ),
    );
  }
}
