import 'package:flutter/material.dart';
import 'package:moment/screens/auth/auth_screen.dart';
import 'package:moment/utils/storage_services.dart';

import 'components/profile_body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (StorageServices.authStorageValues["rememberMe"] == null && StorageServices.authStorageValues["rememberMe"] == "false") {
      return const AuthScreen();
    } else {
      return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: const ProfileBody(),
      );
    }
  }
}
