// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/development/console.dart';
import 'package:moment/screens/auth/components/auth_body.dart';
import 'package:moment/screens/profile/profile_screen.dart';
import 'package:moment/services/load_all_data.dart';
import 'package:moment/utils/storage_services.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../widgets/custom_snackbar_widget.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    consolelog(StorageServices.authStorageValues["rememberMe"]);
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          loadAllData(context: context);
          CustomSnackbarWidget.showSnackbar(
            ctx: context,
            content: "Login Successfully.",
            secDuration: 1,
            snackBarBehavior: SnackBarBehavior.floating,
          );
        }
        if (state is RegisterSuccess) {
          CustomSnackbarWidget.showSnackbar(
            ctx: context,
            backgroundColor: Colors.green,
            content: "Register Successfully.",
            secDuration: 1,
            snackBarBehavior: SnackBarBehavior.floating,
          );
        }
        if (state is LogoutSuccess) {
          CustomSnackbarWidget.showSnackbar(
            ctx: context,
            backgroundColor: Colors.green,
            content: "Logout Successfully.",
            secDuration: 1,
            snackBarBehavior: SnackBarBehavior.floating,
          );
        }
        if (state is LoginFailure) {
          CustomSnackbarWidget.showSnackbar(
              ctx: context,
              backgroundColor: Colors.red,
              content: state.error,
              secDuration: 2);
        }
        if (state is RegisterFailure) {
          CustomSnackbarWidget.showSnackbar(
              ctx: context,
              backgroundColor: Colors.red,
              content: state.error,
              secDuration: 2);
        }
      },
      builder: (context, state) {
        if (state is LogoutSuccess) {
          return AuthBody(state: state);
        }
        if (state is RegisterSuccess) {
          return AuthBody(state: state);
        }
        if (state is AuthLoaded) {
          return const ProfileScreen();
        }
        return StorageServices.authStorageValues.isNotEmpty == true &&
                StorageServices.authStorageValues["rememberMe"] == "true"
            ? const ProfileScreen()
            : AuthBody(state: state);
      },
    );
  }
}
