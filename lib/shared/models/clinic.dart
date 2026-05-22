import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../appointment_duration.dart';
import 'specialty.dart';

class Clinic extends Equatable {
  final String id;
  final String profileId;
  final String name;
  final String? description;
  final String address;
  final String city;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final int appointmentDurationMinutes;
  final List<Specialty> specialties;

  /// Distancia en kilómetros desde la posición del usuario hasta la clínica.
  /// No se persiste en BD: se calcula en cliente al realizar una búsqueda
  /// por proximidad (Haversine).
  final double? distanceKm;

  const Clinic({
    required this.id,
    required this.profileId,
    required this.name,
    this.description,
    required this.address,
    required this.city,
    this.lat,
    this.lng,
    this.phone,
    this.email,
    this.logoUrl,
    this.appointmentDurationMinutes = kDefaultAppointmentDurationMinutes,
    this.specialties = const [],
    this.distanceKm,
  });

  factory Clinic.fromMap(Map<String, dynamic> map) {
    final rawSpecialties = map['clinic_specialties'] as List<dynamic>? ?? [];

    return Clinic(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      address: map['address'] as String,
      city: map['city'] as String,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      logoUrl: map['logo_url'] as String?,
      appointmentDurationMinutes:
          (map['appointment_duration_minutes'] as num?)?.toInt() ??
              kDefaultAppointmentDurationMinutes,
      specialties: rawSpecialties
          .map((e) => Specialty.fromMap(e['specialties'] as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'profile_id': profileId,
        'name': name,
        'description': description,
        'address': address,
        'city': city,
        'lat': lat,
        'lng': lng,
        'phone': phone,
        'email': email,
        'logo_url': logoUrl,
        'appointment_duration_minutes': appointmentDurationMinutes,
      };

  Clinic copyWith({
    String? id,
    String? profileId,
    String? name,
    String? description,
    String? address,
    String? city,
    double? lat,
    double? lng,
    String? phone,
    String? email,
    String? logoUrl,
    int? appointmentDurationMinutes,
    List<Specialty>? specialties,
    double? distanceKm,
  }) =>
      Clinic(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
        description: description ?? this.description,
        address: address ?? this.address,
        city: city ?? this.city,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        logoUrl: logoUrl ?? this.logoUrl,
        appointmentDurationMinutes:
            appointmentDurationMinutes ?? this.appointmentDurationMinutes,
        specialties: specialties ?? this.specialties,
        distanceKm: distanceKm ?? this.distanceKm,
      );

  bool get isProfileComplete =>
      name.isNotEmpty && address.isNotEmpty && city.isNotEmpty;

  @override
  List<Object?> get props => [id, profileId, name, city, specialties];
}

/// Calcula la distancia en kilómetros entre dos pares de coordenadas
/// geográficas usando la fórmula Haversine.
double haversineKm({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLng = _degToRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degToRad(lat1)) *
          math.cos(_degToRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degToRad(double deg) => deg * (math.pi / 180.0);