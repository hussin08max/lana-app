import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/auth_repository.dart';

enum AuthStatus { initial, loading, otpSent, success, error }

class AuthState {
  const AuthState({
    required this.status,
    this.errorMessage,
    this.otpRequested = false,
  });

  final AuthStatus status;
  final String? errorMessage;
  final bool otpRequested;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? otpRequested,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      otpRequested: otpRequested ?? this.otpRequested,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState(status: AuthStatus.initial);

  Future<void> sendOtp(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter your phone number',
        otpRequested: false,
      );
      return;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      otpRequested: false,
    );

    try {
      await ref.read(authRepositoryProvider).sendOtp(trimmed);
      state = AuthState(
        status: AuthStatus.otpSent,
        otpRequested: true,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _messageFromException(e),
        otpRequested: false,
      );
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    final p = phone.trim();
    final o = otp.trim();
    if (p.isEmpty || o.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Phone and OTP are required',
        otpRequested: true,
      );
      return;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      otpRequested: true,
    );

    try {
      final token = await ref.read(authRepositoryProvider).verifyOtp(p, o);
      await ApiClient.saveToken(token);
      state = AuthState(
        status: AuthStatus.success,
        otpRequested: true,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _messageFromException(e),
        otpRequested: true,
      );
    }
  }

  void acknowledgeError() {
    if (state.status == AuthStatus.error && state.otpRequested) {
      state = state.copyWith(
        status: AuthStatus.otpSent,
        clearErrorMessage: true,
      );
    } else if (state.status == AuthStatus.error) {
      state = const AuthState(status: AuthStatus.initial);
    }
  }

  static String _messageFromException(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final m = data['message'];
        if (m is String) return m;
        if (m is List && m.isNotEmpty) return m.first.toString();
      }
      return e.message ?? 'Network error';
    }
    return e.toString();
  }
}
