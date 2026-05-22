import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/appointment_repository.dart';
import '../utils/slot_generator.dart';
import '../../../shared/models/appointment.dart';
import '../../../features/auth/providers/auth_provider.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (_) => AppointmentRepository(),
);

/// Filtro de mascota seleccionado en pantalla de citas (null = todas)
final selectedPetFilterProvider = StateProvider<String?>((_) => null);

/// Citas del usuario actual
final myAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value.session?.user;
  if (user == null) return [];
  final raw = await ref
      .watch(appointmentRepositoryProvider)
      .fetchMyAppointments(user.id);
  return raw.map((e) => Appointment.fromMap(e)).toList();
});

/// Slots ocupados para una clínica y fecha
final bookedSlotsProvider =
    FutureProvider.family<List<BookedSlot>, ({String clinicId, DateTime date})>((
      ref,
      params,
    ) async {
      return ref
          .watch(appointmentRepositoryProvider)
          .fetchBookedSlots(params.clinicId, params.date);
    });
