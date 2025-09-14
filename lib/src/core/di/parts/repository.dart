part of '../dependency_injection.dart';

@riverpod
LocationRepository locationRepository(Ref ref) {
  return LocationRepositoryImpl(
    locationService: ref.read(locationServiceProvider),
  );
}

@riverpod
MapRepository mapRepository(Ref ref) {
  return MapRepositoryImpl();
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.read(firebaseServiceProvider));
}
