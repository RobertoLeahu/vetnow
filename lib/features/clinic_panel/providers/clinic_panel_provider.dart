import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../clinic/providers/clinic_provider.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/schedule.dart';

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
