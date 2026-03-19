import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../cases/presentation/controllers/cases_provider.dart';
import '../controllers/agent_provider.dart';

class AddCaseUpdateScreen extends ConsumerStatefulWidget {
  const AddCaseUpdateScreen({
    super.key,
    required this.caseId,
  });

  final String caseId;

  @override
  ConsumerState<AddCaseUpdateScreen> createState() =>
      _AddCaseUpdateScreenState();
}

class _AddCaseUpdateScreenState extends ConsumerState<AddCaseUpdateScreen> {
  final _notesController = TextEditingController();
  final List<String> _imagePaths = [];
  static const int _maxImages = 5;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (!mounted || picked.isEmpty) return;

    setState(() {
      for (final x in picked) {
        if (_imagePaths.length >= _maxImages) break;
        _imagePaths.add(x.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final agent = ref.watch(agentControllerProvider);
    final isLoading = agent.status == AgentSubmitStatus.loading;

    ref.listen<AgentState>(agentControllerProvider, (previous, next) {
      if (next.status == AgentSubmitStatus.success) {
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        ref.invalidate(caseDetailsProvider(widget.caseId));
        ref.read(agentControllerProvider.notifier).reset();
        context.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم رفع التحديث بنجاح'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة تحديث للحالة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'رجوع',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ملاحظات (اختياري)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'صف ما تم إنجازه في الميدان…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: isLoading ? null : _pickImages,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _imagePaths.isEmpty
                    ? 'اختر صوراً (حتى $_maxImages)'
                    : 'إضافة المزيد (${_imagePaths.length}/$_maxImages)',
              ),
            ),
            if (_imagePaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_imagePaths[i]),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (!isLoading)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Material(
                              color: Colors.black54,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _imagePaths.removeAt(i);
                                  });
                                },
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
            if (agent.status == AgentSubmitStatus.error &&
                agent.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                agent.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 28),
            Consumer(
              builder: (context, ref, _) {
                final loading =
                    ref.watch(agentControllerProvider).status ==
                        AgentSubmitStatus.loading;
                return FilledButton(
                  onPressed: loading
                      ? null
                      : () {
                          ref.read(agentControllerProvider.notifier).submitUpdate(
                                widget.caseId,
                                _notesController.text,
                                List<String>.from(_imagePaths),
                              );
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                  ),
                  child: loading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('رفع التحديث'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
