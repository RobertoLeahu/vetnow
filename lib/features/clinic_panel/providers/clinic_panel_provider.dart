import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../appointment/providers/appointment_provider.dart';
import '../../clinic/providers/clinic_provider.dart';
import '../../../shared/models/appointment.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/pet.dart';
import '../../../shared/models/schedule.dart';
import '../data/medical_notes_repository.dart';

/// Clínica del usuario logueado (null si no existe fila en `clinics`).
final myClinicProvider = FutureProvider<Clinic?>((ref) async {
  final profile = ref.watch(profileProvider).valueOrNull;
  if (profile == null) return null;
  return ref.watch(clinicRepositoryProvider).getMyClinic(profile.id);
});

/// Horarios semanales de la clínica logueada.
final mySchedulesProvider = FutureProvider<List<Schedule>>((ref) async {
  final clinic = await ref.watch(myClinicProvider.future);
  if (clinic == null) return [];
  return ref.watch(clinicRepositoryProvider).fetchSchedules(clinic.id);
});

/// Citas recibidas por la clínica del usuario logueado (agenda).
final clinicAppointmentsProvider =
    FutureProvider<List<Appointment>>((ref) async {
  final clinic = await ref.watch(myClinicProvider.future);
  if (clinic == null) return [];
  final raw = await ref
      .watch(appointmentRepositoryProvider)
      .fetchClinicAppointments(clinic.id);
  final list = raw.map((e) => Appointment.fromMap(e)).toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return list;
});

// ── Expedientes médicos ───────────────────────────────────────────────────────

final medicalNotesRepositoryProvider = Provider<MedicalNotesRepository>(
  (_) => MedicalNotesRepository(),
);

/// Propietarios únicos con al menos una cita en la clínica logueada.
final clinicPatientsProvider =
    FutureProvider<List<ClinicPatient>>((ref) async {
  final clinic = await ref.watch(myClinicProvider.future);
  if (clinic == null) return [];
  return ref
      .watch(medicalNotesRepositoryProvider)
      .fetchClinicPatients(clinic.id);
});

/// Mascotas de [ownerId] que han visitado la clínica logueada.
/// autoDispose: datos frescos cada vez que se abre la pantalla.
final ownerPetsForClinicProvider =
    FutureProvider.autoDispose.family<List<Pet>, String>((ref, ownerId) async {
  final clinic = await ref.watch(myClinicProvider.future);
  if (clinic == null) return [];
  return ref
      .watch(medicalNotesRepositoryProvider)
      .fetchOwnerPetsForClinic(clinic.id, ownerId);
});

/// Visitas realizadas de [petId] en la clínica logueada, con notas clínicas.
/// autoDispose: datos frescos cada vez que se abre la pantalla.
final petVisitsProvider =
    FutureProvider.autoDispose.family<List<PetVisit>, String>(
        (ref, petId) async {
  final clinic = await ref.watch(myClinicProvider.future);
  if (clinic == null) return [];
  return ref
      .watch(medicalNotesRepositoryProvider)
      .fetchPetVisits(clinic.id, petId);
});

/// Citas de hoy (pending o confirmed) de la clínica logueada.
final todayClinicAppointmentsProvider =
    FutureProvider<List<Appointment>>((ref) async {
  final all = await ref.watch(clinicAppointmentsProvider.future);
  final now = DateTime.now();
  return all.where((a) {
    final local = a.scheduledAt.toLocal();
    return a.isUpcoming &&
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }).toList();
});
