import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/bloc/activity_bloc.dart';
import 'package:moment/bloc/auth_bloc.dart';
import 'package:moment/bloc/internet_bloc.dart';
import 'package:moment/bloc/posts_bloc.dart';
import 'package:moment/blocObserver/bloc_observer.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_native_splash/flutter_native_splash.dart';

const appId = "ea8b2f5a8acd452e88b5028f95ab55dd";
const String baseUrl = "momentsapps.herokuapp.com";
const String socketUrl = "https://momentsapps.herokuapp.com";
// const String baseUrl = "192.168.1.78:3000";
// const String socketUrl = "http://192.168.1.78:3000";
IO.Socket? socket;

final storage = new FlutterSecureStorage();
final accountNameController =
    TextEditingController(text: 'flutter_secure_storage_service');
// OSDeviceState? deviceState;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
List<CameraDescription>? cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  socket = IO.io(
    socketUrl,
    IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .disableAutoConnect() // disable auto-connection
        .setExtraHeaders({'foo': 'bar'}) // optional
        .build(),
  );

  // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  await OneSignal.shared.setAppId("c6055b6a-d6d7-4ecf-99f9-6d7e38e884ae");
  OneSignal.shared
      .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
    print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
  });
  // deviceState = await OneSignal.shared.getDeviceState();
  // inspect(deviceState);

  Bloc.observer = MyBlocObserver();
  cameras = await availableCameras();

  // NativeNotify.initialize(831, 'hsgYDUjuCgmNl9GaYuCc8I', null, null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Moments';

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostsBloc>(
          lazy: false,
          create: (context) => PostsBloc()..add(GetPostsEvent()),
        ),
        BlocProvider<ActivityBloc>(
          // lazy: false,
          create: (context) => ActivityBloc(),
        ),
        BlocProvider<AuthBloc>(
          // lazy: false,
          create: (context) => AuthBloc(),
        ),
        BlocProvider<InternetBloc>(
          // lazy: false,
          create: (context) => InternetBloc(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: title,
            navigatorKey: navigatorKey,
            // darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                  backgroundColor: const Color.fromARGB(255, 26, 168, 228),
                  titleTextStyle: TextStyle(
                    fontFamily: GoogleFonts.cookie().fontFamily,
                    fontSize: 35,
                  )),
              fontFamily: GoogleFonts.openSans(
                fontSize: 16.0,
              ).fontFamily,
            ),
            home: child,
          );
        },
        child: const HomeScreen(),
      ),
    );
  }
}
