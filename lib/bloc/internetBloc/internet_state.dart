part of 'internet_bloc.dart';

abstract class InternetState extends Equatable {
  const InternetState();

  @override
  List<Object> get props => [];
}

class InternetLoading extends InternetState {}

class InternetConnected extends InternetState {
  final ConnectivityResult connectivityResult;

  InternetConnected(this.connectivityResult);

  @override
  List<Object> get props => [connectivityResult];
}

class InternetDisconnected extends InternetState {
  @override
  List<Object> get props => [];
}
