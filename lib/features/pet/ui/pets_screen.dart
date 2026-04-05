import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_provider.dart';
import '../../../shared/models/pet.dart';
import '../../../app/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(myPetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis mascotas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPetSheet(context, ref),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Añadir mascota'),
      ),
      body: petsAsync.when(
        data: (pets) => pets.isEmpty
            ? _EmptyPets(onAdd: () => _showAddPetSheet(context, ref))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: pets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _PetCard(pet: pets[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddPetSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _AddPetSheet(onSaved: () => ref.invalidate(myPetsProvider)),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyPets extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPets({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_rounded,
              size: 80,
              color: AppTheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aún no has añadido mascotas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Añade a tu mascota para gestionar sus citas',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Añadir mascota'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de mascota ───────────────────────────────────────────────────────

class _PetCard extends ConsumerWidget {
  final Pet pet;
  const _PetCard({required this.pet});

  String get _speciesLabel => switch (pet.species) {
    PetSpecies.dog => '🐶 Perro',
    PetSpecies.cat => '🐱 Gato',
    PetSpecies.exotic => '🦎 Exótico',
    PetSpecies.other => '🐾 Otro',
  };

  String get _speciesEmoji => switch (pet.species) {
    PetSpecies.dog => '🐶',
    PetSpecies.cat => '🐱',
    PetSpecies.exotic => '🦎',
    PetSpecies.other => '🐾',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          // Avatar especie
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(_speciesEmoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _speciesLabel,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (pet.breed != null && pet.breed!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    pet.breed!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (pet.birthDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _calculateAge(pet.birthDate!),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Botón eliminar
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.textSecondary,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Eliminar mascota'),
                  content: Text('¿Seguro que quieres eliminar a ${pet.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(petRepositoryProvider).deletePet(pet.id);
                ref.invalidate(myPetsProvider);
              }
            },
          ),
        ],
      ),
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final years = now.year - birthDate.year;
    final months = now.month - birthDate.month;
    final totalMonths = years * 12 + months;

    if (totalMonths < 1) return 'Menos de 1 mes';
    if (totalMonths < 12) return '$totalMonths meses';
    if (totalMonths < 24) return '1 año';
    return '${totalMonths ~/ 12} años';
  }
}

// ─── Bottom sheet: añadir mascota ─────────────────────────────────────────────

class _AddPetSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _AddPetSheet({required this.onSaved});

  @override
  ConsumerState<_AddPetSheet> createState() => _AddPetSheetState();
}

class _AddPetSheetState extends ConsumerState<_AddPetSheet> {
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  PetSpecies _species = PetSpecies.dog;
  DateTime? _birthDate;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = ref.read(authRepositoryProvider).currentUser!;
      final pet = Pet(
        id: '',
        ownerId: user.id,
        name: _nameCtrl.text.trim(),
        species: _species,
        breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
        birthDate: _birthDate,
      );
      await ref.read(petRepositoryProvider).addPet(pet);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nueva mascota',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Nombre
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nombre *'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),

          // Especie
          const Text(
            'Especie',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: PetSpecies.values.map((s) {
              final emoji = switch (s) {
                PetSpecies.dog => '🐶',
                PetSpecies.cat => '🐱',
                PetSpecies.exotic => '🦎',
                PetSpecies.other => '🐾',
              };
              final label = switch (s) {
                PetSpecies.dog => 'Perro',
                PetSpecies.cat => 'Gato',
                PetSpecies.exotic => 'Exótico',
                PetSpecies.other => 'Otro',
              };
              final selected = _species == s;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _species = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppTheme.primary : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Raza (opcional)
          TextField(
            controller: _breedCtrl,
            decoration: const InputDecoration(labelText: 'Raza (opcional)'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),

          // Fecha nacimiento (opcional)
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365)),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                helpText: 'Fecha de nacimiento',
              );
              if (picked != null) {
                setState(() => _birthDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cake_rounded,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _birthDate == null
                        ? 'Fecha de nacimiento (opcional)'
                        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                    style: TextStyle(
                      color: _birthDate == null
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Guardar mascota'),
          ),
        ],
      ),
    );
  }
}
