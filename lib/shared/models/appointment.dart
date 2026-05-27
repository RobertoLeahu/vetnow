import 'package:equatable/equatable.dart';

import '../../core/datetime/timestamptz.dart';
import 'pet.dart';

class Appointment extends Equatable {
  final String id;
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String clinicPhone;
  final String petId;
  final String petName;
  final PetSpecies petSpecies;
  final String? petPhotoUrl;
  final String specialtyName;
  final DateTime scheduledAt;
  final String status;
  final String? ownerFullName;
  final String? ownerId;

  const Appointment({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.clinicAddress,
    required this.clinicPhone,
    required this.petId,
    required this.petName,
    this.petSpecies = PetSpecies.other,
    this.petPhotoUrl,
    required this.specialtyName,
    required this.scheduledAt,
    required this.status,
    this.ownerFullName,
    this.ownerId,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    String? readNestedString(String key, String field) {
      final raw = map[key];
      if (raw is! Map) return null;
      return raw[field] as String?;
    }

    final profilesRaw = map['profiles'];
    String? ownerName;
    if (profilesRaw is Map<String, dynamic>) {
      ownerName = profilesRaw['full_name'] as String?;
    }

    final speciesRaw = readNestedString('pets', 'species');
    final petSpecies = speciesRaw != null
        ? PetSpecies.values.firstWhere(
            (e) => e.name == speciesRaw,
            orElse: () => PetSpecies.other,
          )
        : PetSpecies.other;

    final street = readNestedString('clinics', 'address') ?? '';
    final city = readNestedString('clinics', 'city') ?? '';
    final clinicAddress = street.isNotEmpty && city.isNotEmpty
        ? '$street, $city'
        : (street.isNotEmpty ? street : (city.isNotEmpty ? city : '—'));

    return Appointment(
      id: map['id'] as String,
      clinicId: map['clinic_id'] as String,
      clinicName: readNestedString('clinics', 'name') ?? '—',
      clinicAddress: clinicAddress,
      clinicPhone: readNestedString('clinics', 'phone') ?? '—',
      petId: map['pet_id'] as String,
      petName: readNestedString('pets', 'name') ?? '—',
      petSpecies: petSpecies,
      petPhotoUrl: readNestedString('pets', 'photo_url'),
      specialtyName: readNestedString('specialties', 'name') ?? '—',
      scheduledAt: parseScheduledAtColumn(map['scheduled_at']),
      status: map['status'] as String,
      ownerFullName: ownerName,
      ownerId: map['owner_id'] as String?,
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isDone => status == 'done';
  bool get isUpcoming => isPending || isConfirmed;

  @override
  List<Object?> get props => [id, status, scheduledAt, ownerFullName];
}
