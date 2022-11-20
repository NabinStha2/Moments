import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/activity_bloc/activity_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/internet_bloc/internet_bloc.dart';
import '../bloc/posts_bloc/posts_bloc.dart';

List blocProvider = [
  BlocProvider<PostsBloc>(
    lazy: false,
    create: (context) => PostsBloc()
      ..add(GetPostsEvent(
        context: context,
      )),
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
];
