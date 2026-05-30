import 'package:flutter_test/flutter_test.dart';
import 'package:vetnow/features/clinic_panel/data/medical_notes_repository.dart';

void main() {
  final scheduledAt = DateTime(2026, 6, 15, 10, 0);

  group('PetVisit.canAddNotes', () {
    test('T-U9 pending no permite añadir notas', () {
      final visit = PetVisit(
        appointmentId: 'appt-1',
        scheduledAt: scheduledAt,
        specialtyName: 'General',
        status: 'pending',
      );

      expect(visit.canAddNotes, isFalse);
    });

    test('T-U9 confirmed y done permiten añadir notas', () {
      final confirmed = PetVisit(
        appointmentId: 'appt-1',
        scheduledAt: scheduledAt,
        specialtyName: 'General',
        status: 'confirmed',
      );
      final done = PetVisit(
        appointmentId: 'appt-2',
        scheduledAt: scheduledAt,
        specialtyName: 'General',
        status: 'done',
      );

      expect(confirmed.canAddNotes, isTrue);
      expect(done.canAddNotes, isTrue);
    });
  });
}
