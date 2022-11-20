// ignore_for_file: depend_on_referenced_packages, unused_import, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moment/development/console.dart';
import 'package:moment/main.dart';
import 'package:moment/models/message_model/message_model.dart';
import 'package:moment/models/user_model/individual_user_model.dart';
import 'package:moment/models/user_model/users_model.dart';
import 'package:moment/repo/user_repo.dart';
import 'package:moment/screens/main/main_screen.dart';
import 'package:moment/utils/storage_services.dart';
import 'package:moment/widgets/custom_dialog_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _userRepo = UserRepo();
  IndividualUserModel userModel = IndividualUserModel();
  IndividualUserModel ownerUserModel = IndividualUserModel();
  UserModel allUsers = UserModel();
  UserModel userFriends = UserModel();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  File? userSelectedFile;
  bool isSignIn = true;
  bool showPassword = false;
  List<MessageData> messageData = <MessageData>[];

  void clearAuthValue({BuildContext? ctx}) {
    emailController.clear();
    passwordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    confirmPasswordController.clear();
    userSelectedFile = null;
  }

  void setUserSelectedFile({File? selectedFile}) {
    userSelectedFile = selectedFile;
  }

  AuthBloc() : super(AuthInitial()) {
    on<AuthInitialLoadedEvent>((event, emit) async {
      await _authLoaded(event, emit, ctx: event.context);
    });
    on<SendMsgDataEvent>((event, emit) async {
      await _sendMsgData(event, emit, ctx: event.context);
    });
    on<LoginEvent>((event, emit) async {
      await _login(event, emit, ctx: event.context);
    });
    on<RegisterEvent>((event, emit) async {
      await _register(event, emit, ctx: event.context);
    });
    on<LogoutEvent>((event, emit) async {
      await _logout(event, emit, ctx: event.context);
    });
    on<UploadImageEvent>((event, emit) async {
      await _uploadUserImage(event, emit, ctx: event.context);
    });
    on<UploadMsgImageEvent>((event, emit) async {
      await _uploadMsgImage(event, emit, ctx: event.context);
    });
    on<EditProfileEvent>((event, emit) async {
      await _editUserProfile(event, emit, ctx: event.context);
    });
    on<AddUserEvent>((event, emit) async {
      await _addUser(event, emit, ctx: event.context);
    });
    on<GetOwnerById>((event, emit) async {
      await _getOwnerById(event, emit, ctx: event.context);
    });
    on<GetUserById>((event, emit) async {
      await _getUserById(event, emit, ctx: event.context);
    });
    on<GetUserFriends>((event, emit) async {
      await _getUserFriends(event, emit, ctx: event.context);
    });
    on<GetAllUser>((event, emit) async {
      await _getAllUser(event, emit, ctx: event.context);
    });
  }

  _authLoaded(AuthInitialLoadedEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(AuthLoaded(
      ownerUser: IndividualUserModel(
        message: "Success",
        data: IndividualUserData(
          email: event.data["email"] ?? "",
          id: event.data["id"] ?? "",
          image: IndividualImageData(
            imageUrl: event.data["imageUrl"] ?? "",
          ),
          token: event.data["token"] ?? "",
          name: event.data["name"] ?? "",
          friends: event.data["friends"] != null ? event.data["friends"].split(",") : [],
        ),
      ),
    ));
  }

  clearMessageData() {
    messageData.clear();
  }

  clearUserDetails() {
    userModel = IndividualUserModel();
    ownerUserModel = IndividualUserModel();
  }

  _sendMsgData(SendMsgDataEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    messageData.add(event.msgData);
    emit(AuthLoaded(
      msgData: messageData,
      user: userModel,
      ownerUser: ownerUserModel,
      allUsers: allUsers,
      userFriends: userFriends,
    ));
  }

  Future _login(LoginEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(AuthLoading());
    CustomDialogs.showCustomFullLoadingDialog(ctx: ctx, title: "Logging In...");
    try {
      final IndividualUserModel user = await _userRepo.login(data: event.data ?? {}, ctx: ctx);
      if (user.message == "Success" && user.data != null) {
        ownerUserModel = user;
        await StorageServices.writeStorage(key: "imageUrl", value: user.data?.image?.imageUrl ?? "");
        await StorageServices.writeStorage(key: "email", value: user.data?.email);
        await StorageServices.writeStorage(key: "name", value: user.data?.name);
        await StorageServices.writeStorage(key: "id", value: user.data?.id);
        await StorageServices.writeStorage(key: "token", value: user.data?.token);
        await StorageServices.writeStorage(key: "about", value: user.data?.about);
        await StorageServices.writeStorage(key: "rememberMe", value: "true");
        user.data?.friends != [] && user.data?.friends?.isNotEmpty == true
            ? await StorageServices.writeStorage(key: "friends", value: user.data?.friends?.join(",").toString() ?? "")
            : null;
        StorageServices.setAuthStorageValues(await StorageServices.getStorage());
        emit(LoginSuccess());
        clearAuthValue();
        emit(AuthLoaded(
          ownerUser: user,
        ));
      }
      Navigator.pop(ctx);
    } catch (err) {
      consolelog("Error : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _register(RegisterEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(AuthLoading());
    CustomDialogs.showCustomFullLoadingDialog(ctx: ctx);
    try {
      final IndividualUserModel user = await _userRepo.register(data: event.data ?? {}, ctx: ctx);
      if (user.message == "Success" && user.data != null) {
        emit(RegisterSuccess(user: user));
      }
      Navigator.pop(ctx);
    } catch (err) {
      consolelog("Error : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _logout(LogoutEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(AuthLoading());
    CustomDialogs.showCustomFullLoadingDialog(ctx: ctx, title: "Logging Out...");
    try {
      await _userRepo.logout(
        ctx: ctx,
        id: event.id,
        oneSignalUserId: event.oneSignalUserId,
      );
      await StorageServices.deleteAllStorage();
      StorageServices.authStorageValues.clear();
      // OneSignal.shared.removeExternalUserId().then((results) {
      //   consolelog("Results: $results.toString()");
      // }).catchError((error) {
      //   consolelog("Error : $error.toString()");
      // });
      emit(LogoutSuccess());
      Navigator.pop(ctx);
    } catch (err) {
      // consolelog("Error : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _uploadUserImage(UploadImageEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(UploadImageLoading());
    try {
      final IndividualUserModel user = await _userRepo.uploadImage(event.image, event.id);
      if (user.message == "Success" && user.data != null) {
        ownerUserModel = user;
        clearAuthValue();
        emit(UploadImageSuccess());
        emit(AuthLoaded(
          ownerUser: ownerUserModel,
          allUsers: allUsers,
          userFriends: userFriends,
        ));
        await StorageServices.deleteSpecificStorage(key: "imageUrl");
        await StorageServices.writeStorage(key: "imageUrl", value: user.data?.image?.imageUrl);
        StorageServices.setAuthStorageValues(await StorageServices.getStorage());
      }
    } catch (err) {
      consolelog("err : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _uploadMsgImage(UploadMsgImageEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(UploadMsgImageLoading());
    try {
      final MessageModel msgData = await _userRepo.uploadMsgImage(event.image, event.id, event.text);
      if (msgData.message == "Success" && msgData.data != null) {
        emit(UploadMsgImageSuccess(msgData: msgData));
        Navigator.pop(event.context);
      }
    } catch (err) {
      consolelog("err : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _editUserProfile(event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    try {
      final user = await _userRepo.editUser(event.id, event.name, event.about);
      if (user != null) {
        if (user.errMessage != "") {
          emit(AuthError(error: user.errMessage!));
        } else {
          consolelog("user ---- ${user.name}");
          emit(EditProfileSuccess(user: user));
        }
      }
    } catch (err) {
      // ignore: avoid_log
      consolelog("err : $err");
      emit(AuthError(error: "Server has been down recently"));
    }
  }

  Future _addUser(AddUserEvent event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(AddUserLoading());
    try {
      final IndividualUserModel user = await _userRepo.addUser(
        userId: event.userId,
        friend: event.friend,
        activityName: event.activityName,
        activityUserId: event.creatorId,
        userImageUrl: event.userImageUrl,
      );
      if (user.message == "Success" && user.data != null) {
        ownerUserModel = user;
        await StorageServices.deleteSpecificStorage(key: "friends");
        await StorageServices.writeStorage(key: "friends", value: user.data?.friends?.join(",").toString() ?? "");
        StorageServices.setAuthStorageValues(await StorageServices.getStorage());
        emit(AddUserSuccess(user: user));
      }
    } catch (err) {
      consolelog("err : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _getOwnerById(GetOwnerById event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    // emit(AuthLoading());
    try {
      final IndividualUserModel user = await _userRepo.getUserById(id: event.id, ctx: ctx);
      if (user.message == "Success" && user.data != null) {
        ownerUserModel = user;
        emit(AuthLoaded(
          user: userModel,
          ownerUser: ownerUserModel,
          allUsers: allUsers,
          userFriends: userFriends,
        ));
      }
    } catch (err) {
      consolelog("_getOwnerById : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _getUserById(GetUserById event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    // emit(AuthLoading());
    try {
      final IndividualUserModel user = await _userRepo.getUserById(id: event.id, ctx: ctx);
      if (user.message == "Success" && user.data != null) {
        userModel = user;
        emit(AuthLoaded(
          user: userModel,
          ownerUser: ownerUserModel,
          allUsers: allUsers,
          userFriends: userFriends,
        ));
      }
    } catch (err) {
      consolelog("_getUserById : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _getUserFriends(GetUserFriends event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(GetUserFriendsLoading());
    try {
      final UserModel user = await _userRepo.getUserFriends(id: event.id, ctx: ctx);
      if (user.message == "Success" && user.data != null) {
        userFriends = user;
        emit(AuthLoaded(
          user: userModel,
          ownerUser: ownerUserModel,
          allUsers: allUsers,
          userFriends: userFriends,
        ));
      }
    } catch (err) {
      consolelog("_getUserFriendsError : $err");
      emit(AuthError(error: err.toString()));
    }
  }

  Future _getAllUser(GetAllUser event, Emitter<AuthState> emit, {required BuildContext ctx}) async {
    emit(GetAllUsersLoading());
    try {
      final UserModel allUser = await _userRepo.getAllUsers(ctx: ctx);
      if (allUser.message == "Success" && allUser.data != null) {
        allUsers = allUser;
        emit(AuthLoaded(
          user: userModel,
          ownerUser: ownerUserModel,
          userFriends: userFriends,
          allUsers: allUser,
        ));
      }
    } catch (err) {
      consolelog("_getAllUser : $err");
      emit(AuthError(error: err.toString()));
    }
  }
}
