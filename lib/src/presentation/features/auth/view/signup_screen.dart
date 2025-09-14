import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../riverpod/signup_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(signupNotifierProvider, (previous, next) {
        if (next.isSuccess && !(previous?.isSuccess ?? false)) {
          _showSuccessDialog();
        } else if (next.isFailure && !(previous?.isFailure ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? AppConstants.signUpFailed),
              backgroundColor: AppColors.error,
            ),
          );
          ref.read(signupNotifierProvider.notifier).resetErrorState();
        }
      });
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(children: [const Text(AppConstants.signUpSuccessful)]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.accountCreatedMessage,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              AppConstants.pleaseSignInMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ref.read(signupNotifierProvider.notifier).resetState();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(AppConstants.signIn),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.location_on, size: 80, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  AppConstants.signUpToCreate,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  onChanged: (value) {
                    ref.read(signupNotifierProvider.notifier).updateName(value);
                  },
                  decoration: const InputDecoration(
                    labelText: AppConstants.fullNameLabel,
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.pleaseEnterName;
                    }
                    if (value.length < 2) {
                      return AppConstants.nameMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  onChanged: (value) {
                    ref
                        .read(signupNotifierProvider.notifier)
                        .updateEmail(value);
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppConstants.emailLabel,
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.pleaseEnterEmail;
                    }
                    if (!value.contains('@')) {
                      return AppConstants.pleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  onChanged: (value) {
                    ref
                        .read(signupNotifierProvider.notifier)
                        .updatePassword(value);
                  },
                  obscureText: signupState.obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppConstants.passwordLabel,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        signupState.obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        ref
                            .read(signupNotifierProvider.notifier)
                            .togglePasswordVisibility();
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.pleaseEnterPassword;
                    }
                    if (value.length < 6) {
                      return AppConstants.passwordMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  onChanged: (value) {
                    ref
                        .read(signupNotifierProvider.notifier)
                        .updateConfirmPassword(value);
                  },
                  obscureText: signupState.obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: AppConstants.confirmPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        signupState.obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        ref
                            .read(signupNotifierProvider.notifier)
                            .toggleConfirmPasswordVisibility();
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.pleaseConfirmPassword;
                    }
                    if (value != signupState.password) {
                      return AppConstants.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: signupState.canSubmit
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            ref.read(signupNotifierProvider.notifier).signUp();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: signupState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          AppConstants.createAccount,
                          style: TextStyle(color: AppColors.white),
                        ),
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(AppConstants.alreadyHaveAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
