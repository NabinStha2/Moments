import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/user_model/individual_user_model.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    //  on<LoginEvent>((event, emit) async {
    //     await _login(event, emit, ctx: event.context);
    //   });
  }

  //  Future _login(LoginEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
  //   emit(state.());
  //   CustomDialogs.showCustomFullLoadingDialog(ctx: ctx, title: "Logging In...");
  //   try {
  //     final IndividualUserModel user = await _userRepo.login(data: event.data ?? {}, ctx: ctx);
  //     if (user.message == "Success" && user.data != null) {
  //       ownerUserModel = user;
  //       await StorageServices.writeStorage(key: "imageUrl", value: user.data?.image?.imageUrl ?? "");
  //       await StorageServices.writeStorage(key: "email", value: user.data?.email);
  //       await StorageServices.writeStorage(key: "name", value: user.data?.name);
  //       await StorageServices.writeStorage(key: "id", value: user.data?.id);
  //       await StorageServices.writeStorage(key: "token", value: user.data?.token);
  //       await StorageServices.writeStorage(key: "about", value: user.data?.about);
  //       await StorageServices.writeStorage(key: "rememberMe", value: "true");
  //       user.data?.friends != [] && user.data?.friends?.isNotEmpty == true
  //           ? await StorageServices.writeStorage(key: "friends", value: user.data?.friends?.join(",").toString() ?? "")
  //           : null;
  //       StorageServices.setAuthStorageValues(await StorageServices.getStorage());
  //       emit(LoginSuccess());
  //       clearAuthValue();
  //       emit(AuthLoaded(
  //         ownerUser: user,
  //       ));
  //     }
  //     Navigator.pop(ctx);
  //   } catch (err) {
  //     consolelog("Error : $err");
  //     emit(AuthError(error: err.toString()));
  //   }
  // }
}
