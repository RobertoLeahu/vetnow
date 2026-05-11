import 'package:equatable/equatable.dart';
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
  final List<Specialty> specialties;

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
    this.specialties = const [],
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
    List<Specialty>? specialties,
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
        specialties: specialties ?? this.specialties,
      );

  bool get isProfileComplete =>
      name.isNotEmpty && address.isNotEmpty && city.isNotEmpty;

  @override
  List<Object?> get props => [id, profileId, name, city, specialties];
}