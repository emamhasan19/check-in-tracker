import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/base/repository.dart';
import '../../core/base/result.dart';
import '../entities/location_entity.dart';

abstract base class LocationRepository extends Repository {
  Future<LocationPermissionEntity> checkLocationPermission();

  Future<bool> requestLocationPermission();

  Future<LocationServiceEntity> checkLocationService();

  Future<bool> requestLocationService();

  Future<Result<CurrentLocationEntity>> getCurrentLocation();

  Future<LocationAvailabilityEntity> checkLocationAvailability();

  Future<bool> getPermissionStatus();

  Future<double> calculateDistanceToCheckinPoint({
    required LatLng currentLocation,
    required LatLng checkinPointLocation,
  });

  Future<bool> isWithinCheckinRadius({
    required LatLng currentLocation,
    required LatLng checkinPointLocation,
    required double radiusMeters,
  });
}
