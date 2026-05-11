import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final String? id;
  final String clinicId;
  final int dayOfWeek; // 0 = lunes … 6 = domingo
  final String openTime; // "HH:mm:ss"
  final String closeTime;

  const Schedule({
    this.id,
    required this.clinicId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
        id: map['id'] as String?,
        clinicId: map['clinic_id'] as String,
        dayOfWeek: map['day_of_week'] as int,
        openTime: map['open_time'] as String,
        closeTime: map['close_time'] as String,
      );

  Map<String, dynamic> toMap() => {
        'clinic_id': clinicId,
        'day_of_week': dayOfWeek,
        'open_time': openTime,
        'close_time': closeTime,
      };

  static const dayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  List<Object?> get props => [id, clinicId, dayOfWeek, openTime, closeTime];
}
