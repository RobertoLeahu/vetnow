import 'package:equatable/equatable.dart';

class MedicalNote extends Equatable {
  final String id;
  final String appointmentId;
  final String clinicId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicalNote({
    required this.id,
    required this.appointmentId,
    required this.clinicId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalNote.fromMap(Map<String, dynamic> map) => MedicalNote(
        id: map['id'] as String,
        appointmentId: map['appointment_id'] as String,
        clinicId: map['clinic_id'] as String,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(map['updated_at'] as String).toLocal(),
      );

  Map<String, dynamic> toMap() => {
        'appointment_id': appointmentId,
        'clinic_id': clinicId,
        'content': content,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props => [id, appointmentId, content, updatedAt];
}
