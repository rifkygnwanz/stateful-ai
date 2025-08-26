import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent {}

class AutoLoginEvent extends AuthEvent {}

class LoginWithGoogleEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<AutoLoginEvent>((event, emit) async {
      emit(AuthLoading());
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<LoginWithGoogleEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _repository.signInWithGoogle();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await _repository.signOut();
      emit(AuthUnauthenticated());
    });
  }
}
