import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/location/user_location_service.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../shared/models/clinic.dart';

class ClinicMapScreen extends StatefulWidget {
  final String clinicName;
  final double clinicLat;
  final double clinicLng;

  const ClinicMapScreen({
    super.key,
    required this.clinicName,
    required this.clinicLat,
    required this.clinicLng,
  });

  @override
  State<ClinicMapScreen> createState() => _ClinicMapScreenState();
}

class _ClinicMapScreenState extends State<ClinicMapScreen> {
  final _mapCtrl = MapController();
  bool _locatingUser = true;
  bool _userLocationUnavailable = false;
  UserLocationFailure? _locationFailure;
  double? _userLat;
  double? _userLng;

  static final _mapCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: AppTheme.divider)),
    boxShadow: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 10,
        offset: Offset(0, 3),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveUserLocation();
    });
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  Future<void> _resolveUserLocation() async {
    if (!mounted) return;
    setState(() {
      _locatingUser = true;
      _userLocationUnavailable = false;
      _locationFailure = null;
    });

    final result = await resolveUserLocation();

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _locatingUser = false;
        _userLocationUnavailable = false;
        _userLat = result.lat;
        _userLng = result.lng;
      });
      _scheduleFitCamera();
      if (result.fromCache) {
        _refineUserLocationInBackground();
      }
    } else {
      setState(() {
        _locatingUser = false;
        _userLocationUnavailable = true;
        _locationFailure = result.failure;
        _userLat = null;
        _userLng = null;
      });
      _scheduleFitCamera();
    }
  }

  /// Si la primera respuesta fue caché, intenta una posición GPS más precisa sin
  /// bloquear la UI.
  Future<void> _refineUserLocationInBackground() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 12),
      );
      if (!mounted) return;
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
        _userLocationUnavailable = false;
      });
      _scheduleFitCamera();
    } catch (_) {
      // Mantener caché o estado actual.
    }
  }

  void _scheduleFitCamera() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapCamera();
    });
  }

  double? get _distanceKm {
    if (_userLat == null || _userLng == null) return null;
    return haversineKm(
      lat1: _userLat!,
      lng1: _userLng!,
      lat2: widget.clinicLat,
      lng2: widget.clinicLng,
    );
  }

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  void _fitMapCamera() {
    final clinicPoint = LatLng(widget.clinicLat, widget.clinicLng);

    if (_userLat != null && _userLng != null) {
      final userPoint = LatLng(_userLat!, _userLng!);
      _mapCtrl.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints([userPoint, clinicPoint]),
          padding: const EdgeInsets.all(56),
        ),
      );
    } else {
      _mapCtrl.move(clinicPoint, 14);
    }
  }

  Future<void> _showLocationDeniedDialog({
    required String title,
    required String message,
    required Future<bool> Function() openSettings,
  }) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _onRetryLocation() async {
    final failure = _locationFailure;
    if (failure == UserLocationFailure.serviceDisabled) {
      await _showLocationDeniedDialog(
        title: context.l10n.locationDisabledTitle,
        message: context.l10n.locationDisabledMessage,
        openSettings: Geolocator.openLocationSettings,
      );
      return;
    }
    if (failure == UserLocationFailure.permissionDenied) {
      await _showLocationDeniedDialog(
        title: context.l10n.locationPermissionTitle,
        message: context.l10n.locationPermissionMessage,
        openSettings: Geolocator.openAppSettings,
      );
      return;
    }
    await _resolveUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final clinicPoint = LatLng(widget.clinicLat, widget.clinicLng);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clinicMapTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_userLocationUnavailable)
            Material(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.clinicMapUserUnavailable,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _locatingUser ? null : _onRetryLocation,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Stack(
                children: [
                  Container(
                    decoration: _mapCardDecoration,
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      mapController: _mapCtrl,
                      options: MapOptions(
                        initialCenter: clinicPoint,
                        initialZoom: 14,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.robertoleahu.vetnow',
                        ),
                        MarkerLayer(
                          markers: [
                            if (_userLat != null && _userLng != null)
                              Marker(
                                point: LatLng(_userLat!, _userLng!),
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.my_location_rounded,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            Marker(
                              point: clinicPoint,
                              width: 44,
                              height: 44,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.local_hospital_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_locatingUser)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(50),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.locatingUser,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_userLat != null && _userLng != null && !_locatingUser)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: FloatingActionButton.small(
                        heroTag: 'clinic_map_center_user',
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        onPressed: _fitMapCamera,
                        child: const Icon(Icons.my_location_rounded),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                Text(
                  widget.clinicName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (_distanceKm != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me_rounded,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDistance(_distanceKm!),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
