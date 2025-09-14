import '../../core/base/base.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Result<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<void>> signOut();
}
