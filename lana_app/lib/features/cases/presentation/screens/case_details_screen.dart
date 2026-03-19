import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lana_app/core/utils/case_icons.dart';

import '../../../donations/presentation/controllers/donations_provider.dart';
import '../../data/models/case_update_model.dart';
import '../controllers/cases_provider.dart';

String _formatUpdateDate(DateTime d) {
  final l = d.toLocal();
  return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
      '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

void _showDonationBottomSheet(
  BuildContext context,
  WidgetRef ref,
  String caseId,
) {
  final messenger = ScaffoldMessenger.of(context);
  ref.read(donationControllerProvider.notifier).reset();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Consumer(
          builder: (context, ref, _) {
            return _DonationSheetBody(
              caseId: caseId,
              scaffoldMessenger: messenger,
            );
          },
        ),
      );
    },
  );
}

class _DonationSheetBody extends ConsumerStatefulWidget {
  const _DonationSheetBody({
    required this.caseId,
    required this.scaffoldMessenger,
  });

  final String caseId;
  final ScaffoldMessengerState scaffoldMessenger;

  @override
  ConsumerState<_DonationSheetBody> createState() =>
      _DonationSheetBodyState();
}

class _DonationSheetBodyState extends ConsumerState<_DonationSheetBody> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donation = ref.watch(donationControllerProvider);
    final isLoading = donation.status == DonationSubmitStatus.loading;

    ref.listen<DonationState>(donationControllerProvider, (previous, next) {
      if (next.status == DonationSubmitStatus.success) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        widget.scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('شكراً لتبرعك!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.invalidate(caseDetailsProvider(widget.caseId));
        ref.invalidate(myDonationsProvider);
        ref.read(donationControllerProvider.notifier).reset();
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'أدخل مبلغ التبرع',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            enabled: !isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'المبلغ (جنيه سوداني)',
              hintText: 'مثال: ٥٠ جنيه سوداني',
              prefixIcon: const Icon(Icons.payments_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            autofocus: true,
          ),
          if (donation.status == DonationSubmitStatus.error &&
              donation.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              donation.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isLoading
                ? null
                : () {
                    final raw = _amountController.text.trim();
                    final amount = double.tryParse(raw);
                    if (amount == null || amount <= 0) {
                      ref.read(donationControllerProvider.notifier).submitDonation(
                            widget.caseId,
                            0,
                          );
                      return;
                    }
                    ref
                        .read(donationControllerProvider.notifier)
                        .submitDonation(widget.caseId, amount);
                  },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

class CaseDetailsScreen extends ConsumerWidget {
  const CaseDetailsScreen({
    super.key,
    required this.caseId,
  });

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCase = ref.watch(caseDetailsProvider(caseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الحالة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'رجوع',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: 'إضافة تحديث',
            onPressed: () => context.push('/add-update/$caseId'),
          ),
        ],
      ),
      body: asyncCase.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(err.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(caseDetailsProvider(caseId)),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (c) {
          final creatorName = c.createdByUser?.name ?? '—';
          final updates = List<CaseUpdateModel>.from(c.updates ?? [])
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 12),
                            child: Icon(
                              iconForCase(c),
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              c.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.location,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أضافه: $creatorName',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'الوصف',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'التحديثات والإثباتات',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (updates.isEmpty)
                        Text(
                          'لا توجد تحديثات بعد.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        )
                      else
                        ...updates.map((u) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.update,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatUpdateDate(u.createdAt),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                      ],
                                    ),
                                    if (u.notes != null &&
                                        u.notes!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        u.notes!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                    if (u.images.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 88,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: u.images.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 8),
                                          itemBuilder: (context, i) {
                                            final url = u.images[i];
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                url,
                                                width: 88,
                                                height: 88,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (ctx, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    width: 88,
                                                    height: 88,
                                                    color: Colors.grey.shade200,
                                                    child: const Center(
                                                      child:
                                                          SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  width: 88,
                                                  height: 88,
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.broken_image_outlined,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () =>
                          _showDonationBottomSheet(context, ref, caseId),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'تبرع الآن',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
