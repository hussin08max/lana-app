import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/donations_repository.dart';
import '../../data/models/donation_model.dart';

final donationsRepositoryProvider = Provider<DonationsRepository>((ref) {
  return DonationsRepository();
});

final myDonationsProvider = FutureProvider<List<DonationModel>>((ref) async {
  return ref.read(donationsRepositoryProvider).getMyDonations();
});

enum DonationSubmitStatus { initial, loading, success, error }

class DonationState {
  const DonationState({
    required this.status,
    this.errorMessage,
  });

  final DonationSubmitStatus status;
  final String? errorMessage;

  DonationState copyWith({
    DonationSubmitStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DonationState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final donationControllerProvider =
    NotifierProvider<DonationController, DonationState>(DonationController.new);

class DonationController extends Notifier<DonationState> {
  @override
  DonationState build() =>
      const DonationState(status: DonationSubmitStatus.initial);

  void reset() {
    state = const DonationState(status: DonationSubmitStatus.initial);
  }

  Future<void> submitDonation(String caseId, double amount) async {
    if (amount <= 0) {
      state = DonationState(
        status: DonationSubmitStatus.error,
        errorMessage: 'أدخل مبلغاً صحيحاً (جنيه سوداني)',
      );
      return;
    }

    state = const DonationState(status: DonationSubmitStatus.loading);

    try {
      await ref.read(donationsRepositoryProvider).createDonation(caseId, amount);
      state = const DonationState(status: DonationSubmitStatus.success);
    } catch (e) {
      final msg =
          ref.read(donationsRepositoryProvider).messageFromDio(e);
      state = DonationState(
        status: DonationSubmitStatus.error,
        errorMessage: msg,
      );
    }
  }
}
