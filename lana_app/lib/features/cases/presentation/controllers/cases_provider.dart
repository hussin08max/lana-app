import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cases_repository.dart';
import '../../data/models/case_model.dart';

final casesRepositoryProvider = Provider<CasesRepository>((ref) {
  return CasesRepository();
});

final openCasesProvider = FutureProvider<List<CaseModel>>((ref) async {
  return ref.read(casesRepositoryProvider).getOpenCases();
});

final caseDetailsProvider =
    FutureProvider.family<CaseModel, String>((ref, id) async {
  return ref.read(casesRepositoryProvider).getCaseDetails(id);
});
