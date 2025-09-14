import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/logger/log.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get checkinPointsCollection =>
      _firestore.collection('checkinPoints');

  CollectionReference get checkinsCollection =>
      _firestore.collection('checkins');

  CollectionReference get usersCollection => _firestore.collection('users');

  String? get currentUserId {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  bool get isSignedIn {
    try {
      return _auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _createUserProfile(credential.user!);

      return credential;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      await usersCollection.doc(user.uid).set({
        'userId': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Log.debug('Failed to create user profile: $e');
    }
  }

  Future<void> _updateUserProfile(User user) async {
    try {
      await usersCollection.doc(user.uid).update({
        'displayName': user.displayName,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Log.debug('Failed to update user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }

      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await _createUserProfile(currentUser);
        return {
          'userId': userId,
          'email': currentUser.email,
          'displayName': currentUser.displayName,
        };
      }

      return null;
    } catch (e) {
      Log.debug('Failed to get user profile: $e');
      return null;
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();

        await _updateUserProfile(user);
      } else {
        throw Exception('No user signed in');
      }
    } catch (e) {
      throw Exception('Update display name failed: $e');
    }
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<String> createCheckinPoint({
    required String name,
    required String creator,
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    try {
      await deactivateAllCheckinPoints();

      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final docRef = await checkinPointsCollection.add({
        'name': name,
        'creator': creator,
        'lat': lat,
        'lng': lng,
        'radiusMeters': radiusMeters,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': userId,
        'createdByEmail': _auth.currentUser?.email,
        'createdByDisplayName': _auth.currentUser?.displayName,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create check-in point: $e');
    }
  }

  Future<void> deactivateAllCheckinPoints() async {
    try {
      final activePoints = await checkinPointsCollection
          .where('active', isEqualTo: true)
          .get();

      for (var doc in activePoints.docs) {
        await doc.reference.update({'active': false});
      }
    } catch (e) {
      throw Exception('Failed to deactivate check-in points: $e');
    }
  }

  Future<void> updateCheckinPoint({
    required String pointId,
    required String name,
    required String creator,
    required double radiusMeters,
  }) async {
    try {
      await checkinPointsCollection.doc(pointId).update({
        'name': name,
        'creator': creator,
        'radiusMeters': radiusMeters,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update check-in point: $e');
    }
  }

  Future<void> deleteCheckinPoint(String pointId) async {
    try {
      final isCreator = await isCurrentUserCreator(pointId);
      if (!isCreator) {
        throw Exception('Only the event creator can delete this event');
      }

      final checkinsQuery = await checkinsCollection
          .where('pointId', isEqualTo: pointId)
          .get();

      for (var doc in checkinsQuery.docs) {
        await doc.reference.delete();
      }

      await checkinPointsCollection.doc(pointId).delete();
    } catch (e) {
      throw Exception('Failed to delete check-in point: $e');
    }
  }

  Stream<QuerySnapshot> getCheckinPointsStream() {
    return checkinPointsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot?> getActiveCheckinPoint() async {
    try {
      final querySnapshot = await checkinPointsCollection
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
    } catch (e) {
      throw Exception('Failed to get active check-in point: $e');
    }
  }

  Future<String> checkIn({
    required String pointId,
    required double lat,
    required double lng,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final existingCheckin = await checkinsCollection
          .where('userId', isEqualTo: userId)
          .where('pointId', isEqualTo: pointId)
          .where('checkedOutAt', isNull: true)
          .limit(1)
          .get();

      if (existingCheckin.docs.isNotEmpty) {
        throw Exception('User is already checked in to this point');
      }

      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        final userProfile = await getUserProfile(userId);

        String? userEmail = userProfile?['email'] ?? currentUser.email;
        String? userDisplayName =
            userProfile?['displayName'] ?? currentUser.displayName;

        final docRef = await checkinsCollection.add({
          'userId': userId,
          'pointId': pointId,
          'userEmail': userEmail,
          'userDisplayName': userDisplayName,
          'checkedInAt': FieldValue.serverTimestamp(),
          'checkedOutAt': null,
          'lastLocation': {
            'lat': lat,
            'lng': lng,
            'ts': FieldValue.serverTimestamp(),
          },
        });

        await _updateCheckinCount(pointId, 1);

        return docRef.id;
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      throw Exception('Failed to check in: $e');
    }
  }

  Future<void> checkOut(String checkinId) async {
    try {
      final checkinDoc = await checkinsCollection.doc(checkinId).get();
      if (!checkinDoc.exists) {
        throw Exception('Check-in not found');
      }

      final data = checkinDoc.data() as Map<String, dynamic>;
      final pointId = data['pointId'] as String;

      await checkinsCollection.doc(checkinId).update({
        'checkedOutAt': FieldValue.serverTimestamp(),
      });

      await _updateCheckinCount(pointId, -1);
    } catch (e) {
      throw Exception('Failed to check out: $e');
    }
  }

  Future<void> updateLocation({
    required String checkinId,
    required double lat,
    required double lng,
  }) async {
    try {
      await checkinsCollection.doc(checkinId).update({
        'lastLocation': {
          'lat': lat,
          'lng': lng,
          'ts': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  Future<DocumentSnapshot?> getCurrentCheckin(String pointId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      final querySnapshot = await checkinsCollection
          .where('userId', isEqualTo: userId)
          .where('pointId', isEqualTo: pointId)
          .where('checkedOutAt', isNull: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
    } catch (e) {
      throw Exception('Failed to get current check-in: $e');
    }
  }

  Stream<QuerySnapshot> getActiveCheckinsStream(String pointId) {
    return checkinsCollection
        .where('pointId', isEqualTo: pointId)
        .where('checkedOutAt', isNull: true)
        .snapshots();
  }

  Future<int> getActiveCheckinCount(String pointId) async {
    try {
      final querySnapshot = await checkinsCollection
          .where('pointId', isEqualTo: pointId)
          .where('checkedOutAt', isNull: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get active check-in count: $e');
    }
  }

  Stream<int> getActiveCheckinCountStream(String pointId) {
    return checkinsCollection
        .where('pointId', isEqualTo: pointId)
        .where('checkedOutAt', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<List<Map<String, dynamic>>> getActiveCheckinUsers(
    String pointId,
  ) async {
    try {
      final checkinsSnapshot = await checkinsCollection
          .where('pointId', isEqualTo: pointId)
          .where('checkedOutAt', isNull: true)
          .get();

      if (checkinsSnapshot.docs.isEmpty) {
        return [];
      }

      final List<Map<String, dynamic>> checkinUsers = [];

      for (final checkinDoc in checkinsSnapshot.docs) {
        final checkinData = checkinDoc.data() as Map<String, dynamic>;
        final userId = checkinData['userId'] as String;

        String? userEmail = checkinData['userEmail'];
        String? userDisplayName = checkinData['userDisplayName'];

        if (userDisplayName == null || userDisplayName.isEmpty) {
          if (userEmail != null && userEmail.isNotEmpty) {
            userDisplayName = userEmail.split('@').first;
          } else {
            userDisplayName = 'User ${userId.substring(0, 8)}';
          }
        }

        checkinUsers.add({
          'checkinId': checkinDoc.id,
          'userId': userId,
          'userEmail': userEmail,
          'userDisplayName': userDisplayName,
          'checkedInAt': checkinData['checkedInAt'],
          'lastLocation': checkinData['lastLocation'],
        });
      }

      return checkinUsers;
    } catch (e) {
      throw Exception('Failed to get active checkin users: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getActiveCheckinUsersStream(
    String pointId,
  ) {
    return checkinsCollection
        .where('pointId', isEqualTo: pointId)
        .where('checkedOutAt', isNull: true)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return <Map<String, dynamic>>[];
          }

          final List<Map<String, dynamic>> checkinUsers = [];

          for (final checkinDoc in snapshot.docs) {
            final checkinData = checkinDoc.data() as Map<String, dynamic>;
            final userId = checkinData['userId'] as String;

            String? userEmail = checkinData['userEmail'];
            String? userDisplayName = checkinData['userDisplayName'];

            if (userDisplayName == null || userDisplayName.isEmpty) {
              if (userEmail != null && userEmail.isNotEmpty) {
                userDisplayName = userEmail.split('@').first;
              } else {
                userDisplayName = 'User ${userId.substring(0, 8)}';
              }
            }

            checkinUsers.add({
              'checkinId': checkinDoc.id,
              'userId': userId,
              'userEmail': userEmail,
              'userDisplayName': userDisplayName,
              'checkedInAt': checkinData['checkedInAt'],
              'lastLocation': checkinData['lastLocation'],
            });
          }

          return checkinUsers;
        });
  }

  Future<void> _updateCheckinCount(String pointId, int increment) async {
    try {
      await checkinPointsCollection.doc(pointId).update({
        'activeCheckinCount': FieldValue.increment(increment),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      try {
        final currentCount = await getActiveCheckinCount(pointId);
        await checkinPointsCollection.doc(pointId).update({
          'activeCheckinCount': currentCount + increment,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } catch (e2) {
        await checkinPointsCollection.doc(pointId).update({
          'activeCheckinCount': increment > 0 ? 1 : 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<bool> isCurrentUserCreator(String pointId) async {
    try {
      final doc = await checkinPointsCollection.doc(pointId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final creatorId = data['createdBy'] as String?;
      final currentUserId = this.currentUserId;

      return creatorId == currentUserId;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCheckinPointCreator(String pointId) async {
    try {
      final doc = await checkinPointsCollection.doc(pointId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return {
        'createdBy': data['createdBy'],
        'createdByEmail': data['createdByEmail'],
        'createdByDisplayName': data['createdByDisplayName'],
        'createdAt': data['createdAt'],
      };
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMyCheckinPoints() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      final query = await checkinPointsCollection
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllCheckinPointsWithCreators() async {
    try {
      final checkinPointsSnapshot = await checkinPointsCollection.get();

      if (checkinPointsSnapshot.docs.isEmpty) {
        return [];
      }

      final List<Map<String, dynamic>> checkinPointsWithCreators = [];

      for (final pointDoc in checkinPointsSnapshot.docs) {
        final pointData = pointDoc.data() as Map<String, dynamic>;
        final createdBy = pointData['createdBy'] as String;

        final creatorProfile = await getUserProfile(createdBy);

        String? creatorEmail =
            pointData['createdByEmail'] ?? creatorProfile?['email'];
        String? creatorDisplayName =
            pointData['createdByDisplayName'] ?? creatorProfile?['displayName'];

        if (creatorDisplayName == null || creatorDisplayName.isEmpty) {
          if (creatorEmail != null && creatorEmail.isNotEmpty) {
            creatorDisplayName = creatorEmail.split('@').first;
          } else {
            creatorDisplayName = 'User ${createdBy.substring(0, 8)}';
          }
        }

        checkinPointsWithCreators.add({
          'pointId': pointDoc.id,
          'name': pointData['name'],
          'description': pointData['description'] ?? '',
          'latitude': pointData['lat'],
          'longitude': pointData['lng'],
          'radius': pointData['radiusMeters'],
          'creatorId': createdBy,
          'creatorEmail': creatorEmail,
          'creatorDisplayName': creatorDisplayName,
          'createdAt': pointData['createdAt'],
          'checkinCount': pointData['checkinCount'] ?? 0,
        });
      }

      checkinPointsWithCreators.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp;
        final bTime = b['createdAt'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      return checkinPointsWithCreators;
    } catch (e) {
      throw Exception('Failed to get check-in points: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getAllCheckinPointsWithCreatorsStream() {
    return checkinPointsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<Map<String, dynamic>> checkinPointsWithCreators = [];

          for (final pointDoc in snapshot.docs) {
            final pointData = pointDoc.data() as Map<String, dynamic>;
            final createdBy = pointData['createdBy'] as String;

            final creatorProfile = await getUserProfile(createdBy);

            String? creatorEmail =
                pointData['createdByEmail'] ?? creatorProfile?['email'];
            String? creatorDisplayName =
                pointData['createdByDisplayName'] ??
                creatorProfile?['displayName'];

            if (creatorDisplayName == null || creatorDisplayName.isEmpty) {
              if (creatorEmail != null && creatorEmail.isNotEmpty) {
                creatorDisplayName = creatorEmail.split('@').first;
              } else {
                creatorDisplayName = 'User ${createdBy.substring(0, 8)}';
              }
            }

            checkinPointsWithCreators.add({
              'pointId': pointDoc.id,
              'name': pointData['name'],
              'description': pointData['description'] ?? '',
              'latitude': pointData['lat'],
              'longitude': pointData['lng'],
              'radius': pointData['radiusMeters'],
              'creatorId': createdBy,
              'creatorEmail': creatorEmail,
              'creatorDisplayName': creatorDisplayName,
              'createdAt': pointData['createdAt'],
              'checkinCount': pointData['checkinCount'] ?? 0,
            });
          }

          return checkinPointsWithCreators;
        });
  }
}
