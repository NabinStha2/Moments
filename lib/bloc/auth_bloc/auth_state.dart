part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoaded extends AuthState {
  IndividualUserModel? user = IndividualUserModel();
  IndividualUserModel? ownerUser = IndividualUserModel();
  UserModel? userFriends = UserModel();
  UserModel? allUsers = UserModel();
  final List<MessageData>? msgData;
  AuthLoaded({
    this.user,
    this.ownerUser,
    this.userFriends,
    this.allUsers,
    this.msgData,
  });
}

class AuthError extends AuthState {
  final String error;
  AuthError({
    required this.error,
  });
}

class LoginSuccess extends AuthState {}

class LoginFailure extends AuthState {
  final String error;
  LoginFailure({
    required this.error,
  });
}

class RegisterSuccess extends AuthState {
  final IndividualUserModel? user;
  RegisterSuccess({
    this.user,
  });
}

class RegisterFailure extends AuthState {
  final String error;
  RegisterFailure({
    required this.error,
  });
}

class LogoutSuccess extends AuthState {}

class UploadImageLoading extends AuthState {}

class UploadImageSuccess extends AuthState {}

class UploadImageFailure extends AuthState {
  final String error;
  UploadImageFailure({
    required this.error,
  });
}

class UploadMsgImageLoading extends AuthState {}

class UploadMsgImageSuccess extends AuthState {
  final MessageModel msgData;
  UploadMsgImageSuccess({
    required this.msgData,
  });
}

class UploadMsgImageFailure extends AuthState {
  final String error;
  UploadMsgImageFailure({
    required this.error,
  });
}

// class SendMsgDataState extends AuthState {
//   final List<MessageData> msgData;
//   SendMsgDataState({
//     required this.msgData,
//   });
// }

class EditProfileLoading extends AuthState {}

class EditProfileSuccess extends AuthState {
  final UserModel? user;
  EditProfileSuccess({
    this.user,
  });
}

class EditProfileFailure extends AuthState {
  final String error;
  EditProfileFailure({
    required this.error,
  });
}

class AddUserLoading extends AuthState {}

class AddUserSuccess extends AuthState {
  final IndividualUserModel? user;
  AddUserSuccess({
    this.user,
  });
}

class AddUserFailure extends AuthState {
  final String error;
  AddUserFailure({
    required this.error,
  });
}

class GetUserByIdSuccess extends AuthState {
  final UserModel? user;
  GetUserByIdSuccess({
    this.user,
  });
}

class GetUserByIdFailure extends AuthState {
  final String error;
  GetUserByIdFailure({
    required this.error,
  });
}

class GetUserFriendsLoading extends AuthState {}

class GetUserFriendsFailure extends AuthState {
  final String error;
  GetUserFriendsFailure({
    required this.error,
  });
}

class GetAllUsersLoading extends AuthState {}

class GetAllUsersFailure extends AuthState {
  final String error;
  GetAllUsersFailure({
    required this.error,
  });
}
