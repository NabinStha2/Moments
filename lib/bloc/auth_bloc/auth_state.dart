part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String error;
  AuthError({
    required this.error,
  });
}

class LoginSuccess extends AuthState {}

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

class RegisterSuccess extends AuthState {
  final IndividualUserModel? user;
  RegisterSuccess({
    this.user,
  });
}

class LogoutSuccess extends AuthState {}

class UploadImageLoading extends AuthState {}

class UploadImageSuccess extends AuthState {}

class UploadMsgImageLoading extends AuthState {}

class UploadMsgImageSuccess extends AuthState {
  final MessageModel msgData;
  UploadMsgImageSuccess({
    required this.msgData,
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

class AddUserLoading extends AuthState {}

class AddUserSuccess extends AuthState {
  final IndividualUserModel? user;
  AddUserSuccess({
    this.user,
  });
}

class GetUserByIdSuccess extends AuthState {
  final UserModel? user;
  GetUserByIdSuccess({
    this.user,
  });
}

class GetUserFriendsLoading extends AuthState {}

class GetAllUsersLoading extends AuthState {}

class GetAllUsersFailure extends AuthState {
  final String error;
  GetAllUsersFailure({
    required this.error,
  });
}
