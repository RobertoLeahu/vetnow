import '../../../core/datetime/timestamptz.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/pet.dart';

class AppointmentRepository {
  /// Obtener mascotas del propietario actual
  Future<List<Pet>> fetchMyPets(String ownerId) async {
    final data = await supabase
        .from('pets')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at');
    return (data as List).map((e) => Pet.fromMap(e)).toList();
  }

  /// Añadir mascota (devuelve el id insertado).
  Future<String> addPet(Pet pet) async {
    final row = await supabase.from('pets').insert(pet.toMap()).select('id').single();
    return row['id'] as String;
  }

  /// Obtener slots ocupados de una clínica en una fecha.
  /// Usa RPC con SECURITY DEFINER para bypasear RLS y ver slots de todos los
  /// usuarios, devolviendo únicamente scheduled_at (sin datos personales).
  Future<List<DateTime>> fetchBookedSlots(
    String clinicId,
    DateTime date,
  ) async {
    // UTC midnight del día local → cubre el día completo en hora local.
    final from = DateTime(date.year, date.month, date.day).toUtc();
    final to = from.add(const Duration(days: 1));

    final data = await supabase.rpc('get_booked_slots', params: {
      'p_clinic_id': clinicId,
      'p_from': from.toIso8601String(),
      'p_to': to.toIso8601String(),
    });

    return (data as List)
        .map((e) => parseScheduledAtColumn(e['scheduled_at']))
        .toList();
  }

  /// Crear cita
  Future<void> createAppointment({
    required String clinicId,
    required String petId,
    required String ownerId,
    required String specialtyId,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    await supabase.from('appointments').insert({
      'clinic_id': clinicId,
      'pet_id': petId,
      'owner_id': ownerId,
      'specialty_id': specialtyId,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'status': 'pending',
      'notes': notes,
    });
  }

  /// Obtener citas del propietario
  Future<List<Map<String, dynamic>>> fetchMyAppointments(String ownerId) async {
    final data = await supabase
        .from('appointments')
        .select('''
          *,
          clinics(name, address, city, phone),
          pets(name, species),
          specialties(name)
        ''')
        .eq('owner_id', ownerId)
        .order('scheduled_at');
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Citas recibidas por una clínica (panel agenda), con nombre del propietario.
  Future<List<Map<String, dynamic>>> fetchClinicAppointments(
    String clinicId,
  ) async {
    final data = await supabase
        .from('appointments')
        .select('''
          *,
          clinics(name, address, city, phone),
          pets(name, species, photo_url),
          specialties(name),
          profiles(full_name)
        ''')
        .eq('clinic_id', clinicId)
        .order('scheduled_at', ascending: true);
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Confirmar cita (pendiente → confirmada). RLS: solo la clínica dueña.
  Future<void> confirmAppointment(String appointmentId) async {
    await supabase
        .from('appointments')
        .update({'status': 'confirmed'})
        .eq('id', appointmentId)
        .eq('status', 'pending');
  }

  /// Marcar cita como realizada (confirmada → realizada). RLS: solo la clínica dueña.
  Future<void> markAppointmentDone(String appointmentId) async {
    await supabase
        .from('appointments')
        .update({'status': 'done'})
        .eq('id', appointmentId)
        .eq('status', 'confirmed');
  }

  /// La clínica deniega una cita pendiente (pasa a cancelada).
  Future<void> rejectAppointmentByClinic(String appointmentId) async {
    await supabase
        .from('appointments')
        .update({'status': 'cancelled'})
        .eq('id', appointmentId)
        .eq('status', 'pending');
  }

  /// Cancelar cita
  Future<void> cancelAppointment(String appointmentId) async {
    await supabase
        .from('appointments')
        .update({'status': 'cancelled'})
        .eq('id', appointmentId);
  }

  /// Eliminar cita (solo debe usarse para citas canceladas; RLS en Supabase).
  Future<void> deleteAppointment(String appointmentId) async {
    await supabase.from('appointments').delete().eq('id', appointmentId);
  }
}
