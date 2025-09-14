import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';

class MapUtils {
  static CameraPosition getDefaultCameraPosition() {
    return const CameraPosition(
      target: LatLng(
        AppConstants.defaultLatitude,
        AppConstants.defaultLongitude,
      ),
      zoom: AppConstants.defaultZoom,
    );
  }

  static CameraPosition getCurrentLocationCameraPosition(LatLng position) {
    return CameraPosition(
      target: position,
      zoom: AppConstants.currentLocationZoom,
    );
  }
}
