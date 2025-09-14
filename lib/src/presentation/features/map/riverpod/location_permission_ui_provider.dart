import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_permission_ui_provider.g.dart';

@riverpod
class LocationPermissionUiNotifier extends _$LocationPermissionUiNotifier {
  @override
  LocationPermissionUiState build() {
    return const LocationPermissionUiState();
  }

  void updateIsCheckingPermission(bool isChecking) {
    state = state.copyWith(isCheckingPermission: isChecking);
  }

  void updateHasPermission(bool hasPermission) {
    state = state.copyWith(hasPermission: hasPermission);
  }

  void updateIsPermanentlyDenied(bool isPermanentlyDenied) {
    state = state.copyWith(
      isPermanentlyDenied: isPermanentlyDenied,
      isCheckingPermission: false,
      permissionChecked: true,
    );
  }

  void updatePermissionChecked(bool hasPermission, bool isPermanentlyDenied) {
    state = state.copyWith(
      hasPermission: hasPermission,
      isPermanentlyDenied: isPermanentlyDenied,
      isCheckingPermission: false,
      permissionChecked: true,
    );
  }

  void reset() {
    state = const LocationPermissionUiState();
  }
}

class LocationPermissionUiState {
  const LocationPermissionUiState({
    this.isCheckingPermission = true,
    this.hasPermission = false,
    this.isPermanentlyDenied = false,
    this.permissionChecked = false,
  });

  final bool isCheckingPermission;
  final bool hasPermission;
  final bool isPermanentlyDenied;
  final bool permissionChecked;

  LocationPermissionUiState copyWith({
    bool? isCheckingPermission,
    bool? hasPermission,
    bool? isPermanentlyDenied,
    bool? permissionChecked,
  }) {
    return LocationPermissionUiState(
      isCheckingPermission: isCheckingPermission ?? this.isCheckingPermission,
      hasPermission: hasPermission ?? this.hasPermission,
      isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
      permissionChecked: permissionChecked ?? this.permissionChecked,
    );
  }
}
