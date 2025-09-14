import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPermissionEntity {
  const LocationPermissionEntity({
    required this.isGranted,
    required this.isPermanentlyDenied,
    this.isLimited = false,
  });

  final bool isGranted;
  final bool isPermanentlyDenied;
  final bool isLimited;
}

class LocationServiceEntity {
  const LocationServiceEntity({required this.isEnabled});

  final bool isEnabled;
}

class CurrentLocationEntity {
  const CurrentLocationEntity({
    required this.position,
    required this.isAvailable,
  });

  final LatLng position;
  final bool isAvailable;
}

class LocationAvailabilityEntity {
  const LocationAvailabilityEntity({
    required this.hasPermission,
    required this.serviceEnabled,
    required this.isAvailable,
  });

  final bool hasPermission;
  final bool serviceEnabled;
  final bool isAvailable;
}
