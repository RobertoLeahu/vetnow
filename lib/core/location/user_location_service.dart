import 'package:geolocator/geolocator.dart';

enum UserLocationFailure {
  serviceDisabled,
  permissionDenied,
  unavailable,
}

class UserLocationResult {
  final double? lat;
  final double? lng;
  final UserLocationFailure? failure;
  final bool fromCache;

  const UserLocationResult._({
    this.lat,
    this.lng,
    this.failure,
    this.fromCache = false,
  });

  bool get isSuccess => lat != null && lng != null;

  factory UserLocationResult.success(
    double lat,
    double lng, {
    bool fromCache = false,
  }) =>
      UserLocationResult._(lat: lat, lng: lng, fromCache: fromCache);

  factory UserLocationResult.failure(UserLocationFailure failure) =>
      UserLocationResult._(failure: failure);
}

/// Obtiene la ubicación del usuario de forma rápida y tolerante a fallos.
///
/// 1. Comprueba servicio y permisos.
/// 2. Usa [Geolocator.getLastKnownPosition] si es reciente (hasta 15 min).
/// 3. Refina con [Geolocator.getCurrentPosition] en segundo plano (baja precisión,
///    timeout corto) si hace falta.
Future<UserLocationResult> resolveUserLocation({
  bool requestPermissionIfDenied = true,
  Duration maxCacheAge = const Duration(minutes: 15),
  Duration gpsTimeout = const Duration(seconds: 8),
}) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return UserLocationResult.failure(UserLocationFailure.serviceDisabled);
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied && requestPermissionIfDenied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return UserLocationResult.failure(UserLocationFailure.permissionDenied);
  }

  Position? cached;
  try {
    cached = await Geolocator.getLastKnownPosition();
  } catch (_) {
    cached = null;
  }

  if (cached != null) {
    final age = DateTime.now().difference(cached.timestamp);
    if (!age.isNegative && age <= maxCacheAge) {
      return UserLocationResult.success(
        cached.latitude,
        cached.longitude,
        fromCache: true,
      );
    }
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: gpsTimeout,
    );
    return UserLocationResult.success(position.latitude, position.longitude);
  } catch (_) {
    if (cached != null) {
      return UserLocationResult.success(
        cached.latitude,
        cached.longitude,
        fromCache: true,
      );
    }
    return UserLocationResult.failure(UserLocationFailure.unavailable);
  }
}
