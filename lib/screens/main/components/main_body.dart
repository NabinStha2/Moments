// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/utils/dynamic_link.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_snackbar_widget.dart';
import 'package:moment/widgets/custom_text_widget.dart';

import '../../../bloc/activity_bloc/activity_bloc.dart';
import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/home_bloc/home_bloc.dart';
import '../../../bloc/internet_bloc/internet_bloc.dart';
import '../../../bloc/posts_bloc/posts_bloc.dart';
import '../../../bloc/profile_posts_bloc/profile_posts_bloc.dart';
import '../../../development/console.dart';

class MainBody extends StatefulWidget {
  const MainBody({super.key});

  @override
  State<MainBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<MainBody> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  int currentIndex = 0;
  var authBloc = AuthBloc();
  var homeBloc = HomeBloc();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      authBloc = BlocProvider.of<AuthBloc>(context);
      homeBloc = BlocProvider.of<HomeBloc>(context);
      FirebaseDynamicLinkService.startDynamicService(ctx: context);
      getStorageItem();
      if (StorageServices.authStorageValues.isNotEmpty == true) {
        authBloc.add(AuthInitialLoadedEvent(
          context: context,
          data: StorageServices.authStorageValues,
        ));
      }
      final internetBloc = BlocProvider.of<InternetBloc>(context);
      _connectivity.checkConnectivity().then((result) => internetBloc.add(GetInternetStatus(connectivityResult: result)));
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
        internetBloc.add(GetInternetStatus(connectivityResult: result));
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  getStorageItem() async {
    StorageServices.setAuthStorageValues(await StorageServices.getStorage());
    // consolelog(StorageServices.authStorageValues);
    consolelog("storage is not empty : ${StorageServices.authStorageValues.isNotEmpty}");
    if (StorageServices.authStorageValues.isNotEmpty == true && StorageServices.authStorageValues != {}) {
      BlocProvider.of<ProfilePostsBloc>(context).add(
        GetProfilePostsEvent(
          context: context,
          creator: StorageServices.authStorageValues["id"] ?? "",
        ),
      );
      BlocProvider.of<PostsBloc>(context).add(
        GetPostsEvent(
          context: context,
        ),
      );
      BlocProvider.of<ActivityBloc>(context).add(
        GetActivity(id: StorageServices.authStorageValues["id"] ?? ""),
      );
      BlocProvider.of<AuthBloc>(context).add(GetUserFriends(
        context: context,
        id: StorageServices.authStorageValues["id"],
      ));
      BlocProvider.of<AuthBloc>(context).add(
        GetAllUser(context: context),
      );
      BlocProvider.of<AuthBloc>(context).add(
        GetOwnerById(
          context: context,
          id: StorageServices.authStorageValues["id"],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var homeBloc = BlocProvider.of<HomeBloc>(context);
    return BlocConsumer<InternetBloc, InternetState>(
      listener: (context, state) {
        if (state is InternetDisconnected) {
          CustomSnackbarWidget.showSnackbar(
            ctx: context,
            content: "Disconnected to Internet",
            backgroundColor: Colors.redAccent,
            snackBarBehavior: SnackBarBehavior.fixed,
          );
        }
      },
      builder: (context, state) {
        if (state is InternetDisconnected) {
          return Center(
            child: PoppinsText(
              "It looks as though you're offline.",
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          );
        }
        return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
          if (state is HomeCurrentIndexChangedState) {
            return homeBloc.screens[state.index];
          }
          return homeBloc.screens[0];
        });
      },
    );
  }
}
