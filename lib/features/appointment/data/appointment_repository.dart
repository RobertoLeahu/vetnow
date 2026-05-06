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

  /// Obtener slots ocupados de una clínica en una fecha
  Future<List<DateTime>> fetchBookedSlots(
    String clinicId,
    DateTime date,
  ) async {
    final from = DateTime(date.year, date.month, date.day);
    final to = from.add(const Duration(days: 1));

    final data = await supabase
        .from('appointments')
        .select('scheduled_at')
        .eq('clinic_id', clinicId)
        .gte('scheduled_at', from.toIso8601String())
        .lt('scheduled_at', to.toIso8601String())
        .inFilter('status', ['pending', 'confirmed']);

    return (data as List)
        .map((e) => DateTime.parse(e['scheduled_at'] as String).toLocal())
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

  /// Cancelar cita
  Future<void> cancelAppointment(String appointmentId) async {
    await supabase
        .from('appointments')
        .update({'status': 'cancelled'})
        .eq('id', appointmentId);
  }
}
