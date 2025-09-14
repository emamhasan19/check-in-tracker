import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/checkin_point.dart';

class MapState {
  const MapState({
    this.markers = const [],
    this.circles = const [],
    this.checkinPoints = const [],
    this.isLoading = false,
    this.currentLocation,
    this.cameraPosition,
    this.hasLocationPermission,
    this.permissionRequestAttempts = 0,
  });

  final List<Marker> markers;
  final List<Circle> circles;
  final List<CheckinPoint> checkinPoints;
  final bool isLoading;
  final LatLng? currentLocation;
  final CameraPosition? cameraPosition;
  final bool? hasLocationPermission;
  final int permissionRequestAttempts;

  MapState copyWith({
    List<Marker>? markers,
    List<Circle>? circles,
    List<CheckinPoint>? checkinPoints,
    bool? isLoading,
    LatLng? currentLocation,
    CameraPosition? cameraPosition,
    bool? hasLocationPermission,
    int? permissionRequestAttempts,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
      checkinPoints: checkinPoints ?? this.checkinPoints,
      isLoading: isLoading ?? this.isLoading,
      currentLocation: currentLocation ?? this.currentLocation,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      permissionRequestAttempts:
          permissionRequestAttempts ?? this.permissionRequestAttempts,
    );
  }
}
