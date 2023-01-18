part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeCurrentIndexChangeEvent extends HomeEvent {
  final int index;
  const HomeCurrentIndexChangeEvent({
    required this.index,
  });
  @override
  List<Object> get props => [index];
}
