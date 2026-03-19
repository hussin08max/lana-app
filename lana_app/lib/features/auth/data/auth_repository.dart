import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<void> sendOtp(String phone) async {
    await _dio.post<Map<String, dynamic>>(
      '/auth/send-otp',
      data: <String, dynamic>{'phone': phone},
    );
  }

  /// Returns JWT [accessToken] on success.
  Future<String> verifyOtp(String phone, String otp) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: <String, dynamic>{
        'phone': phone,
        'otp': otp,
      },
    );

    final data = response.data;
    final token = data?['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('Missing accessToken in response');
    }
    return token;
  }
}
