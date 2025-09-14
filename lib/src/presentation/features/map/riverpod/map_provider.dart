import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/base/base.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/logger/log.dart';
import '../../../../data/models/checkin_point.dart';
import '../../../../domain/use_cases/auth_use_case.dart';
import '../../../../domain/use_cases/checkin_use_case.dart';
import '../../../../domain/use_cases/location_use_case.dart';
import '../../../../domain/use_cases/map_use_case.dart';
import '../utils/map_utils.dart';
import 'location_permission_ui_provider.dart';
import 'map_state.dart';

part 'map_provider.g.dart';

@riverpod
class MapNotifier extends _$MapNotifier {
  late final CheckLocationPermissionUseCase _checkLocationPermissionUseCase;
  late final RequestLocationPermissionUseCase _requestLocationPermissionUseCase;
  late final CheckLocationServiceUseCase _checkLocationServiceUseCase;
  late final RequestLocationServiceUseCase _requestLocationServiceUseCase;
  late final GetCurrentLocationUseCase getCurrentLocationUseCase;
  late final CheckLocationAvailabilityUseCase _checkLocationAvailabilityUseCase;
  late final CreateCheckinAreaCirclesUseCase _createCheckinAreaCirclesUseCase;
  late final GetCheckinPointsUseCase _getCheckinPointsUseCase;
  late final SignOutUseCase _signOutUseCase;

  GoogleMapController? _mapController;
  Function(String)? _onMarkerTapCallback;
  StreamSubscription<LocationData>? _locationStreamSubscription;
  String? _monitoredCheckinId;
  CheckinPoint? _monitoredCheckinPoint;

  @override
  MapState build() {
    _initializeUseCases();

    _loadCheckinPoints();

    ref.onDispose(() {
      _stopLocationMonitoring();
    });

    return MapState(
      cameraPosition: MapUtils.getDefaultCameraPosition(),
      hasLocationPermission: null,
      permissionRequestAttempts: 0,
    );
  }

  void _initializeUseCases() {
    _checkLocationPermissionUseCase = ref.read(
      checkLocationPermissionUseCaseProvider,
    );
    _requestLocationPermissionUseCase = ref.read(
      requestLocationPermissionUseCaseProvider,
    );
    _checkLocationServiceUseCase = ref.read(
      checkLocationServiceUseCaseProvider,
    );
    _requestLocationServiceUseCase = ref.read(
      requestLocationServiceUseCaseProvider,
    );
    getCurrentLocationUseCase = ref.read(getCurrentLocationUseCaseProvider);
    _checkLocationAvailabilityUseCase = ref.read(
      checkLocationAvailabilityUseCaseProvider,
    );
    _createCheckinAreaCirclesUseCase = ref.read(
      createCheckinAreaCirclesUseCaseProvider,
    );
    _getCheckinPointsUseCase = ref.read(getCheckinPointsUseCaseProvider);
    _signOutUseCase = ref.read(signOutUseCaseProvider);
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<bool> checkLocationPermission() async {
    try {
      // Check if we've already determined the permission state to prevent loops
      final permissionUiNotifier = ref.read(locationPermissionUiNotifierProvider.notifier);
      final currentState = ref.read(locationPermissionUiNotifierProvider);
      
      if (currentState.permissionChecked) {
        return currentState.hasPermission;
      }

      if (!await _ensureLocationServiceEnabled()) {
        permissionUiNotifier.updatePermissionChecked(false, false);
        _updateLocationPermissionState(false);
        return false;
      }

      final permissionEntity = await _checkLocationPermissionUseCase.call();

      if (permissionEntity.isGranted || permissionEntity.isLimited) {
        await getCurrentLocation();
        permissionUiNotifier.updatePermissionChecked(true, false);
        _updateLocationPermissionState(true);
        return true;
      } else if (permissionEntity.isPermanentlyDenied) {
        permissionUiNotifier.updateIsPermanentlyDenied(true);
        _updateLocationPermissionState(false);
        return false;
      } else {
        permissionUiNotifier.updatePermissionChecked(false, false);
        _updateLocationPermissionState(false);
        return false;
      }
    } catch (e) {
      Log.error('Error checking location permission: $e');
      final permissionUiNotifier = ref.read(locationPermissionUiNotifierProvider.notifier);
      permissionUiNotifier.updatePermissionChecked(false, false);
      _updateLocationPermissionState(false);
      return false;
    }
  }

  Future<bool> _ensureLocationServiceEnabled() async {
    final serviceEntity = await _checkLocationServiceUseCase.call();
    if (serviceEntity.isEnabled) return true;

    return _requestLocationServiceUseCase.call();
  }

  void _updateLocationPermissionState(bool hasPermission) {
    state = state.copyWith(hasLocationPermission: hasPermission);
  }

  Future<void> getCurrentLocation() async {
    try {
      final availabilityEntity = await _checkLocationAvailabilityUseCase.call();

      if (!availabilityEntity.isAvailable) {
        Log.error(
          'Location not available - permission: ${availabilityEntity.hasPermission}, service: ${availabilityEntity.serviceEnabled}',
        );
        _setDefaultCameraPosition();
        return;
      }

      final result = await getCurrentLocationUseCase.call().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          Log.error('Location request timed out');
          return const Result.failure('Location request timed out');
        },
      );

      result.when(
        success: (locationEntity) {
          if (locationEntity.isAvailable) {
            Log.info(
              'Location obtained: ${locationEntity.position.latitude}, ${locationEntity.position.longitude}',
            );
            _updateCurrentLocation(locationEntity.position);
          } else {
            Log.error('Location entity reports not available');
            _setDefaultCameraPosition();
          }
        },
        failure: (error) {
          Log.error('Failed to get current location: $error');
          _setDefaultCameraPosition();
        },
      );
    } catch (e) {
      Log.error('Error getting current location: $e');
      _setDefaultCameraPosition();
    }
  }

  Future<void> checkCurrentStatus() async {
    try {
      final getActiveCheckinPointUseCase = ref.read(
        getActiveCheckinPointUseCaseProvider,
      );
      final result = await getActiveCheckinPointUseCase.call();

      result.when(
        success: (pointDoc) {
          if (pointDoc != null) {
            final point = CheckinPoint.fromMap(
              pointDoc.id,
              pointDoc.data() as Map<String, dynamic>,
            );
            _loadActiveCheckins(point.id);
          }
        },
        failure: (error) {
          Log.error('Failed to get active check-in point: $error');
        },
      );
    } catch (e) {
      Log.error('Error checking current status: $e');
    }
  }

  void _loadActiveCheckins(String pointId) {
    final getActiveCheckinsUseCase = ref.read(getActiveCheckinsUseCaseProvider);
    getActiveCheckinsUseCase.call(pointId).listen((snapshot) {});
  }

  Future<void> checkIn({
    required String pointId,
    required LatLng currentLocation,
    required LatLng checkinPointLocation,
    required double radiusMeters,
  }) async {
    try {
      final checkInUseCase = ref.read(checkInUseCaseProvider);
      final result = await checkInUseCase.call(
        pointId: pointId,
        currentLocation: currentLocation,
        checkinPointLocation: checkinPointLocation,
        radiusMeters: radiusMeters,
      );

      result.when(
        success: (checkinId) {
          Log.info('Check-in successful, starting auto-logout monitoring');
          startAutoLogoutMonitoring(checkinId, pointId);
        },
        failure: (error) {
          Log.error('Check-in failed: $error');
        },
      );
    } catch (e) {
      Log.error('Error checking in: $e');
    }
  }

  Future<void> checkOut(String checkinId) async {
    try {
      if (_monitoredCheckinId == checkinId) {
        _stopLocationMonitoring();
      }

      final checkOutUseCase = ref.read(checkOutUseCaseProvider);
      final result = await checkOutUseCase.call(checkinId);

      result.when(
        success: (_) {},
        failure: (error) {
          Log.error('Check-out failed: $error');
        },
      );
    } catch (e) {
      Log.error('Error checking out: $e');
    }
  }

  void _updateCurrentLocation(LatLng position) {
    final cameraPosition = MapUtils.getCurrentLocationCameraPosition(position);

    state = state.copyWith(
      currentLocation: position,
      cameraPosition: cameraPosition,
    );

    _animateCameraToPosition(cameraPosition);
  }

  void _setDefaultCameraPosition() {
    final defaultPosition = MapUtils.getDefaultCameraPosition();
    state = state.copyWith(cameraPosition: defaultPosition);
  }

  void _animateCameraToPosition(CameraPosition position) {
    if (_mapController != null) {
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(position));
    }
  }

  void _loadCheckinPoints() {
    try {
      _getCheckinPointsUseCase.call().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final points = snapshot.docs.map((doc) {
            return CheckinPoint.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

          _updateMapMarkersAndCircles(points);
        }
      });
    } catch (e) {
      Log.error('Error loading check-in points: $e');
    }
  }

  Future<void> createCheckinEvent({
    required String name,
    required String creator,
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    try {
      final useCase = ref.read(createCheckinPointUseCaseProvider);
      final result = await useCase.call(
        name: name,
        creator: creator,
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
      );

      result.when(
        success: (pointId) {
          _loadCheckinPoints();
        },
        failure: (error) {
          throw Exception('Failed to create check-in event: $error');
        },
      );
    } catch (e) {
      throw Exception('Failed to create check-in event: $e');
    }
  }

  Future<void> updateCheckinPoint(
    String pointId, {
    required String name,
    required String creator,
    required double radiusMeters,
  }) async {
    try {
      final useCase = ref.read(updateCheckinPointUseCaseProvider);
      final result = await useCase.call(
        pointId: pointId,
        name: name,
        creator: creator,
        radiusMeters: radiusMeters,
      );

      result.when(
        success: (data) {
          _loadCheckinPoints();
        },
        failure: (error) {
          throw Exception('Failed to update check-in point: $error');
        },
      );
    } catch (e) {
      throw Exception('Failed to update check-in point: $e');
    }
  }

  Future<Result<void>> checkInToPoint(String pointId) async {
    try {
      final locationResult = await ref
          .read(getCurrentLocationUseCaseProvider)
          .call();

      return locationResult.when(
        success: (locationEntity) async {
          if (locationEntity.isAvailable) {
            return await _performCheckIn(pointId, locationEntity.position);
          } else {
            return Result.failure('Location not available');
          }
        },
        failure: (error) {
          return Result.failure('Failed to get current location: $error');
        },
      );
    } catch (e) {
      return Result.failure('Failed to check in: $e');
    }
  }

  Future<Result<void>> _performCheckIn(
    String pointId,
    LatLng currentLocation,
  ) async {
    try {
      final checkinPoint = _findCheckinPointById(pointId);
      if (checkinPoint == null) {
        return Result.failure('Check-in point not found');
      }

      final useCase = ref.read(checkInUseCaseProvider);
      final result = await useCase.call(
        pointId: pointId,
        currentLocation: currentLocation,
        checkinPointLocation: LatLng(checkinPoint.lat, checkinPoint.lng),
        radiusMeters: checkinPoint.radiusMeters,
      );

      return result.when(
        success: (data) async {
          _loadActiveCheckins(pointId);
          return const Result.success(null);
        },
        failure: (error) {
          return Result.failure('Failed to check in: $error');
        },
      );
    } catch (e) {
      return Result.failure('Failed to check in: $e');
    }
  }

  CheckinPoint? _findCheckinPointById(String pointId) {
    for (final point in state.checkinPoints) {
      if (point.id == pointId) {
        return point;
      }
    }
    return null;
  }

  Stream<int> getCheckinCountStream(String pointId) {
    try {
      final useCase = ref.read(getActiveCheckinCountStreamUseCaseProvider);
      return useCase.call(pointId);
    } catch (e) {
      return Stream.value(0);
    }
  }

  Stream<List<Map<String, dynamic>>> getActiveCheckinUsersStream(
    String pointId,
  ) {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      return firebaseService.getActiveCheckinUsersStream(pointId);
    } catch (e) {
      Log.error('Error getting active checkin users stream: $e');
      return Stream.value([]);
    }
  }

  Future<bool> isCheckedInToPoint(String pointId) async {
    try {
      final useCase = ref.read(getCurrentCheckinUseCaseProvider);
      final result = await useCase.call(pointId);

      return result.when(
        success: (checkin) => checkin != null,
        failure: (error) => false,
      );
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCurrentCheckinId(String pointId) async {
    try {
      final useCase = ref.read(getCurrentCheckinUseCaseProvider);
      final result = await useCase.call(pointId);

      return result.when(
        success: (checkin) => checkin?.id,
        failure: (error) => null,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> isCurrentUserCreator(String pointId) async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      return await firebaseService.isCurrentUserCreator(pointId);
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteCheckinPoint(String pointId) async {
    try {
      final useCase = ref.read(deleteCheckinPointUseCaseProvider);
      final result = await useCase.call(pointId);

      result.when(
        success: (data) {
          _loadCheckinPoints();
        },
        failure: (error) {
          throw Exception('Failed to delete check-in point: $error');
        },
      );
    } catch (e) {
      throw Exception('Failed to delete check-in point: $e');
    }
  }

  Future<Result<void>> checkOutFromPoint(String checkinId) async {
    try {
      final useCase = ref.read(checkOutUseCaseProvider);
      final result = await useCase.call(checkinId);

      return result.when(
        success: (data) async {
          _loadCheckinPoints();
          return const Result.success(null);
        },
        failure: (error) {
          return Result.failure('Failed to check out: $error');
        },
      );
    } catch (e) {
      return Result.failure('Failed to check out: $e');
    }
  }

  void _updateMapMarkersAndCircles(List<CheckinPoint> points) {
    final markers = points.map((point) {
      return Marker(
        markerId: MarkerId(point.id),
        position: LatLng(point.lat, point.lng),
        infoWindow: InfoWindow(
          title: point.name,
          snippet: 'Radius: ${point.radiusMeters.toStringAsFixed(0)}m',
        ),
        onTap: () => _onMarkerTap(point.id),
        icon: point.active
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();

    final circles = _createCheckinAreaCirclesUseCase.call(
      checkinPoints: points,
    );

    state = state.copyWith(
      markers: markers.toList(),
      circles: circles.toList(),
      checkinPoints: points,
    );
  }

  void _onMarkerTap(String pointId) {
    if (_onMarkerTapCallback != null) {
      _onMarkerTapCallback!(pointId);
    }
  }

  void setMarkerTapCallback(Function(String) callback) {
    _onMarkerTapCallback = callback;
  }

  void forceMapInitialization() async {
    try {
      if (state.hasLocationPermission == true) {
        await getCurrentLocation();
      } else {
        state = state.copyWith(
          cameraPosition: MapUtils.getDefaultCameraPosition(),
        );
      }
    } catch (e) {
      Log.error('Error in forceMapInitialization: $e');
      state = state.copyWith(
        cameraPosition: MapUtils.getDefaultCameraPosition(),
      );
    }
  }

  Future<void> startLocationMonitoring(
    String checkinId,
    CheckinPoint checkinPoint,
  ) async {
    try {
      Log.info('Starting location monitoring for checkin: $checkinId');

      _monitoredCheckinId = checkinId;
      _monitoredCheckinPoint = checkinPoint;

      final locationService = ref.read(locationServiceProvider);

      final streamStarted = await locationService.startLocationStream(
        distanceFilter: 5.0,
        interval: const Duration(seconds: 10),
      );

      if (!streamStarted) {
        Log.error('Failed to start location stream for monitoring');
        return;
      }

      _locationStreamSubscription = locationService.locationStream?.listen(
        (LocationData locationData) {
          _handleLocationUpdate(locationData);
        },
        onError: (error) {
          Log.error('Location stream error: $error');
        },
      );
    } catch (e) {
      Log.error('Error starting location monitoring: $e');
    }
  }

  void _stopLocationMonitoring() {
    try {
      Log.info('Stopping location monitoring');

      _locationStreamSubscription?.cancel();
      _locationStreamSubscription = null;
      _monitoredCheckinId = null;
      _monitoredCheckinPoint = null;

      final locationService = ref.read(locationServiceProvider);
      locationService.stopLocationStream();
    } catch (e) {
      Log.error('Error stopping location monitoring: $e');
    }
  }

  void _handleLocationUpdate(LocationData locationData) async {
    try {
      if (_monitoredCheckinPoint == null || _monitoredCheckinId == null) {
        return;
      }

      final currentLocation = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      final checkinPointLocation = LatLng(
        _monitoredCheckinPoint!.lat,
        _monitoredCheckinPoint!.lng,
      );

      final isWithinRadius = await ref
          .read(locationRepositoryProvider)
          .isWithinCheckinRadius(
            currentLocation: currentLocation,
            checkinPointLocation: checkinPointLocation,
            radiusMeters: _monitoredCheckinPoint!.radiusMeters,
          );

      if (!isWithinRadius) {
        Log.info('User moved out of radius, auto-logging out');

        final distance = await ref
            .read(locationRepositoryProvider)
            .calculateDistanceToCheckinPoint(
              currentLocation: currentLocation,
              checkinPointLocation: checkinPointLocation,
            );

        Log.info(
          'Distance from check-in point: ${distance.toStringAsFixed(1)}m (radius: ${_monitoredCheckinPoint!.radiusMeters}m)',
        );

        await _performAutoLogout(_monitoredCheckinId!);
      }
    } catch (e) {
      Log.error('Error handling location update: $e');
    }
  }

  Future<void> _performAutoLogout(String checkinId) async {
    try {
      Log.info('Performing auto-logout for checkin: $checkinId');

      _stopLocationMonitoring();

      final checkOutUseCase = ref.read(checkOutUseCaseProvider);
      final result = await checkOutUseCase.call(checkinId);

      result.when(
        success: (_) {
          Log.info('Auto-logout successful');

          state = state.copyWith();
        },
        failure: (error) {
          Log.error('Auto-logout failed: $error');

          if (_monitoredCheckinPoint != null) {
            startLocationMonitoring(checkinId, _monitoredCheckinPoint!);
          }
        },
      );
    } catch (e) {
      Log.error('Error performing auto-logout: $e');

      if (_monitoredCheckinPoint != null) {
        startLocationMonitoring(checkinId, _monitoredCheckinPoint!);
      }
    }
  }

  Future<void> startAutoLogoutMonitoring(
    String checkinId,
    String pointId,
  ) async {
    try {
      final checkinPoint = _findCheckinPointById(pointId);
      if (checkinPoint == null) {
        Log.error('Checkin point not found for monitoring: $pointId');
        return;
      }

      await startLocationMonitoring(checkinId, checkinPoint);
    } catch (e) {
      Log.error('Error starting auto-logout monitoring: $e');
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    try {
      final serviceEntity = await _checkLocationServiceUseCase.call();
      return serviceEntity.isEnabled;
    } catch (e) {
      Log.error('Error checking location service: $e');
      return false;
    }
  }

  Future<bool> requestLocationService() async {
    try {
      return await _requestLocationServiceUseCase.call();
    } catch (e) {
      Log.error('Error requesting location service: $e');
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final permissionUiNotifier = ref.read(locationPermissionUiNotifierProvider.notifier);
      
      final granted = await _requestLocationPermissionUseCase.call();

      if (granted) {
        await getCurrentLocation();
        permissionUiNotifier.updatePermissionChecked(true, false);
        _updateLocationPermissionState(true);
        return true;
      } else {
        final permissionEntity = await _checkLocationPermissionUseCase.call();
        if (permissionEntity.isLimited) {
          await getCurrentLocation();
          permissionUiNotifier.updatePermissionChecked(true, false);
          _updateLocationPermissionState(true);
          return true;
        } else if (permissionEntity.isPermanentlyDenied) {
          permissionUiNotifier.updateIsPermanentlyDenied(true);
          _updateLocationPermissionState(false);
          return false;
        } else {
          permissionUiNotifier.updatePermissionChecked(false, false);
          _updateLocationPermissionState(false);
          return false;
        }
      }
    } catch (e) {
      Log.error('Error requesting location permission: $e');
      final permissionUiNotifier = ref.read(locationPermissionUiNotifierProvider.notifier);
      permissionUiNotifier.updatePermissionChecked(false, false);
      _updateLocationPermissionState(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _signOutUseCase.call();
    } catch (e) {
      Log.error('Error signing out: $e');
    }
  }
}
