import 'package:bloc/bloc.dart';

import '../development/console.dart';

class MyBlocObserver extends BlocObserver {
  // @override
  // void onCreate(BlocBase bloc) {
  //   super.onCreate(bloc);
  //   consolelog('onCreate -- ${bloc.runtimeType}');
  // }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    consolelog('onEvent -- ${bloc.runtimeType}, $event');
  }

  // @override
  // void onChange(BlocBase bloc, Change change) {
  //   super.onChange(bloc, change);
  //   consolelog('onChange -- ${bloc.runtimeType}, $change');
  // }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    consolelog('onTransition -- ${bloc.runtimeType}, $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    consolelog('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  // @override
  // void onClose(BlocBase bloc) {
  //   super.onClose(bloc);
  //   consolelog('onClose -- ${bloc.runtimeType}');
  // }
}
