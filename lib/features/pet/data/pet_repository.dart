import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/pet.dart';

class PetRepository {
  PetRepository({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  Future<List<Pet>> fetchMyPets(String ownerId) async {
    final data = await _client.from('pets').select().eq('owner_id', ownerId);
    return (data as List).map((e) => Pet.fromMap(e)).toList();
  }

  /// Devuelve el `id` de la fila insertada.
  Future<String> addPet(Pet pet) async {
    final row = await _client.from('pets').insert(pet.toMap()).select('id').single();
    return row['id'] as String;
  }

  Future<void> updatePet(Pet pet) async {
    await _client.from('pets').update(pet.toMap()).eq('id', pet.id);
  }

  Future<void> deletePet(String petId) async {
    await _client.from('pets').delete().eq('id', petId);
  }

  String _contentTypeForPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }

  /// Sube la imagen al bucket `pet-photos` y devuelve la URL pública.
  Future<String> uploadPetPhoto({
    required String ownerId,
    required String petId,
    required File file,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    final objectName =
        '$ownerId/${petId.isEmpty ? DateTime.now().millisecondsSinceEpoch : petId}.$ext';
    final contentType = _contentTypeForPath(file.path);
    await _client.storage.from('pet-photos').upload(
          objectName,
          file,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );
    return _client.storage.from('pet-photos').getPublicUrl(objectName);
  }
}
