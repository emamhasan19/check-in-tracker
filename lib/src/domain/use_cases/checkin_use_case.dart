import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/base/result.dart';
import '../../data/services/firebase_service.dart';
import '../repositories/location_repository.dart';

final class CreateCheckinPointUseCase {
  CreateCheckinPointUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Future<Result<String>> call({
    required String name,
    required String creator,
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    try {
      final pointId = await firebaseService.createCheckinPoint(
        name: name,
        creator: creator,
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
      );
      return Result.success(pointId);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

final class GetCheckinPointsUseCase {
  GetCheckinPointsUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Stream<QuerySnapshot> call() {
    return firebaseService.getCheckinPointsStream();
  }
}

final class GetActiveCheckinPointUseCase {
  GetActiveCheckinPointUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Future<Result<DocumentSnapshot?>> call() async {
    try {
      final point = await firebaseService.getActiveCheckinPoint();
      return Result.success(point);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

final class CheckInUseCase {
  CheckInUseCase(this.firebaseService, this.locationRepository);

  final FirebaseService firebaseService;
  final LocationRepository locationRepository;

  Future<Result<String>> call({
    required String pointId,
    required LatLng currentLocation,
    required LatLng checkinPointLocation,
    required double radiusMeters,
  }) async {
    try {
      final isWithinRadius = await locationRepository.isWithinCheckinRadius(
        currentLocation: currentLocation,
        checkinPointLocation: checkinPointLocation,
        radiusMeters: radiusMeters,
      );

      if (!isWithinRadius) {
        final distance = await locationRepository
            .calculateDistanceToCheckinPoint(
              currentLocation: currentLocation,
              checkinPointLocation: checkinPointLocation,
            );
        return Result.failure(
          'You are too far from the check-in point. Distance: ${distance.toStringAsFixed(1)}m (required: ${radiusMeters}m)',
        );
      }

      final checkinId = await firebaseService.checkIn(
        pointId: pointId,
        lat: currentLocation.latitude,
        lng: currentLocation.longitude,
      );

      return Result.success(checkinId);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

final class CheckOutUseCase {
  CheckOutUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Future<Result<void>> call(String checkinId) async {
    try {
      await firebaseService.checkOut(checkinId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

final class GetCurrentCheckinUseCase {
  GetCurrentCheckinUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Future<Result<DocumentSnapshot?>> call(String pointId) async {
    try {
      final checkin = await firebaseService.getCurrentCheckin(pointId);
      return Result.success(checkin);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

final class GetActiveCheckinsUseCase {
  GetActiveCheckinsUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Stream<QuerySnapshot> call(String pointId) {
    return firebaseService.getActiveCheckinsStream(pointId);
  }
}

final class GetActiveCheckinCountStreamUseCase {
  GetActiveCheckinCountStreamUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Stream<int> call(String pointId) {
    return firebaseService.getActiveCheckinCountStream(pointId);
  }
}

final class UpdateCheckinPointUseCase {
  UpdateCheckinPointUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Future<Result<void>> call({
    required String pointId,
    required String name,
    required String creator,
    required double radiusMeters,
  }) async {
    try {
      await firebaseService.updateCheckinPoint(
        pointId: pointId,
        name: name,
        creator: creator,
        radiusMeters: radiusMeters,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

final class DeleteCheckinPointUseCase {
  DeleteCheckinPointUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Future<Result<void>> call(String pointId) async {
    try {
      await firebaseService.deleteCheckinPoint(pointId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

final class UpdateLocationUseCase {
  UpdateLocationUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Future<Result<void>> call({
    required String checkinId,
    required double lat,
    required double lng,
  }) async {
    try {
      await firebaseService.updateLocation(
        checkinId: checkinId,
        lat: lat,
        lng: lng,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}

final class GetAllCheckinPointsWithCreatorsUseCase {
  GetAllCheckinPointsWithCreatorsUseCase(this.firebaseService);

  final FirebaseService firebaseService;

  Stream<List<Map<String, dynamic>>> call() {
    return firebaseService.getAllCheckinPointsWithCreatorsStream();
  }
}
