// ignore_for_file: depend_on_referenced_packages, unused_import

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:moment/main.dart';
import 'package:moment/models/chat_model.dart';
import 'package:moment/models/user_model.dart';
import 'package:moment/repo/user_repo.dart';
import 'package:moment/screens/home_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial());

  final _userRepo = UserRepo();
  UserModel? userModel;
  UserModel? ownerUserModel;
  List<ChatModel>? allUsers = [];
  List<ChatModel>? userFriends;

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is LoginEvent) {
      yield AuthLoading();
      try {
        log("Auth Event Data: ${event.data}");
        final user = await _userRepo.login(event.data);

        if (user != null) {
          if (user.errMessage != "") {
            yield AuthError(error: user.errMessage!);
          } else {
            log("LoginSuccess: $user");
            ownerUserModel = user;
            await storage.write(
              key: "email",
              value: user.email,
              aOptions: const AndroidOptions(),
              iOptions: IOSOptions(
                accountName: accountNameController.text.isEmpty
                    ? null
                    : accountNameController.text,
              ),
            );
            await storage.write(
              key: "name",
              value: user.name,
              aOptions: const AndroidOptions(),
              iOptions: IOSOptions(
                accountName: accountNameController.text.isEmpty
                    ? null
                    : accountNameController.text,
              ),
            );
            await storage.write(
              key: "id",
              value: user.id,
              aOptions: const AndroidOptions(),
              iOptions: IOSOptions(
                accountName: accountNameController.text.isEmpty
                    ? null
                    : accountNameController.text,
              ),
            );
            await storage.write(
              key: "token",
              value: user.userToken,
              aOptions: const AndroidOptions(),
              iOptions: IOSOptions(
                accountName: accountNameController.text.isEmpty
                    ? null
                    : accountNameController.text,
              ),
            );
            await storage.write(
              key: "about",
              value: user.about,
              aOptions: const AndroidOptions(),
              iOptions: IOSOptions(
                accountName: accountNameController.text.isEmpty
                    ? null
                    : accountNameController.text,
              ),
            );
            await storage.write(
              key: "imageUrl",
              value: user.imageUrl,
              aOptions: const AndroidOptions(),
              iOptions: IOSOptions(
                accountName: accountNameController.text.isEmpty
                    ? null
                    : accountNameController.text,
              ),
            );
            yield LoginSuccess();
            // notifiedOnline();
            yield AuthLoaded(
              ownerUser: user,
            );
          }
        }
      } catch (err) {
        log("Error : $err");
        yield AuthError(error: "Server has been down recently");
      }
    } else if (event is RegisterEvent) {
      yield AuthLoading();
      try {
        // log(event.data);
        final user = await _userRepo.register(event.data);

        if (user?.errMessage != "") {
          yield AuthError(error: user!.errMessage!);
        } else {
          yield RegisterSuccess(user: user);
        }
      } catch (err) {
        log("Error : $err");
        yield AuthError(error: "Server has been down recently");
      }
    } else if (event is LogoutEvent) {
      yield AuthLoading();
      try {
        final user = await _userRepo.logout(
          id: event.id,
          oneSignalUserId: event.oneSignalUserId,
        );

        OneSignal.shared.removeExternalUserId().then((results) {
          log("Results: $results.toString()");
        }).catchError((error) {
          log("Error : $error.toString()");
        });
        yield LogoutSuccess();
      } catch (err) {
        log("Error : $err");
        yield AuthError(error: "Server has been down recently");
      }
    } else if (event is UploadImageEvent) {
      // yield UploadImageLoading();
      try {
        // inspect(event);
        final user = await _userRepo.uploadImage(event.image, event.id);
        log("user ---- ${user?.imageUrl}");
        ownerUserModel = user;
        yield UploadImageSuccess();
        yield AuthLoaded(
          ownerUser: user,
          allUsers: allUsers,
          userFriends: userFriends,
        );
      } catch (err) {
        log("err : $err");
        // yield AuthError(error: "Server has been down recently");
      }
    } else if (event is EditProfileEvent) {
      // yield EditProfileLoading();
      try {
        final user =
            await _userRepo.editUser(event.id, event.name, event.about);
        if (user != null) {
          if (user.errMessage != "") {
            yield AuthError(error: user.errMessage!);
          } else {
            log("user ---- ${user.name}");
            yield EditProfileSuccess(user: user);
          }
        }
      } catch (err) {
        // ignore: avoid_log
        log("err : $err");
        yield AuthError(error: "Server has been down recently");
      }
    } else if (event is AddUserEvent) {
      // yield AuthLoading();
      try {
        final user = await _userRepo.addUser(
          userId: event.userId,
          friend: event.friend,
          activityName: event.activityName,
          activityUserId: event.creatorId,
          userImageUrl: event.userImageUrl,
        );
        if (user != null) {
          if (user.errMessage != "") {
            yield AuthError(error: user.errMessage!);
          } else {
            ownerUserModel = user;
            log("user ---- ${user.friends}");
            yield AddUserSuccess(user: user);
            yield AuthLoaded(
              user: userModel,
              ownerUser: user,
              allUsers: allUsers,
              userFriends: userFriends,
            );
          }
        }
      } catch (err) {
        // ignore: avoid_log
        log("err : $err");
        yield AuthError(error: "Server has been down recently");
      }
    } else if (event is GetUserById) {
      yield AuthLoading();
      try {
        final user = await _userRepo.getUserById(event.id);
        if (user != null) {
          if (user.errMessage != "") {
            yield AuthError(error: user.errMessage!);
          } else {
            userModel = user;
            log("user ---- ${user.friends}");
            yield GetUserByIdSuccess(user: user);
            yield AuthLoaded(
              user: user,
              ownerUser: ownerUserModel,
              allUsers: allUsers,
              userFriends: userFriends,
            );
          }
        }
      } catch (err) {
        // ignore: avoid_log
        log("err : $err");
        yield AuthError(error: "Server has been down recently");
      }
    } else if (event is GetOwnerById) {
      // yield AuthLoading();
      try {
        final user = await _userRepo.getUserById(event.id);
        if (user != null) {
          if (user.errMessage != "") {
            yield AuthError(error: user.errMessage!);
          } else {
            ownerUserModel = user;
            log("owneruser ---- ${user.friends}");
            yield AuthLoaded(
              user: userModel,
              ownerUser: user,
              allUsers: allUsers,
              userFriends: userFriends,
            );
          }
        }
      } catch (err) {
        // ignore: avoid_log
        log("err : $err");
        yield AuthError(error: "Server has been down recently");
      }
    } else if (event is GetUserFriends) {
      yield AuthLoading();
      try {
        final userFriend = await _userRepo.getUserFriends(event.id);
        // log("$userFriend");
        if (userFriend != null) {
          userFriends = userFriend;
          yield GetUserByFriends();
          yield AuthLoaded(
            user: userModel,
            ownerUser: ownerUserModel,
            userFriends: userFriend,
            allUsers: allUsers,
          );
        }
      } catch (err) {
        // ignore: avoid_log
        log("err : $err");
        yield AuthError(error: "Server has been down recently");
      }
    } else if (event is GetAllUser) {
      // yield AuthLoading();
      try {
        final allUser = await _userRepo.getAllUsers();
        if (allUser != null) {
          allUsers = allUser;
          // log("user ---- ${allUser[0].email}");
          yield AuthLoaded(
            user: userModel,
            ownerUser: ownerUserModel,
            userFriends: userFriends,
            allUsers: allUser,
          );
        }
      } catch (err) {
        // ignore: avoid_log
        log("err : $err");
        yield AuthError(error: "Server has been down recently");
      }
    }
  }
}
