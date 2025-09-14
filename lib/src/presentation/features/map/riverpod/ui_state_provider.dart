import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/models/checkin_point.dart';

part 'ui_state_provider.g.dart';

@riverpod
class UiStateNotifier extends _$UiStateNotifier {
  @override
  UiState build() {
    return const UiState();
  }

  void updateSelectedCheckinPoint(CheckinPoint? point) {
    state = state.copyWith(selectedCheckinPoint: point);
  }

  void updateCurrentCheckinId(String? checkinId) {
    state = state.copyWith(currentCheckinId: checkinId);
  }

  void updateIsLoadingLocation(bool isLoading) {
    state = state.copyWith(isLoadingLocation: isLoading);
  }

  void updateMapData({
    Set<Marker>? markers,
    Set<Circle>? circles,
    LatLng? currentLocation,
  }) {
    state = state.copyWith(
      markers: markers ?? state.markers,
      circles: circles ?? state.circles,
      currentLocation: currentLocation ?? state.currentLocation,
    );
  }

  void clearSelectedCheckinPoint() {
    state = state.copyWith(selectedCheckinPoint: null);
  }

  void clearCurrentCheckinId() {
    state = state.copyWith(currentCheckinId: null);
  }

  void reset() {
    state = const UiState();
  }
}

class UiState {
  const UiState({
    this.selectedCheckinPoint,
    this.currentCheckinId,
    this.isLoadingLocation = false,
    this.markers = const {},
    this.circles = const {},
    this.currentLocation,
  });

  final CheckinPoint? selectedCheckinPoint;
  final String? currentCheckinId;
  final bool isLoadingLocation;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final LatLng? currentLocation;

  UiState copyWith({
    CheckinPoint? selectedCheckinPoint,
    String? currentCheckinId,
    bool? isLoadingLocation,
    Set<Marker>? markers,
    Set<Circle>? circles,
    LatLng? currentLocation,
  }) {
    return UiState(
      selectedCheckinPoint: selectedCheckinPoint ?? this.selectedCheckinPoint,
      currentCheckinId: currentCheckinId ?? this.currentCheckinId,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}
