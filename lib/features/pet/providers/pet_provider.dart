import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pet_repository.dart';
import '../../../shared/models/pet.dart';
import '../../../features/auth/providers/auth_provider.dart';

final petRepositoryProvider = Provider<PetRepository>((_) => PetRepository());

final myPetsProvider = FutureProvider<List<Pet>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value.session?.user;
  if (user == null) return [];
  return ref.watch(petRepositoryProvider).fetchMyPets(user.id);
});
