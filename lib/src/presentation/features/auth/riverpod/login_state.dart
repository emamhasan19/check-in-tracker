class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final bool isFailure;
  final String? errorMessage;
  final String email;
  final String password;
  final bool obscurePassword;

  const LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.errorMessage,
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isFailure,
    String? errorMessage,
    String? email,
    String? password,
    bool? obscurePassword,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      errorMessage: errorMessage ?? this.errorMessage,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  bool get isValidEmail => email.isNotEmpty && email.contains('@');
  bool get isValidPassword => password.isNotEmpty && password.length >= 6;
  bool get canSubmit => isValidEmail && isValidPassword && !isLoading;
}
