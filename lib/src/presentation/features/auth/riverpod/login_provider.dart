import 'package:check_in_tracker/src/core/base/base.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/dependency_injection.dart';
import 'login_state.dart';

part 'login_provider.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() {
    return const LoginState();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<void> signIn() async {
    if (!state.canSubmit) return;

    state = state.copyWith(
      isLoading: true,
      isFailure: false,
      errorMessage: null,
    );

    final useCase = ref.read(signInWithEmailAndPasswordUseCaseProvider);
    final result = await useCase.call(
      email: state.email,
      password: state.password,
    );

    result.when(
      success: (user) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          isFailure: false,
          errorMessage: null,
        );
        // Navigation will be handled by the UI listener
      },
      failure: (error) {
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
    state = const LoginState();
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
