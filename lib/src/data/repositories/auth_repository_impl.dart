import 'package:firebase_auth/firebase_auth.dart';

import '../../core/base/base.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepositoryImpl(this._firebaseService);

  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = AuthUser.fromFirebaseUser(credential.user!);
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_firebaseService.getErrorMessage(e));
    } catch (e) {
      return Result.failure('Sign in failed: $e');
    }
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await _firebaseService.updateDisplayName(displayName);

      final user = AuthUser.fromFirebaseUser(credential.user!);
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_firebaseService.getErrorMessage(e));
    } catch (e) {
      return Result.failure('Sign up failed: $e');
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseService.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Sign out failed: $e');
    }
  }
}
