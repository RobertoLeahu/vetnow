import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/pet.dart';

class PetRepository {
  Future<List<Pet>> fetchMyPets(String ownerId) async {
    final data = await supabase.from('pets').select().eq('owner_id', ownerId);
    return (data as List).map((e) => Pet.fromMap(e)).toList();
  }

  Future<void> addPet(Pet pet) async {
    await supabase.from('pets').insert(pet.toMap());
  }

  Future<void> updatePet(Pet pet) async {
    await supabase.from('pets').update(pet.toMap()).eq('id', pet.id);
  }

  Future<void> deletePet(String petId) async {
    await supabase.from('pets').delete().eq('id', petId);
  }
}
