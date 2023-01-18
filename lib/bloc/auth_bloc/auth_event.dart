part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final Map<String, dynamic>? data;
  final BuildContext context;
  LoginEvent({
    required this.context,
    this.data,
  });
}

class AuthInitialLoadedEvent extends AuthEvent {
  final Map<String, dynamic> data;
  final BuildContext context;
  AuthInitialLoadedEvent({
    required this.context,
    required this.data,
  });
}

class SendMsgDataEvent extends AuthEvent {
  final MessageData msgData;
  final BuildContext context;
  SendMsgDataEvent({
    required this.context,
    required this.msgData,
  });
}

class RegisterEvent extends AuthEvent {
  final Map<String, dynamic>? data;
  final BuildContext context;
  RegisterEvent({
    this.data,
    required this.context,
  });
}

class UploadImageEvent extends AuthEvent {
  final File? image;
  final BuildContext context;
  final String id;
  UploadImageEvent({
    required this.image,
    required this.context,
    required this.id,
  });
}

class UploadMsgImageEvent extends AuthEvent {
  final File? image;
  final BuildContext context;
  final String id;
  final String text;
  UploadMsgImageEvent({
    required this.image,
    required this.context,
    required this.id,
    required this.text,
  });
}

class LogoutEvent extends AuthEvent {
  final String id;
  final String oneSignalUserId;
  final BuildContext context;
  LogoutEvent({
    required this.id,
    required this.oneSignalUserId,
    required this.context,
  });
}

class EditProfileEvent extends AuthEvent {
  final String id;
  final String? name;
  final String? about;
  final BuildContext context;
  EditProfileEvent({
    required this.id,
    this.name,
    this.about,
    required this.context,
  });
}

class AddUserEvent extends AuthEvent {
  final String userId;
  final String? friend;
  final String creatorId;
  final String activityName;
  final String userImageUrl;
  final BuildContext context;

  AddUserEvent({
    required this.userId,
    this.friend,
    required this.creatorId,
    required this.activityName,
    required this.userImageUrl,
    required this.context,
  });
}

class GetUserById extends AuthEvent {
  final String? id;
  final BuildContext context;
  GetUserById({
    required this.context,
    required this.id,
  });
}

class GetOwnerById extends AuthEvent {
  final String? id;
  final BuildContext context;
  GetOwnerById({
    required this.context,
    required this.id,
  });
}

class GetUserFriends extends AuthEvent {
  final String? id;
  final BuildContext context;
  GetUserFriends({
    required this.context,
    required this.id,
  });
}

class GetAllUser extends AuthEvent {
  final BuildContext context;
  GetAllUser({
    required this.context,
  });
}

class GetUserFromStorage extends AuthEvent {}
