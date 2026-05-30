import 'package:flutter_test/flutter_test.dart';
import 'package:vetnow/features/appointment/data/appointment_repository.dart';

import '../../../helpers/supabase_mocks.dart';

void main() {
  late FakeSupabaseClient fakeClient;
  late FakeSupabaseQueryBuilder appointmentsTable;
  late AppointmentRepository repo;

  setUp(() {
    fakeClient = FakeSupabaseClient();
    appointmentsTable = fakeClient.table('appointments');
    repo = AppointmentRepository(client: fakeClient);
  });

  group('createAppointment', () {
    test('T-U1 inserta cita con status pending y scheduled_at en UTC', () async {
      final scheduledAt = DateTime(2026, 6, 15, 10, 30);

      await repo.createAppointment(
        clinicId: 'clinic-1',
        petId: 'pet-1',
        ownerId: 'owner-1',
        specialtyId: 'spec-1',
        scheduledAt: scheduledAt,
        durationMinutes: 60,
      );

      final captured = appointmentsTable.capturedInsert!;

      expect(captured['clinic_id'], 'clinic-1');
      expect(captured['pet_id'], 'pet-1');
      expect(captured['owner_id'], 'owner-1');
      expect(captured['specialty_id'], 'spec-1');
      expect(captured['status'], 'pending');
      expect(captured['duration_minutes'], 60);
      expect(captured['notes'], isNull);
      expect(
        captured['scheduled_at'],
        scheduledAt.toUtc().toIso8601String(),
      );
    });

    test('T-U1 persiste notes cuando se proporcionan', () async {
      await repo.createAppointment(
        clinicId: 'clinic-1',
        petId: 'pet-1',
        ownerId: 'owner-1',
        specialtyId: 'spec-1',
        scheduledAt: DateTime(2026, 6, 15, 10, 30),
        durationMinutes: 45,
        notes: 'Primera visita',
      );

      final captured = appointmentsTable.capturedInsert!;

      expect(captured['notes'], 'Primera visita');
      expect(captured['duration_minutes'], 45);
    });
  });

  group('deleteAppointment', () {
    test('T-U2 elimina físicamente la cita sin usar update', () async {
      await repo.deleteAppointment('appt-1');

      expect(appointmentsTable.deleteCalled, isTrue);
      expect(appointmentsTable.builder.eqColumn, 'id');
      expect(appointmentsTable.builder.eqValue, 'appt-1');
      expect(appointmentsTable.updateCalled, isNull);
    });
  });
}
