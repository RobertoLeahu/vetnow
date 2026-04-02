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
  });

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
    id: map['id'] as String,
    clinicId: map['clinic_id'] as String,
    clinicName: (map['clinics'] as Map)['name'] as String,
    clinicAddress: (map['clinics'] as Map)['city'] as String,
    petId: map['pet_id'] as String,
    petName: (map['pets'] as Map)['name'] as String,
    specialtyName: (map['specialties'] as Map)['name'] as String,
    scheduledAt: DateTime.parse(map['scheduled_at']).toLocal(),
    status: map['status'] as String,
  );

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isDone => status == 'done';
  bool get isUpcoming => isPending || isConfirmed;

  @override
  List<Object?> get props => [id, status, scheduledAt];
}
