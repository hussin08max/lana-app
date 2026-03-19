import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _otpFocus = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final notifier = ref.read(authControllerProvider.notifier);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/home');
        });
        return;
      }
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        notifier.acknowledgeError();
      }
    });

    final isLoading = auth.status == AuthStatus.loading;
    final showOtp = auth.otpRequested ||
        auth.status == AuthStatus.otpSent ||
        (auth.status == AuthStatus.loading && auth.otpRequested);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Theme.of(context).brightness,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل الدخول'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'رجوع',
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.volunteer_activism_rounded,
                      size: 72,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لنا',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تسجيل الدخول برقم الهاتف',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.phone,
                      textInputAction:
                          showOtp ? TextInputAction.next : TextInputAction.done,
                      enabled: !isLoading && !showOtp,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        hintText: 'مثال: ٠٩٩١٢٣٤٥٦٧',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      onSubmitted: (_) {
                        if (!showOtp) {
                          notifier.sendOtp(_phoneController.text);
                        } else {
                          _otpFocus.requestFocus();
                        }
                      },
                    ),
                    if (showOtp) ...[
                      const SizedBox(height: 20),
                      TextField(
                        controller: _otpController,
                        focusNode: _otpFocus,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'رمز التحقق',
                          hintText: 'أدخل الرمز',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        onSubmitted: (_) {
                          notifier.verifyOtp(
                            _phoneController.text,
                            _otpController.text,
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (!showOtp) {
                                notifier.sendOtp(_phoneController.text);
                              } else {
                                notifier.verifyOtp(
                                  _phoneController.text,
                                  _otpController.text,
                                );
                              }
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
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              showOtp ? 'تحقق وتسجيل الدخول' : 'إرسال رمز التحقق',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
