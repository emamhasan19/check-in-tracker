import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/logger/log.dart';
import '../../../../data/models/checkin_point.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_floating_action_button.dart';
import '../riverpod/map_provider.dart';
import '../riverpod/ui_state_provider.dart';
import '../widgets/checkin_info_card.dart';
import '../widgets/create_event_confirmation_dialog.dart';
import '../widgets/event_details_dialog.dart';
import '../widgets/events_list_dialog.dart';
import '../widgets/location_permission_blocker.dart';
import '../widgets/map_app_bar.dart';
import '../widgets/map_click_dialog.dart';

class CheckinMapPage extends ConsumerStatefulWidget {
  const CheckinMapPage({super.key});

  @override
  ConsumerState<CheckinMapPage> createState() => _CheckinMapPageState();
}

class _CheckinMapPageState extends ConsumerState<CheckinMapPage>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  bool _hasAttemptedLocationFetch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeMap();
  }

  void _initializeMap() async {
    await ref.read(mapNotifierProvider.notifier).checkLocationPermission();

    ref
        .read(mapNotifierProvider.notifier)
        .setMarkerTapCallback(_handleMarkerTap);

    ref.listenManual(mapNotifierProvider, (previous, next) {
      if (mounted) {
        ref
            .read(uiStateNotifierProvider.notifier)
            .updateMapData(
              markers: next.markers.toSet(),
              circles: next.circles.toSet(),
              currentLocation: next.currentLocation,
            );

        if (next.currentLocation != null) {
          _animateToLocation(next.currentLocation!);
        }

        final currentCheckinId = ref
            .read(uiStateNotifierProvider)
            .currentCheckinId;
        if (previous != null &&
            previous.currentLocation != null &&
            currentCheckinId != null &&
            next.currentLocation == null) {
          _showAutoLogoutNotification();
        }
      }
    });

    ref.read(mapNotifierProvider.notifier).checkCurrentStatus();

    // Only try to fetch location if we haven't already attempted it
    if (!_hasAttemptedLocationFetch) {
      Future.delayed(const Duration(milliseconds: 1000), () async {
        if (mounted) {
          await _ensureLocationIsFetched();
        }
      });
    }
  }

  Future<void> _ensureLocationIsFetched() async {
    // Prevent repeated calls
    if (_hasAttemptedLocationFetch) {
      Log.debug('Location fetch already attempted, skipping...');
      return;
    }

    _hasAttemptedLocationFetch = true;

    try {
      Log.debug('Starting location fetch process...');

      final hasPermission = await ref
          .read(mapNotifierProvider.notifier)
          .checkLocationPermission();

      Log.debug('Permission check result: $hasPermission');

      if (hasPermission) {
        final isServiceEnabled = await ref
            .read(mapNotifierProvider.notifier)
            .isLocationServiceEnabled();

        Log.debug('Location service enabled: $isServiceEnabled');

        if (isServiceEnabled) {
          Log.debug('Attempting to get current location...');
          await ref.read(mapNotifierProvider.notifier).getCurrentLocation();

          await Future.delayed(const Duration(milliseconds: 3000));

          final mapState = ref.read(mapNotifierProvider);
          Log.debug(
            'Current location after first attempt: ${mapState.currentLocation}',
          );

          if (mapState.currentLocation == null) {
            Log.debug('Location still null, trying again...');
            await ref.read(mapNotifierProvider.notifier).getCurrentLocation();

            await Future.delayed(const Duration(milliseconds: 2000));
            final mapState2 = ref.read(mapNotifierProvider);
            Log.debug(
              'Current location after second attempt: ${mapState2.currentLocation}',
            );
          } else {
            Log.debug(
              'Location successfully obtained: ${mapState.currentLocation}',
            );
          }
        } else {
          Log.debug('Location service is not enabled');
        }
      } else {
        Log.debug('Location permission not granted');
      }
    } catch (e) {
      Log.debug('Error ensuring location is fetched: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        // Reset the flag when app resumes to allow location fetch if permission is granted
        _hasAttemptedLocationFetch = false;
        _ensureLocationIsFetched();
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    ref.read(mapNotifierProvider.notifier).setMapController(controller);

    // Only try to fetch location if we haven't already attempted it
    if (!_hasAttemptedLocationFetch) {
      Future.delayed(const Duration(milliseconds: 1500), () async {
        if (mounted) {
          await _ensureLocationIsFetched();
        }
      });
    }
  }

  void _handleMapTap(LatLng position) {
    showDialog(
      context: context,
      builder: (context) =>
          MapClickDialog(lat: position.latitude, lng: position.longitude),
    );
  }

  void _handleMarkerTap(String pointId) async {
    Log.debug('Marker tapped: $pointId');

    final checkinPoint = _findCheckinPointById(pointId);
    Log.debug('Found checkin point: ${checkinPoint?.name}');

    if (checkinPoint != null) {
      final isCheckedIn = await ref
          .read(mapNotifierProvider.notifier)
          .isCheckedInToPoint(pointId);
      final currentCheckinId = await ref
          .read(mapNotifierProvider.notifier)
          .getCurrentCheckinId(pointId);
      final isCreator = await ref
          .read(mapNotifierProvider.notifier)
          .isCurrentUserCreator(pointId);

      Log.debug('isCheckedIn: $isCheckedIn, isCreator: $isCreator');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => EventDetailsDialog(
            checkinPoint: checkinPoint,
            isCheckedIn: isCheckedIn,
            currentCheckinId: currentCheckinId,
            isCreator: isCreator,
          ),
        );
      }
    } else {
      Log.debug('No checkin point found for ID: $pointId');
    }
  }

  CheckinPoint? _findCheckinPointById(String pointId) {
    final mapState = ref.read(mapNotifierProvider);

    Log.debug('Looking for pointId: $pointId');
    Log.debug('Available points: ${mapState.checkinPoints.length}');
    for (final point in mapState.checkinPoints) {
      Log.debug('Checking point: ${point.id}');
      if (point.id == pointId) {
        Log.debug('Found matching point: ${point.name}');
        return point;
      }
    }

    return null;
  }

  void _animateToLocation(LatLng location) {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(location, 16.0));
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? AppColors.primary,
        ),
      );
    }
  }

  void _showAutoLogoutNotification() {
    if (mounted) {
      ref.read(uiStateNotifierProvider.notifier).clearCurrentCheckinId();

      _showSnackBar(
        AppConstants.autoLogoutMessage,
        backgroundColor: AppColors.warning,
      );
    }
  }

  void _showEventsListDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          EventsListDialog(onViewOnMap: _navigateToEventLocation),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppConstants.logoutConfirmationTitle,
          style: AppTextStyle.semibold18.copyWith(color: AppColors.primary),
        ),
        content: Text(
          AppConstants.logoutConfirmationMessage,
          style: AppTextStyle.regular16.copyWith(color: AppColors.black),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.error, width: 1.5),
                    foregroundColor: AppColors.error,
                  ),
                  child: Text(
                    AppConstants.no,
                    style: AppTextStyle.medium16.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    ref.read(mapNotifierProvider.notifier).signOut();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 2,
                    shadowColor: AppColors.error.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppConstants.yes,
                    style: AppTextStyle.medium16.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToEventLocation(String pointId, double lat, double lng) async {
    if (_mapController != null) {
      final targetLocation = LatLng(lat, lng);

      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: targetLocation, zoom: 16.0),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.navigatedToEventLocation),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleCheckIn(CheckinPoint point) async {
    final uiState = ref.read(uiStateNotifierProvider);
    if (uiState.currentLocation == null) {
      _showSnackBar(
        AppConstants.locationNotAvailable,
        backgroundColor: AppColors.error,
      );
      return;
    }

    try {
      await ref
          .read(mapNotifierProvider.notifier)
          .checkIn(
            pointId: point.id,
            currentLocation: uiState.currentLocation!,
            checkinPointLocation: LatLng(point.lat, point.lng),
            radiusMeters: point.radiusMeters,
          );

      final checkinId = await ref
          .read(mapNotifierProvider.notifier)
          .getCurrentCheckinId(point.id);

      if (checkinId != null) {
        ref
            .read(uiStateNotifierProvider.notifier)
            .updateCurrentCheckinId(checkinId);
      }
    } catch (e) {
      _showSnackBar(
        '${AppConstants.checkinFailed}: $e',
        backgroundColor: AppColors.error,
      );
    }
  }

  void _handleCheckOut() async {
    final currentCheckinId = ref.read(uiStateNotifierProvider).currentCheckinId;
    if (currentCheckinId == null) return;

    try {
      await ref.read(mapNotifierProvider.notifier).checkOut(currentCheckinId);

      ref.read(uiStateNotifierProvider.notifier).clearCurrentCheckinId();
    } catch (e) {
      _showSnackBar(
        '${AppConstants.checkoutFailed}: $e',
        backgroundColor: AppColors.error,
      );
    }
  }

  void _handleCreateEvent() async {
    final uiState = ref.read(uiStateNotifierProvider);
    if (uiState.currentLocation == null) {
      ref.read(uiStateNotifierProvider.notifier).updateIsLoadingLocation(true);

      try {
        final hasPermission = await ref
            .read(mapNotifierProvider.notifier)
            .checkLocationPermission();
        if (!hasPermission) {
          _showSnackBar(
            AppConstants.locationPermissionRequiredForEvents,
            backgroundColor: AppColors.error,
          );
          ref
              .read(uiStateNotifierProvider.notifier)
              .updateIsLoadingLocation(false);
          return;
        }

        final isServiceEnabled = await ref
            .read(mapNotifierProvider.notifier)
            .isLocationServiceEnabled();
        if (!isServiceEnabled) {
          _showSnackBar(
            AppConstants.locationServiceDisabled,
            backgroundColor: AppColors.error,
          );
          ref
              .read(uiStateNotifierProvider.notifier)
              .updateIsLoadingLocation(false);
          return;
        }

        bool locationObtained = false;
        for (int attempt = 0; attempt < 3; attempt++) {
          Log.debug('Create event - location attempt ${attempt + 1}');
          await ref.read(mapNotifierProvider.notifier).getCurrentLocation();

          await Future.delayed(const Duration(milliseconds: 2000));

          final mapState = ref.read(mapNotifierProvider);
          if (mapState.currentLocation != null) {
            ref
                .read(uiStateNotifierProvider.notifier)
                .updateMapData(currentLocation: mapState.currentLocation);
            ref
                .read(uiStateNotifierProvider.notifier)
                .updateIsLoadingLocation(false);
            locationObtained = true;
            Log.debug(
              'Location obtained for create event: ${mapState.currentLocation}',
            );
            break;
          }

          if (attempt < 2) {
            await Future.delayed(const Duration(milliseconds: 1000));
          }
        }

        if (!locationObtained) {
          _showSnackBar(
            AppConstants.unableToGetLocation,
            backgroundColor: AppColors.error,
          );
          ref
              .read(uiStateNotifierProvider.notifier)
              .updateIsLoadingLocation(false);
          return;
        }
      } catch (e) {
        _showSnackBar(
          '${AppConstants.failedToGetLocation}: $e',
          backgroundColor: AppColors.error,
        );
        ref
            .read(uiStateNotifierProvider.notifier)
            .updateIsLoadingLocation(false);
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) => CreateEventConfirmationDialog(
        currentLocation: uiState.currentLocation!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(uiStateNotifierProvider);

    return LocationPermissionBlocker(
      // onPermissionGranted: () async {
      //   await _ensureLocationIsFetched();
      // },
      child: Scaffold(
        appBar: CheckinMapAppBar(
          onRefresh: () async {
            ref.read(mapNotifierProvider.notifier).forceMapInitialization();
            await _ensureLocationIsFetched();
          },
          onLogout: _showLogoutConfirmationDialog,
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: _handleMapTap,
              markers: uiState.markers,
              circles: uiState.circles,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  AppConstants.defaultLatitude,
                  AppConstants.defaultLongitude,
                ),
                zoom: 2.0,
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  CommonFloatingActionButton(
                    heroTag: AppConstants.createEventFab,
                    icon: Icons.add_location,
                    onPressed: uiState.isLoadingLocation
                        ? null
                        : _handleCreateEvent,
                    backgroundColor: uiState.isLoadingLocation
                        ? AppColors.grey
                        : AppColors.primary,
                    child: uiState.isLoadingLocation
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  CommonFloatingActionButton(
                    heroTag: AppConstants.myLocationFab,
                    icon: Icons.my_location,
                    onPressed: () async {
                      await _ensureLocationIsFetched();
                    },
                    backgroundColor: AppColors.primary,
                    iconColor: AppColors.white,
                  ),
                  const SizedBox(height: 8),
                  CommonFloatingActionButton(
                    heroTag: AppConstants.eventsListFab,
                    icon: Icons.list,
                    onPressed: _showEventsListDialog,
                    backgroundColor: AppColors.primary,
                    iconColor: AppColors.white,
                  ),
                ],
              ),
            ),

            if (uiState.selectedCheckinPoint != null)
              CheckinInfoCard(
                selectedPoint: uiState.selectedCheckinPoint!,
                onCheckIn: () => _handleCheckIn(uiState.selectedCheckinPoint!),
                onCheckOut: _handleCheckOut,
                onClose: () {
                  ref
                      .read(uiStateNotifierProvider.notifier)
                      .clearSelectedCheckinPoint();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }
}
