import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/app/colors.dart';

import 'package:moment/screens/main/components/main_body.dart';
import 'package:moment/utils/double_tap_back.dart';

import '../../bloc/home_bloc/home_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
    return WillPopScope(
      onWillPop: () {
        return onWillPop(context);
      },
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: MColors.primaryGrayColor80,
          color: MColors.primaryGrayColor90,
          // key: homeBloc.bottomNavigationKey,
          buttonBackgroundColor: MColors.primaryGrayColor90,
          height: 60.0,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          index: 0,
          letIndexChange: (index) => true,
          items: const <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.add_circle, size: 30),
            Icon(Icons.chat_rounded, size: 30),
            Icon(Icons.account_circle, size: 30),
          ],
          onTap: (index) {
            homeBloc.add(HomeCurrentIndexChangeEvent(index: index));
          },
        ),
        body: const MainBody(),
      ),
    );
  }
}
