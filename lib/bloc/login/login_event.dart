part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class CallLoginEvent extends LoginEvent {
  final Map<String, dynamic>? data;
  final BuildContext context;
  const CallLoginEvent({
    required this.context,
    this.data,
  });
}
