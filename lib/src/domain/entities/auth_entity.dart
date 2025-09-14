import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final DateTime? createdAt;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.isAnonymous = false,
    this.createdAt,
  });

  factory AuthUser.fromFirebaseUser(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
      createdAt: user.metadata.creationTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'AuthUser(uid: $uid, email: $email, displayName: $displayName, isAnonymous: $isAnonymous)';
  }
}
