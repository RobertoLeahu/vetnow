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
final myClinicProvider = FutureProvider.autoDispose<Clinic?>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) return null;
  return ref.read(clinicRepositoryProvider).getMyClinic(profile.id);
});

/// Si devuelve `false`, la navegación fuera de Mi clínica debe cancelarse.
typedef ClinicProfileExitHandler = Future<bool> Function();

/// Registrado por [ClinicProfileScreen] para confirmar salida con cambios sin guardar.
final clinicProfileExitHandlerProvider =
    StateProvider<ClinicProfileExitHandler?>((ref) => null);

/// Horarios semanales de la clínica logueada.
final mySchedulesProvider = FutureProvider<List<Schedule>>((ref) async {
  final clinic = await ref.watch(myClinicProvider.future);
  if (clinic == null) return [];
  return ref.watch(clinicRepositoryProvider).fetchSchedules(clinic.id);
});

/// Citas recibidas por la clínica del usuario logueado (agenda).
final clinicAppointmentsProvider =
    FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final clinic = await ref.watch(myClinicProvider.future);
  if (clinic == null) return [];
  final raw = await ref
      .watch(appointmentRepositoryProvider)
      .fetchClinicAppointments(clinic.id);
  final list = raw.map((e) => Appointment.fromMap(e)).toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return list;
});

List<Appointment> filterTodayClinicAppointments(List<Appointment> all) {
  final now = DateTime.now();
  return all.where((a) {
    final local = a.scheduledAt.toLocal();
    return a.isConfirmed &&
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }).toList();
}

List<Appointment> filterTodayConfirmedClinicAppointments(List<Appointment> all) {
  final now = DateTime.now();
  return all.where((a) {
    final local = a.scheduledAt.toLocal();
    return a.isConfirmed &&
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }).toList();
}

/// Citas confirmadas de hoy para la tarjeta principal del dashboard.
final todayClinicAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final all = ref.watch(clinicAppointmentsProvider).valueOrNull ?? [];
  return filterTodayClinicAppointments(all);
});

/// Citas confirmadas de hoy para el carrusel de pacientes.
final todayConfirmedClinicAppointmentsProvider =
    Provider<List<Appointment>>((ref) {
  final all = ref.watch(clinicAppointmentsProvider).valueOrNull ?? [];
  return filterTodayConfirmedClinicAppointments(all);
});

DateTime _dateOnlyLocal(DateTime dt) {
  final l = dt.toLocal();
  return DateTime(l.year, l.month, l.day);
}

bool _isInCurrentWeek(DateTime scheduledAt) {
  final d = _dateOnlyLocal(scheduledAt);
  final today = _dateOnlyLocal(DateTime.now());
  final monday = today.subtract(Duration(days: today.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  return !d.isBefore(monday) && !d.isAfter(sunday);
}

/// Fecha local en que se completó la cita (o programada si no hay `completed_at`).
DateTime _completedLocalDate(Appointment a) =>
    _dateOnlyLocal(a.completedAt ?? a.scheduledAt);

/// Métricas de citas para el resumen del dashboard (hoy + semana actual).
class ClinicAppointmentStats {
  final int todayScheduled;
  final int todayConfirmed;
  final int todayPending;
  final int todayDone;
  final int todayCancelled;
  final int weekScheduled;
  final int weekConfirmed;
  final int weekPending;
  final int weekDone;
  final int weekCancelled;
  final int pendingConfirmTotal;
  final int uniquePatientsToday;

  const ClinicAppointmentStats({
    this.todayScheduled = 0,
    this.todayConfirmed = 0,
    this.todayPending = 0,
    this.todayDone = 0,
    this.todayCancelled = 0,
    this.weekScheduled = 0,
    this.weekConfirmed = 0,
    this.weekPending = 0,
    this.weekDone = 0,
    this.weekCancelled = 0,
    this.pendingConfirmTotal = 0,
    this.uniquePatientsToday = 0,
  });
}

ClinicAppointmentStats computeClinicAppointmentStats(List<Appointment> all) {
  final now = DateTime.now();
  final today = _dateOnlyLocal(now);

  var todayScheduled = 0;
  var todayConfirmed = 0;
  var todayPending = 0;
  var todayDone = 0;
  var todayCancelled = 0;
  var weekScheduled = 0;
  var weekConfirmed = 0;
  var weekPending = 0;
  var weekDone = 0;
  var weekCancelled = 0;
  var pendingConfirmTotal = 0;
  final patientsToday = <String>{};

  for (final a in all) {
    final day = _dateOnlyLocal(a.scheduledAt);
    final isToday = day == today;
    final isWeek = _isInCurrentWeek(a.scheduledAt);

    if (a.isPending) pendingConfirmTotal++;

    if (a.isDone && _completedLocalDate(a) == today) {
      todayDone++;
    }

    if (isToday) {
      if (a.isCancelled) {
        todayCancelled++;
      } else if (a.isConfirmed) {
        todayConfirmed++;
        todayScheduled++;
        patientsToday.add(a.petId);
      } else if (a.isPending) {
        todayPending++;
        todayScheduled++;
      }
    }

    if (isWeek) {
      if (a.isCancelled) {
        weekCancelled++;
      } else if (a.isDone) {
        weekDone++;
      } else if (a.isConfirmed) {
        weekConfirmed++;
        weekScheduled++;
      } else if (a.isPending) {
        weekPending++;
        weekScheduled++;
      }
    }
  }

  return ClinicAppointmentStats(
    todayScheduled: todayScheduled,
    todayConfirmed: todayConfirmed,
    todayPending: todayPending,
    todayDone: todayDone,
    todayCancelled: todayCancelled,
    weekScheduled: weekScheduled,
    weekConfirmed: weekConfirmed,
    weekPending: weekPending,
    weekDone: weekDone,
    weekCancelled: weekCancelled,
    pendingConfirmTotal: pendingConfirmTotal,
    uniquePatientsToday: patientsToday.length,
  );
}

final clinicAppointmentStatsProvider = Provider<ClinicAppointmentStats>((ref) {
  final all = ref.watch(clinicAppointmentsProvider).valueOrNull ?? [];
  return computeClinicAppointmentStats(all);
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

/// Citas de [petId] en la clínica logueada (excepto canceladas), con notas clínicas.
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

