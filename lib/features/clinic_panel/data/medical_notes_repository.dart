import '../../../core/datetime/timestamptz.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/medical_note.dart';
import '../../../shared/models/pet.dart';

/// Value object representing a unique patient (owner) of a clinic.
class ClinicPatient {
  final String ownerId;
  final String fullName;
  /// Most recent appointment at this clinic (any status).
  final DateTime lastAppointmentAt;

  const ClinicPatient({
    required this.ownerId,
    required this.fullName,
    required this.lastAppointmentAt,
  });
}

/// Value object pairing an appointment with its clinical notes.
class PetVisit {
  final String appointmentId;
  final DateTime scheduledAt;
  final String specialtyName;
  /// pending | confirmed | done | cancelled
  final String status;
  final List<MedicalNote> notes;

  const PetVisit({
    required this.appointmentId,
    required this.scheduledAt,
    required this.specialtyName,
    required this.status,
    this.notes = const [],
  });

  bool get isDone => status == 'done';
  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'pending';

  /// Solo tras confirmar la cita (o si ya está realizada).
  bool get canAddNotes => status == 'confirmed' || status == 'done';
}

class MedicalNotesRepository {
  /// Unique owners who have had at least one appointment at this clinic.
  Future<List<ClinicPatient>> fetchClinicPatients(String clinicId) async {
    final data = await supabase
        .from('appointments')
        .select('owner_id, scheduled_at, profiles(full_name)')
        .eq('clinic_id', clinicId);

    final byOwner = <String, ({String fullName, DateTime lastAt})>{};

    for (final row in data as List) {
      final ownerId = row['owner_id'] as String;
      final scheduledAt =
          parseTimestamptzToLocal(row['scheduled_at'] as String);
      final profilesRaw = row['profiles'];
      final fullName = (profilesRaw is Map ? profilesRaw['full_name'] : null)
              as String? ??
          '—';

      final existing = byOwner[ownerId];
      if (existing == null) {
        byOwner[ownerId] = (fullName: fullName, lastAt: scheduledAt);
      } else if (scheduledAt.isAfter(existing.lastAt)) {
        byOwner[ownerId] = (fullName: existing.fullName, lastAt: scheduledAt);
      }
    }

    final patients = byOwner.entries
        .map(
          (e) => ClinicPatient(
            ownerId: e.key,
            fullName: e.value.fullName,
            lastAppointmentAt: e.value.lastAt,
          ),
        )
        .toList();

    patients.sort((a, b) => a.fullName.compareTo(b.fullName));
    return patients;
  }

  /// Pets belonging to [ownerId] that have visited [clinicId] at least once.
  Future<List<Pet>> fetchOwnerPetsForClinic(
    String clinicId,
    String ownerId,
  ) async {
    final data = await supabase
        .from('appointments')
        .select('pet_id, pets(id, owner_id, name, species, breed, birth_date, photo_url)')
        .eq('clinic_id', clinicId)
        .eq('owner_id', ownerId)
        .order('pet_id');

    final seen = <String>{};
    final pets = <Pet>[];

    for (final row in data as List) {
      final petId = row['pet_id'] as String;
      if (seen.contains(petId)) continue;
      seen.add(petId);

      final petsRaw = row['pets'];
      if (petsRaw is Map<String, dynamic>) {
        pets.add(Pet.fromMap(petsRaw));
      }
    }

    pets.sort((a, b) => a.name.compareTo(b.name));
    return pets;
  }

  /// Citas de [petId] en [clinicId] (excepto canceladas), con notas. Más recientes primero.
  Future<List<PetVisit>> fetchPetVisits(
    String clinicId,
    String petId,
  ) async {
    final data = await supabase
        .from('appointments')
        .select('''
          id,
          scheduled_at,
          status,
          specialties(name),
          medical_notes(id, appointment_id, clinic_id, content, created_at, updated_at)
        ''')
        .eq('clinic_id', clinicId)
        .eq('pet_id', petId)
        .neq('status', 'cancelled')
        .order('scheduled_at', ascending: false);

    return (data as List).map((row) {
      final specialtiesRaw = row['specialties'];
      final specialtyName =
          (specialtiesRaw is Map ? specialtiesRaw['name'] : null) as String? ??
              '—';

      final notesRaw = row['medical_notes'];
      final notes = <MedicalNote>[];
      if (notesRaw is List) {
        for (final item in notesRaw) {
          if (item is Map<String, dynamic>) {
            notes.add(MedicalNote.fromMap(item));
          } else if (item is Map) {
            notes.add(MedicalNote.fromMap(Map<String, dynamic>.from(item)));
          }
        }
        notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else if (notesRaw is Map<String, dynamic>) {
        notes.add(MedicalNote.fromMap(notesRaw));
      }

      return PetVisit(
        appointmentId: row['id'] as String,
        scheduledAt:
            parseTimestamptzToLocal(row['scheduled_at'] as String),
        specialtyName: specialtyName,
        status: row['status'] as String,
        notes: notes,
      );
    }).toList();
  }

  Future<void> _assertAppointmentAllowsNotes(String appointmentId) async {
    final row = await supabase
        .from('appointments')
        .select('status')
        .eq('id', appointmentId)
        .single();
    final status = row['status'] as String;
    if (status == 'pending') {
      throw StateError(
        'Confirma la cita en la agenda para poder gestionar notas.',
      );
    }
  }

  /// Añade una nueva nota clínica para la visita [appointmentId].
  Future<void> addNote({
    required String appointmentId,
    required String clinicId,
    required String content,
  }) async {
    await _assertAppointmentAllowsNotes(appointmentId);
    await supabase.from('medical_notes').insert({
      'appointment_id': appointmentId,
      'clinic_id': clinicId,
      'content': content,
    });
  }

  /// Actualiza el texto de una nota existente (solo la clínica dueña vía RLS).
  Future<void> updateNote({
    required String noteId,
    required String content,
  }) async {
    final row = await supabase
        .from('medical_notes')
        .select('appointment_id')
        .eq('id', noteId)
        .single();
    await _assertAppointmentAllowsNotes(row['appointment_id'] as String);
    await supabase.from('medical_notes').update({
      'content': content,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', noteId);
  }

  /// Elimina una nota clínica (solo la clínica dueña vía RLS).
  Future<void> deleteNote(String noteId) async {
    final row = await supabase
        .from('medical_notes')
        .select('appointment_id')
        .eq('id', noteId)
        .single();
    await _assertAppointmentAllowsNotes(row['appointment_id'] as String);
    await supabase.from('medical_notes').delete().eq('id', noteId);
  }
}
