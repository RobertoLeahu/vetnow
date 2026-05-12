import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/medical_note.dart';
import '../../../shared/models/pet.dart';

/// Value object representing a unique patient (owner) of a clinic.
class ClinicPatient {
  final String ownerId;
  final String fullName;

  const ClinicPatient({required this.ownerId, required this.fullName});
}

/// Value object pairing a completed appointment with its optional clinical note.
class PetVisit {
  final String appointmentId;
  final DateTime scheduledAt;
  final String specialtyName;
  final MedicalNote? note;

  const PetVisit({
    required this.appointmentId,
    required this.scheduledAt,
    required this.specialtyName,
    this.note,
  });
}

class MedicalNotesRepository {
  /// Unique owners who have had at least one appointment at this clinic.
  Future<List<ClinicPatient>> fetchClinicPatients(String clinicId) async {
    final data = await supabase
        .from('appointments')
        .select('owner_id, profiles(full_name)')
        .eq('clinic_id', clinicId)
        .order('owner_id');

    final seen = <String>{};
    final patients = <ClinicPatient>[];

    for (final row in data as List) {
      final ownerId = row['owner_id'] as String;
      if (seen.contains(ownerId)) continue;
      seen.add(ownerId);

      final profilesRaw = row['profiles'];
      final fullName = (profilesRaw is Map ? profilesRaw['full_name'] : null)
              as String? ??
          '—';

      patients.add(ClinicPatient(ownerId: ownerId, fullName: fullName));
    }

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

  /// Completed visits for [petId] at [clinicId], newest first.
  Future<List<PetVisit>> fetchPetVisits(
    String clinicId,
    String petId,
  ) async {
    final data = await supabase
        .from('appointments')
        .select('''
          id,
          scheduled_at,
          specialties(name),
          medical_notes(id, appointment_id, clinic_id, content, created_at, updated_at)
        ''')
        .eq('clinic_id', clinicId)
        .eq('pet_id', petId)
        .eq('status', 'done')
        .order('scheduled_at', ascending: false);

    return (data as List).map((row) {
      final specialtiesRaw = row['specialties'];
      final specialtyName =
          (specialtiesRaw is Map ? specialtiesRaw['name'] : null) as String? ??
              '—';

      MedicalNote? note;
      final notesRaw = row['medical_notes'];
      if (notesRaw is Map<String, dynamic>) {
        note = MedicalNote.fromMap(notesRaw);
      } else if (notesRaw is List && notesRaw.isNotEmpty) {
        note = MedicalNote.fromMap(
          Map<String, dynamic>.from(notesRaw.first as Map),
        );
      }

      return PetVisit(
        appointmentId: row['id'] as String,
        scheduledAt:
            DateTime.parse(row['scheduled_at'] as String).toLocal(),
        specialtyName: specialtyName,
        note: note,
      );
    }).toList();
  }

  /// Creates or updates the clinical note for [appointmentId].
  Future<void> upsertNote({
    required String appointmentId,
    required String clinicId,
    required String content,
  }) async {
    await supabase.from('medical_notes').upsert(
      {
        'appointment_id': appointmentId,
        'clinic_id': clinicId,
        'content': content,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'appointment_id',
    );
  }
}
