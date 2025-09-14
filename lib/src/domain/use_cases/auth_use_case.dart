import '../../core/base/result.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailAndPasswordUseCase {
  final AuthRepository _authRepository;

  SignInWithEmailAndPasswordUseCase(this._authRepository);

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authRepository.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return result;
    } catch (e) {
      return Result.failure('Sign in failed: $e');
    }
  }
}

class CreateUserWithEmailAndPasswordUseCase {
  final AuthRepository _authRepository;

  CreateUserWithEmailAndPasswordUseCase(this._authRepository);

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final result = await _authRepository.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
        displayName: displayName.trim(),
      );

      return result;
    } catch (e) {
      return Result.failure('Sign up failed: $e');
    }
  }
}

class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<Result<void>> call() async {
    try {
      final result = await _authRepository.signOut();
      return result;
    } catch (e) {
      return Result.failure('Sign out failed: $e');
    }
  }
}
