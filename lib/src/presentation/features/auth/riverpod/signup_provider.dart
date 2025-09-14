import 'package:check_in_tracker/src/core/base/base.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/dependency_injection.dart';
import 'signup_state.dart';

part 'signup_provider.g.dart';

@riverpod
class SignupNotifier extends _$SignupNotifier {
  @override
  SignupState build() {
    return const SignupState();
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  Future<void> signUp() async {
    if (!state.canSubmit) return;

    state = state.copyWith(
      isLoading: true,
      isFailure: false,
      errorMessage: null,
    );

    final useCase = ref.read(createUserWithEmailAndPasswordUseCaseProvider);
    final result = await useCase.call(
      email: state.email,
      password: state.password,
      displayName: state.name,
    );

    result.when(
      success: (user) {
        print('✅ Sign-up successful: ${user.email}');
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          isFailure: false,
          errorMessage: null,
        );
        // Navigation will be handled by the UI listener
      },
      failure: (error) {
        print('❌ Sign-up failed: $error');
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          isFailure: true,
          errorMessage: error,
        );
      },
    );
  }

  void resetState() {
    state = const SignupState();
  }

  void resetErrorState() {
    state = state.copyWith(
      isLoading: false,
      isSuccess: false,
      isFailure: false,
      errorMessage: null,
    );
  }
}
