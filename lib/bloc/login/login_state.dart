// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'login_bloc.dart';

enum LoginStatus { loading, success, failure }

class LoginState extends Equatable {
  final String? message;
  final LoginStatus status;
  final IndividualUserModel? user;
  const LoginState({
    this.message,
    this.status = LoginStatus.loading,
    this.user,
  });

  @override
  List<Object?> get props => [message, status, user];

  LoginState copyWith({
    String? message,
    LoginStatus? status,
    IndividualUserModel? user,
  }) {
    return LoginState(
      message: message ?? this.message,
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}
