part of '../dependency_injection.dart';

@riverpod
CheckLocationPermissionUseCase checkLocationPermissionUseCase(Ref ref) {
  final repository = ref.read(locationRepositoryProvider);
  return CheckLocationPermissionUseCase(repository);
}

@riverpod
RequestLocationPermissionUseCase requestLocationPermissionUseCase(Ref ref) {
  final repository = ref.read(locationRepositoryProvider);
  return RequestLocationPermissionUseCase(repository);
}

@riverpod
CheckLocationServiceUseCase checkLocationServiceUseCase(Ref ref) {
  final repository = ref.read(locationRepositoryProvider);
  return CheckLocationServiceUseCase(repository);
}

@riverpod
RequestLocationServiceUseCase requestLocationServiceUseCase(Ref ref) {
  final repository = ref.read(locationRepositoryProvider);
  return RequestLocationServiceUseCase(repository);
}

@riverpod
GetCurrentLocationUseCase getCurrentLocationUseCase(Ref ref) {
  final repository = ref.read(locationRepositoryProvider);
  return GetCurrentLocationUseCase(repository);
}

@riverpod
CheckLocationAvailabilityUseCase checkLocationAvailabilityUseCase(Ref ref) {
  final repository = ref.read(locationRepositoryProvider);
  return CheckLocationAvailabilityUseCase(repository);
}

@riverpod
GetPermissionStatusUseCase getPermissionStatusUseCase(Ref ref) {
  final repository = ref.read(locationRepositoryProvider);
  return GetPermissionStatusUseCase(repository);
}

@riverpod
CreateCheckinAreaCirclesUseCase createCheckinAreaCirclesUseCase(Ref ref) {
  final repository = ref.read(mapRepositoryProvider);
  return CreateCheckinAreaCirclesUseCase(repository);
}

@riverpod
CreateCheckinPointUseCase createCheckinPointUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return CreateCheckinPointUseCase(firebaseService);
}

@riverpod
GetCheckinPointsUseCase getCheckinPointsUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return GetCheckinPointsUseCase(firebaseService);
}

@riverpod
GetActiveCheckinPointUseCase getActiveCheckinPointUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return GetActiveCheckinPointUseCase(firebaseService);
}

@riverpod
CheckInUseCase checkInUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  final locationRepository = ref.read(locationRepositoryProvider);
  return CheckInUseCase(firebaseService, locationRepository);
}

@riverpod
CheckOutUseCase checkOutUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return CheckOutUseCase(firebaseService);
}

@riverpod
GetCurrentCheckinUseCase getCurrentCheckinUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return GetCurrentCheckinUseCase(firebaseService);
}

@riverpod
GetActiveCheckinsUseCase getActiveCheckinsUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return GetActiveCheckinsUseCase(firebaseService);
}

@riverpod
GetActiveCheckinCountStreamUseCase getActiveCheckinCountStreamUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return GetActiveCheckinCountStreamUseCase(firebaseService);
}

@riverpod
UpdateLocationUseCase updateLocationUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return UpdateLocationUseCase(firebaseService);
}

@riverpod
UpdateCheckinPointUseCase updateCheckinPointUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return UpdateCheckinPointUseCase(firebaseService);
}

@riverpod
DeleteCheckinPointUseCase deleteCheckinPointUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return DeleteCheckinPointUseCase(firebaseService);
}

@riverpod
GetAllCheckinPointsWithCreatorsUseCase getAllCheckinPointsWithCreatorsUseCase(Ref ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return GetAllCheckinPointsWithCreatorsUseCase(firebaseService);
}

@riverpod
SignInWithEmailAndPasswordUseCase signInWithEmailAndPasswordUseCase(Ref ref) {
  return SignInWithEmailAndPasswordUseCase(ref.read(authRepositoryProvider));
}

@riverpod
CreateUserWithEmailAndPasswordUseCase createUserWithEmailAndPasswordUseCase(
  Ref ref,
) {
  return CreateUserWithEmailAndPasswordUseCase(
    ref.read(authRepositoryProvider),
  );
}

@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
}
