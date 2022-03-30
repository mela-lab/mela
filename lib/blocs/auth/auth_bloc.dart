import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mela/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  StreamSubscription? subscription;
  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is StartAppEvent) {
        emit(AuthLoading());
        try {
          subscription?.cancel();
          subscription = authService
              .isLogin()
              .listen((event) => add(UpdateAuthState(event)));
        } catch (ex) {
          emit(UnAuthenticated());
        }
      }

      if (event is UpdateAuthState) {
        if (event.user != null) {
          // print(event.user);
          emit(AuthSuccess(event.user!));
        } else {
          emit(UnAuthenticated());
        }
      }
      if (event is Login) {
        emit(AuthLoading());
        await authService.signInWithGoogle();

        add(StartAppEvent());
      }
      if (event is Logout) {
        emit(AuthLoading());
        await authService.logout();
        emit(UnAuthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}