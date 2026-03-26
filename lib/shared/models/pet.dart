import 'package:equatable/equatable.dart';

enum PetSpecies { dog, cat, exotic, other }

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
        species: PetSpecies.values.firstWhere(
          (e) => e.name == map['species'],
          orElse: () => PetSpecies.other,
        ),
        breed: map['breed'] as String?,
        birthDate: map['birth_date'] != null
            ? DateTime.parse(map['birth_date'] as String)
            : null,
        photoUrl: map['photo_url'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'owner_id': ownerId,
        'name': name,
        'species': species.name,
        'breed': breed,
        'birth_date': birthDate?.toIso8601String().split('T').first,
        'photo_url': photoUrl,
      };

  @override
  List<Object?> get props => [id, ownerId, name, species];
}