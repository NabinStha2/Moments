// ignore_for_file: avoid_print

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:equatable/equatable.dart';

part 'internet_event.dart';
part 'internet_state.dart';

class InternetBloc extends Bloc<InternetEvent, InternetState> {
  InternetBloc() : super(InternetLoading()) {
    on<GetInternetStatus>((event, emit) async {
      await _checkInternet(event, emit);
    });
  }
  // final pen = AnsiPen()..yellow(bold: true);

  _checkInternet(event, Emitter<InternetState> emit) async {
    emit(InternetLoading());

    try {
      // print(pen(event.connectivityResult));
      switch (event.connectivityResult) {
        case ConnectivityResult.wifi:
          emit(InternetConnected(event.connectivityResult));
          break;
        case ConnectivityResult.none:
          emit(InternetDisconnected());
          break;
        default:
          break;
      }
    } catch (e) {
      print("Bloc Error");
    }
  }
}
