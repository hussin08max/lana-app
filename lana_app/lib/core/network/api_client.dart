import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: <String, Object?>{
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          final isAuthPath =
              path.startsWith('/auth') || path.contains('/auth/');

          if (!isAuthPath) {
            final token = await _storage.read(key: _jwtKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (DioException e, handler) {
          handler.next(e);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio _dio;
  Dio get dio => _dio;

  static const String _jwtKey = 'jwt_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _jwtKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _jwtKey);
  }
}
