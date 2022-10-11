part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeCurrentIndexChangeLoadingState extends HomeState {}

class HomeCurrentIndexChangedState extends HomeState {
  final int index;
  const HomeCurrentIndexChangedState({
    this.index = 0,
  });
  @override
  List<Object> get props => [index];
}
