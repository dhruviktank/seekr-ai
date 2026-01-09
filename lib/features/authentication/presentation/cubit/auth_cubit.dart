import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../data/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final user = authService.currentUser;
      debugPrint("Current User: $user");

      if (user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      debugPrint("Error checking auth status: $e");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await authService.login(email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    emit(AuthLoading());
    try {
      await authService.register(name, email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await authService.logout();
    emit(AuthInitial());
  }

  Future<void> sendPasswordReset(String email) async {
    if (email.isEmpty) {
      emit(AuthError("Please enter your email to recover your key."));
      return;
    }

    emit(AuthLoading());

    try {
      await authService.sendPasswordReset(email);

      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError("The void rejected your request: ${e.toString()}"));
    }
  }
}
