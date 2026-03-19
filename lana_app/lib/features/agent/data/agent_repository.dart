import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class AgentRepository {
  AgentRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Multipart POST `/case-updates/case/:caseId`.
  Future<void> addCaseUpdate(
    String caseId,
    String? notes,
    List<String> imagePaths,
  ) async {
    final formData = FormData();

    final trimmed = notes?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      formData.fields.add(MapEntry('notes', trimmed));
    }

    for (final path in imagePaths) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(path),
        ),
      );
    }

    await _client.dio.post<void>(
      '/case-updates/case/$caseId',
      data: formData,
    );
  }

  String messageFromDio(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final m = data['message'];
        if (m is String) return m;
        if (m is List && m.isNotEmpty) return m.first.toString();
      }
      return e.message ?? 'Upload failed';
    }
    return e.toString();
  }
}
