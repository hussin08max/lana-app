import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/agent_repository.dart';

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  return AgentRepository();
});

enum AgentSubmitStatus { initial, loading, success, error }

class AgentState {
  const AgentState({
    required this.status,
    this.errorMessage,
  });

  final AgentSubmitStatus status;
  final String? errorMessage;

  AgentState copyWith({
    AgentSubmitStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AgentState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final agentControllerProvider =
    NotifierProvider<AgentController, AgentState>(AgentController.new);

class AgentController extends Notifier<AgentState> {
  @override
  AgentState build() =>
      const AgentState(status: AgentSubmitStatus.initial);

  void reset() {
    state = const AgentState(status: AgentSubmitStatus.initial);
  }

  Future<void> submitUpdate(
    String caseId,
    String? notes,
    List<String> imagePaths,
  ) async {
    if (imagePaths.isEmpty) {
      state = const AgentState(
        status: AgentSubmitStatus.error,
        errorMessage: 'Please pick at least one image',
      );
      return;
    }

    state = const AgentState(status: AgentSubmitStatus.loading);

    try {
      await ref.read(agentRepositoryProvider).addCaseUpdate(
            caseId,
            notes,
            imagePaths,
          );
      state = const AgentState(status: AgentSubmitStatus.success);
    } catch (e) {
      final msg = ref.read(agentRepositoryProvider).messageFromDio(e);
      state = AgentState(
        status: AgentSubmitStatus.error,
        errorMessage: msg,
      );
    }
  }
}
