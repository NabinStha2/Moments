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
  final UserModel? user;
  final UserModel? ownerUser;
  List<ChatModel>? userFriends = [];
  List<ChatModel>? allUsers = [];
  AuthLoaded({
    this.user,
    this.ownerUser,
    this.userFriends,
    this.allUsers,
  });
}

class RegisterSuccess extends AuthState {
  final UserModel? user;
  RegisterSuccess({
    this.user,
  });
}

class LogoutSuccess extends AuthState {}

class UploadImageLoading extends AuthState {}

class UploadImageSuccess extends AuthState {}

class EditProfileLoading extends AuthState {}

class EditProfileSuccess extends AuthState {
  final UserModel? user;
  EditProfileSuccess({
    this.user,
  });
}

class AddUserSuccess extends AuthState {
  final UserModel? user;
  AddUserSuccess({
    this.user,
  });

  @override
  String toString() => 'AddUserSuccess(user: ${user!.email})';
}

class GetUserByIdSuccess extends AuthState {
  final UserModel? user;
  GetUserByIdSuccess({
    this.user,
  });
}

class GetUserByFriends extends AuthState {}

class ActivityLoaded extends AuthState {}
