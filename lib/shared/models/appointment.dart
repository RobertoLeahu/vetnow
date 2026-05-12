import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String petId;
  final String petName;
  final String specialtyName;
  final DateTime scheduledAt;
  final String status;
  final String? ownerFullName;

  const Appointment({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.clinicAddress,
    required this.petId,
    required this.petName,
    required this.specialtyName,
    required this.scheduledAt,
    required this.status,
    this.ownerFullName,
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

    return Appointment(
      id: map['id'] as String,
      clinicId: map['clinic_id'] as String,
      clinicName: readNestedString('clinics', 'name') ?? '—',
      clinicAddress: readNestedString('clinics', 'city') ?? '—',
      petId: map['pet_id'] as String,
      petName: readNestedString('pets', 'name') ?? '—',
      specialtyName: readNestedString('specialties', 'name') ?? '—',
      scheduledAt: DateTime.parse(map['scheduled_at'] as String).toLocal(),
      status: map['status'] as String,
      ownerFullName: ownerName,
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
