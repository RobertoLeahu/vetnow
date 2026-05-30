import 'package:flutter_test/flutter_test.dart';
import 'package:vetnow/features/clinic_panel/data/medical_notes_repository.dart';

import '../../../helpers/supabase_mocks.dart';

void main() {
  late FakeSupabaseClient fakeClient;
  late FakeSupabaseQueryBuilder appointmentsTable;
  late FakeSupabaseQueryBuilder notesTable;
  late MedicalNotesRepository repo;

  const appointmentId = 'appt-1';
  const clinicId = 'clinic-1';

  setUp(() {
    fakeClient = FakeSupabaseClient();
    appointmentsTable = fakeClient.table('appointments');
    notesTable = fakeClient.table('medical_notes');
    repo = MedicalNotesRepository(client: fakeClient);
  });

  group('addNote', () {
    test('T-U5 lanza StateError si la cita está pending', () async {
      appointmentsTable.builder.result = {'status': 'pending'};

      await expectLater(
        repo.addNote(
          appointmentId: appointmentId,
          clinicId: clinicId,
          content: 'Nota clínica',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Confirma la cita'),
          ),
        ),
      );

      expect(notesTable.capturedInsert, isNull);
    });

    test('inserta nota cuando la cita está confirmed', () async {
      appointmentsTable.builder.result = {'status': 'confirmed'};

      await repo.addNote(
        appointmentId: appointmentId,
        clinicId: clinicId,
        content: 'Nota clínica',
      );

      final captured = notesTable.capturedInsert!;

      expect(captured['appointment_id'], appointmentId);
      expect(captured['clinic_id'], clinicId);
      expect(captured['content'], 'Nota clínica');
    });
  });
}
