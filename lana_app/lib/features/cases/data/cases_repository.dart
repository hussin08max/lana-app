import '../../../core/demo/demo_data.dart';
import '../../../core/network/api_client.dart';
import 'models/case_model.dart';

class CasesRepository {
  CasesRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<CaseModel>> getOpenCases() async {
    try {
      final response = await _client.dio.get<List<dynamic>>('/cases');
      final list = response.data;
      if (list == null || list.isEmpty) return DemoData.cases;
      return list
          .map((e) => CaseModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return DemoData.cases;
    }
  }

  Future<CaseModel> getCaseDetails(String id) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/cases/$id');
      final data = response.data;
      if (data == null) throw StateError('Empty response');
      return CaseModel.fromJson(data);
    } catch (_) {
      final demo = DemoData.caseById(id);
      if (demo != null) return demo;
      rethrow;
    }
  }
}
