import 'package:flutter_test/flutter_test.dart';
import 'package:vetnow/features/pet/data/pet_repository.dart';
import 'package:vetnow/shared/models/pet.dart';

import '../../../helpers/supabase_mocks.dart';

void main() {
  late FakeSupabaseClient fakeClient;
  late FakeSupabaseQueryBuilder petsTable;
  late PetRepository repo;

  setUp(() {
    fakeClient = FakeSupabaseClient();
    petsTable = fakeClient.table('pets');
    repo = PetRepository(client: fakeClient);
  });

  group('addPet', () {
    test('T-U6 persiste campos opcionales breed, birth_date y photo_url', () async {
      petsTable.builder.result = {'id': 'new-pet-id'};

      final fullPet = Pet(
        id: '',
        ownerId: 'owner-1',
        name: 'Luna',
        species: PetSpecies.dog,
        breed: 'Labrador',
        birthDate: DateTime(2020, 3, 15),
        photoUrl: 'https://example.com/luna.jpg',
      );

      final newId = await repo.addPet(fullPet);

      expect(newId, 'new-pet-id');

      final captured = petsTable.capturedInsert!;

      expect(captured['breed'], 'Labrador');
      expect(captured['birth_date'], '2020-03-15');
      expect(captured['photo_url'], 'https://example.com/luna.jpg');
      expect(captured.containsKey('id'), isFalse);
    });
  });

  group('Pet.toMap', () {
    test('T-U10 no incluye id cuando está vacío', () {
      const pet = Pet(
        id: '',
        ownerId: 'owner-1',
        name: 'Luna',
        species: PetSpecies.cat,
      );

      final map = pet.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['owner_id'], 'owner-1');
      expect(map['name'], 'Luna');
    });
  });
}
