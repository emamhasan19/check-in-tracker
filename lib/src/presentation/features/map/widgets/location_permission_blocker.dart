import 'dart:async';

import 'package:check_in_tracker/src/presentation/core/theme/app_colors.dart';
import 'package:check_in_tracker/src/presentation/core/theme/app_text_styles.dart';
import 'package:check_in_tracker/src/presentation/core/widgets/common_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../riverpod/location_permission_ui_provider.dart';
import '../riverpod/map_provider.dart';

class LocationPermissionBlocker extends ConsumerStatefulWidget {
  final Widget child;
  // final VoidCallback? onPermissionGranted; // 🔥 Add callback

  const LocationPermissionBlocker({
    super.key,
    required this.child,
    // this.onPermissionGranted,
  });

  @override
  ConsumerState<LocationPermissionBlocker> createState() =>
      _LocationPermissionBlockerState();
}

class _LocationPermissionBlockerState
    extends ConsumerState<LocationPermissionBlocker>
    with WidgetsBindingObserver {
  Timer? _permissionCheckTimer;
  bool _hasTriggeredLocationFetch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
    _startPeriodicPermissionCheck();
  }

  // @override
  // void didUpdateWidget(covariant LocationPermissionBlocker oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   final uiState = ref.read(locationPermissionUiNotifierProvider);
  //   if (uiState.hasPermission) {
  //     widget.onPermissionGranted?.call(); // 🔥 Trigger callback
  //   }
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _permissionCheckTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicPermissionCheck() {
    _permissionCheckTimer?.cancel();
    _permissionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final uiState = ref.read(locationPermissionUiNotifierProvider);

      // Stop periodic checks if permanently denied
      if (uiState.isPermanentlyDenied) {
        timer.cancel();
        return;
      }

      if (!uiState.hasPermission && mounted) {
        _checkLocationPermission();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkLocationPermission() async {
    final notifier = ref.read(locationPermissionUiNotifierProvider.notifier);
    final uiState = ref.read(locationPermissionUiNotifierProvider);

    !uiState.isPermanentlyDenied
        ? notifier.updateIsCheckingPermission(true)
        : null;

    try {
      final isServiceEnabled = await ref
          .read(mapNotifierProvider.notifier)
          .isLocationServiceEnabled();

      if (!isServiceEnabled) {
        final serviceEnabled = await ref
            .read(mapNotifierProvider.notifier)
            .requestLocationService();

        if (!serviceEnabled) {
          notifier.updateHasPermission(false);
          notifier.updateIsCheckingPermission(false);
          return;
        }
      }

      final hasPermission = await ref
          .read(mapNotifierProvider.notifier)
          .checkLocationPermission();

      if (hasPermission) {
        notifier.updateHasPermission(true);
        notifier.updateIsCheckingPermission(false);
        _permissionCheckTimer?.cancel();
        return;
      }

      final permissionGranted = await ref
          .read(mapNotifierProvider.notifier)
          .requestLocationPermission();

      if (permissionGranted) {
        notifier.updateHasPermission(true);
        notifier.updateIsCheckingPermission(false);
        _permissionCheckTimer?.cancel();
      } else {
        final status = await Permission.location.status;
        notifier.updateHasPermission(false);
        notifier.updateIsPermanentlyDenied(status.isPermanentlyDenied);
        notifier.updateIsCheckingPermission(false);

        // Reset the flag when permission is denied
        _hasTriggeredLocationFetch = false;

        // 🔥 Stop timer once permanently denied
        if (status.isPermanentlyDenied) {
          _permissionCheckTimer?.cancel();
        }
      }
    } catch (e) {
      notifier.updateHasPermission(false);
      notifier.updateIsCheckingPermission(false);
      // Reset the flag when there's an error
      _hasTriggeredLocationFetch = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Reset the flag when app resumes to allow location fetch if permission is granted
      _hasTriggeredLocationFetch = false;
      _checkLocationPermission();

      _startPeriodicPermissionCheck();
    } else if (state == AppLifecycleState.paused) {
      _permissionCheckTimer?.cancel();
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.resumed) {
  //     _checkLocationPermission();
  //
  //     _startPeriodicPermissionCheck();
  //   } else if (state == AppLifecycleState.paused) {
  //     _permissionCheckTimer?.cancel();
  //   }
  // }
  //
  // void _startPeriodicPermissionCheck() {
  //   _permissionCheckTimer?.cancel();
  //   _permissionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
  //     final uiState = ref.read(locationPermissionUiNotifierProvider);
  //     if (!uiState.hasPermission && mounted) {
  //       _checkLocationPermission();
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }
  //
  // Future<void> _checkLocationPermission() async {
  //   ref
  //       .read(locationPermissionUiNotifierProvider.notifier)
  //       .updateIsCheckingPermission(true);
  //
  //   try {
  //     final isServiceEnabled = await ref
  //         .read(mapNotifierProvider.notifier)
  //         .isLocationServiceEnabled();
  //
  //     if (!isServiceEnabled) {
  //       final serviceEnabled = await ref
  //           .read(mapNotifierProvider.notifier)
  //           .requestLocationService();
  //
  //       if (!serviceEnabled) {
  //         ref
  //             .read(locationPermissionUiNotifierProvider.notifier)
  //             .updateHasPermission(false);
  //         ref
  //             .read(locationPermissionUiNotifierProvider.notifier)
  //             .updateIsCheckingPermission(false);
  //         return;
  //       }
  //     }
  //
  //     final hasPermission = await ref
  //         .read(mapNotifierProvider.notifier)
  //         .checkLocationPermission();
  //
  //     if (hasPermission) {
  //       ref
  //           .read(locationPermissionUiNotifierProvider.notifier)
  //           .updateHasPermission(true);
  //       ref
  //           .read(locationPermissionUiNotifierProvider.notifier)
  //           .updateIsCheckingPermission(false);
  //       _permissionCheckTimer?.cancel();
  //       return;
  //     }
  //
  //     final permissionGranted = await ref
  //         .read(mapNotifierProvider.notifier)
  //         .requestLocationPermission();
  //
  //     if (permissionGranted) {
  //       ref
  //           .read(locationPermissionUiNotifierProvider.notifier)
  //           .updateHasPermission(true);
  //       ref
  //           .read(locationPermissionUiNotifierProvider.notifier)
  //           .updateIsCheckingPermission(false);
  //       _permissionCheckTimer?.cancel();
  //     } else {
  //       final status = await Permission.location.status;
  //       ref
  //           .read(locationPermissionUiNotifierProvider.notifier)
  //           .updateHasPermission(false);
  //       ref
  //           .read(locationPermissionUiNotifierProvider.notifier)
  //           .updateIsPermanentlyDenied(status.isPermanentlyDenied);
  //       ref
  //           .read(locationPermissionUiNotifierProvider.notifier)
  //           .updateIsCheckingPermission(false);
  //     }
  //   } catch (e) {
  //     ref
  //         .read(locationPermissionUiNotifierProvider.notifier)
  //         .updateHasPermission(false);
  //     ref
  //         .read(locationPermissionUiNotifierProvider.notifier)
  //         .updateIsCheckingPermission(false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(locationPermissionUiNotifierProvider);
    if (uiState.hasPermission) {
      // Only trigger location fetch once when permission is newly granted
      if (!_hasTriggeredLocationFetch) {
        _hasTriggeredLocationFetch = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(mapNotifierProvider.notifier).getCurrentLocation();
        });
      }
      return widget.child;
    }

    if (uiState.isCheckingPermission) {
      return const Scaffold(body: Center(child: CommonLoader()));
    }

    if (!uiState.hasPermission) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  AppConstants.locationPermissionRequiredTitle,
                  style: AppTextStyle.bold20.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.locationPermissionRequiredMessage,
                  textAlign: TextAlign.justify,
                  style: AppTextStyle.regular16.copyWith(
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 32),
                if (uiState.isPermanentlyDenied) ...[
                  ElevatedButton(
                    onPressed: () async {
                      await openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      AppConstants.openSettings,
                      style: AppTextStyle.medium16.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _checkLocationPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      AppConstants.grantPermission,
                      style: AppTextStyle.medium16.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _checkLocationPermission,
                  child: Text(
                    AppConstants.cancel,
                    style: AppTextStyle.medium16.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
