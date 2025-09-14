import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/repositories/map_repository.dart';
import '../../presentation/core/theme/app_colors.dart';
import '../models/checkin_point.dart';

final class MapRepositoryImpl extends MapRepository {
  MapRepositoryImpl();

  @override
  Set<Marker> createCheckinPointMarkers({
    required List<CheckinPoint> checkinPoints,
    required Function(String) onMarkerTap,
  }) {
    return checkinPoints.map((point) {
      return Marker(
        markerId: MarkerId(point.id),
        position: LatLng(point.lat, point.lng),
        infoWindow: InfoWindow(
          title: point.name,
          snippet: 'Radius: ${point.radiusMeters.toStringAsFixed(0)}m',
        ),
        onTap: () => onMarkerTap(point.id),
        icon: point.active
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();
  }

  @override
  Set<Circle> createCheckinAreaCircles({
    required List<CheckinPoint> checkinPoints,
  }) {
    return checkinPoints.map((point) {
      return Circle(
        circleId: CircleId(point.id),
        center: LatLng(point.lat, point.lng),
        radius: point.radiusMeters,
        fillColor: point.active
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        strokeColor: point.active ? AppColors.primary : Colors.grey,
        strokeWidth: 2,
      );
    }).toSet();
  }

  @override
  CameraPosition getInitialCameraPosition({
    required double lat,
    required double lng,
    double zoom = 15.0,
  }) {
    return CameraPosition(target: LatLng(lat, lng), zoom: zoom);
  }

  @override
  Marker createCheckinPointMarker({
    required String id,
    required LatLng position,
    required String title,
    required String snippet,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
      onTap: onTap,
      icon: isActive
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  @override
  Circle createCheckinAreaCircle({
    required String id,
    required LatLng center,
    required double radius,
    required bool isActive,
  }) {
    return Circle(
      circleId: CircleId(id),
      center: center,
      radius: radius,
      fillColor: isActive
          ? AppColors.primary.withValues(alpha: 0.2)
          : Colors.grey.withValues(alpha: 0.2),
      strokeColor: isActive ? AppColors.primary : Colors.grey,
      strokeWidth: 2,
    );
  }
}
