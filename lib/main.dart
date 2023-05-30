import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moment/app/colors.dart';
import 'package:moment/blocObserver/bloc_observer.dart';
import 'package:moment/config/routes/route_generator.dart';
import 'package:moment/config/routes/routes_path.dart';
import 'package:moment/screens/main/main_screen.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'app/states/states.dart';
import 'bloc/activity_bloc/activity_bloc.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/home_bloc/home_bloc.dart';
import 'bloc/internet_bloc/internet_bloc.dart';
import 'bloc/posts_bloc/posts_bloc.dart';
import 'bloc/profile_posts_bloc/profile_posts_bloc.dart';
import 'bloc/profile_visit_posts_bloc/profile_visit_posts_bloc.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  StorageServices.initStorage();

  await Firebase.initializeApp();

  // socket = IO.io(
  //   baseUrl,
  //   IO.OptionBuilder()
  //       .setTransports(['websocket']) // for Flutter or Dart VM
  //       .disableAutoConnect() // disable auto-connection
  //       .setExtraHeaders({'foo': 'bar'}) // optional
  //       .build(),
  // );

  await OneSignal.shared.setAppId("c6055b6a-d6d7-4ecf-99f9-6d7e38e884ae");
  OneSignal.shared
      .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
    if (kDebugMode) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    }
  });

  Bloc.observer = MyBlocObserver();
  cameras = await availableCameras();
  // NativeNotify.initialize(831, 'hsgYDUjuCgmNl9GaYuCc8I', null, null);

  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) =>
    MyApp(), // Wrap your app
    // ),
  );
}

class MyApp extends StatelessWidget {
  static const String title = 'Moments';
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc()
            ..add(
              const HomeCurrentIndexChangeEvent(index: 0),
            ),
        ),
        BlocProvider<PostsBloc>(
          create: (context) => PostsBloc(),
        ),
        BlocProvider<ProfilePostsBloc>(
          create: (context) => ProfilePostsBloc(),
        ),
        BlocProvider<ProfileVisitPostsBloc>(
          create: (context) => ProfileVisitPostsBloc(),
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
          lazy: false,
          create: (context) => InternetBloc(),
        ),
      ],
      child: MaterialApp(
        // useInheritedMediaQuery: true,
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        title: title,
        navigatorKey: navigatorKey,
        // darkTheme: ThemeData.dark(),
        // themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            backgroundColor: createMaterialColor(MColors.primaryColor),
            errorColor: createMaterialColor(Colors.red),
            primarySwatch: createMaterialColor(MColors.primaryColor),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: MColors.primaryGrayColor90,
            titleTextStyle: TextStyle(
              fontFamily: GoogleFonts.cookie().fontFamily,
              fontSize: 35,
            ),
          ),

          // scaffoldBackgroundColor: MColors.primaryColor,
          // fontFamily: GoogleFonts.openSans(
          //   fontSize: 16.0,
          // ).fontFamily,
          fontFamily: "Inter",
          iconButtonTheme: const IconButtonThemeData(
            style: ButtonStyle(
              iconColor: MaterialStatePropertyAll(Colors.white),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          splashColor: MColors.primaryColor,
        ),
        initialRoute: RoutesPath.mainRoute,
        onGenerateRoute: RouteGenerator.generateRoute,
        home: const MainScreen(),
      ),
    );
  }
}
