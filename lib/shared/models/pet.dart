import 'package:equatable/equatable.dart';

enum PetSpecies {
  dog,
  cat,
  rabbit,
  hamster,
  bird,
  reptile,
  fish,
  other,
}

extension PetSpeciesX on PetSpecies {
  String get emoji => switch (this) {
    PetSpecies.dog => '🐶',
    PetSpecies.cat => '🐱',
    PetSpecies.rabbit => '🐰',
    PetSpecies.hamster => '🐹',
    PetSpecies.bird => '🦜',
    PetSpecies.reptile => '🦎',
    PetSpecies.fish => '🐟',
    PetSpecies.other => '🐾',
  };

}

class Pet extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final PetSpecies species;
  final String? breed;
  final DateTime? birthDate;
  final String? photoUrl;

  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.photoUrl,
  });

  factory Pet.fromMap(Map<String, dynamic> map) => Pet(
    id: map['id'] as String,
    ownerId: map['owner_id'] as String,
    name: map['name'] as String,
    species: parsePetSpecies(map['species']),
    breed: map['breed'] as String?,
    birthDate: map['birth_date'] != null
        ? DateTime.parse(map['birth_date'] as String)
        : null,
    photoUrl: map['photo_url'] as String?,
  );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'owner_id': ownerId,
      'name': name,
      'species': species.name,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'photo_url': photoUrl,
    };
    if (id.isNotEmpty) map['id'] = id;
    return map;
  }

  @override
  List<Object?> get props => [id, ownerId, name, species];
}

PetSpecies parsePetSpecies(dynamic raw) {
  final name = raw == 'ferret' ? 'fish' : raw as String?;
  return PetSpecies.values.firstWhere(
    (e) => e.name == name,
    orElse: () => PetSpecies.other,
  );
}
