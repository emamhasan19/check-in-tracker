import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/checkin_point.dart';
import '../repositories/map_repository.dart';

final class CreateCheckinAreaCirclesUseCase {
  CreateCheckinAreaCirclesUseCase(this.repository);

  final MapRepository repository;

  Set<Circle> call({required List<CheckinPoint> checkinPoints}) {
    return repository.createCheckinAreaCircles(checkinPoints: checkinPoints);
  }
}
