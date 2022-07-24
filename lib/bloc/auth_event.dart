part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final Map<String, dynamic>? data;
  LoginEvent({
    this.data,
  });
}

class RegisterEvent extends AuthEvent {
  final Map<String, dynamic>? data;
  RegisterEvent({
    this.data,
  });
}

class UploadImageEvent extends AuthEvent {
  final File? image;
  final String id;
  UploadImageEvent({
    required this.image,
    required this.id,
  });
}

class LogoutEvent extends AuthEvent {
  final String id;
  final String oneSignalUserId;
  LogoutEvent({
    required this.oneSignalUserId,
    required this.id,
  });
}

class EditProfileEvent extends AuthEvent {
  final String id;
  final String? name;
  final String? about;
  EditProfileEvent({
    required this.id,
    this.name,
    this.about,
  });
}

class AddUserEvent extends AuthEvent {
  final String userId;
  final String? friend;
  final String creatorId;
  final String activityName;
  final String userImageUrl;

  AddUserEvent({
    required this.userId,
    this.friend,
    required this.creatorId,
    required this.activityName,
    required this.userImageUrl,
  });
}

class GetUserById extends AuthEvent {
  final String? id;
  GetUserById({
    required this.id,
  });
}

class GetOwnerById extends AuthEvent {
  final String? id;
  GetOwnerById({
    required this.id,
  });
}

class GetUserFriends extends AuthEvent {
  final String? id;
  GetUserFriends({
    required this.id,
  });
}

class GetAllUser extends AuthEvent {}

class GetUserFromStorage extends AuthEvent {}
