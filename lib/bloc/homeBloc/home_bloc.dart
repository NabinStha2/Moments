import 'package:bloc/bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:moment/screens/auth/auth_screen.dart';
import 'package:moment/screens/chat/chat_screen.dart';
import 'package:moment/screens/home/home_screen.dart';
import 'package:moment/screens/posts/post_add/post_add_screen.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  List screens = [
    const NewsFeedScreen(),
    const PostAddScreen(),
    const ChatScreen(),
    const AuthScreen(),
  ];
  final GlobalKey<CurvedNavigationBarState> bottomNavigationKey = GlobalKey<CurvedNavigationBarState>();

  HomeBloc() : super(HomeCurrentIndexChangeLoadingState()) {
    on<HomeCurrentIndexChangeEvent>((event, emit) async {
      emit(HomeCurrentIndexChangeLoadingState());
      emit(HomeCurrentIndexChangedState(index: event.index));
    });
  }
}
