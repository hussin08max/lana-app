import 'package:dio/dio.dart';

import '../../../core/demo/demo_data.dart';
import '../../../core/network/api_client.dart';
import 'models/donation_model.dart';

class DonationsRepository {
  DonationsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<DonationModel> createDonation(String caseId, double amount) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/donations',
      data: <String, dynamic>{
        'caseId': caseId,
        'amount': amount,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Empty donation response');
    }
    return DonationModel.fromJson(data);
  }

  Future<List<DonationModel>> getMyDonations() async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        '/donations/my-donations',
      );
      final list = response.data;
      if (list == null || list.isEmpty) return DemoData.donations;
      return list
          .map((e) => DonationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return DemoData.donations;
    }
  }

  String messageFromDio(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final m = data['message'];
        if (m is String) return m;
        if (m is List && m.isNotEmpty) return m.first.toString();
      }
      return e.message ?? 'Request failed';
    }
    return e.toString();
  }
}
