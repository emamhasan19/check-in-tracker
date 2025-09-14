import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/base/repository.dart';
import '../../data/models/checkin_point.dart';

abstract base class MapRepository extends Repository {
  Set<Marker> createCheckinPointMarkers({
    required List<CheckinPoint> checkinPoints,
    required Function(String) onMarkerTap,
  });

  Set<Circle> createCheckinAreaCircles({
    required List<CheckinPoint> checkinPoints,
  });
}
