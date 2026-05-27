import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/pet_provider.dart';
import '../../../shared/models/pet.dart';
import '../../../app/theme.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../shared/widgets/app_error_banner.dart';

class PetsScreen extends ConsumerStatefulWidget {
  const PetsScreen({super.key});

  @override
  ConsumerState<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends ConsumerState<PetsScreen> {
  Future<void> _refreshPets() async {
    ref.invalidate(myPetsProvider);
    await ref.read(myPetsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final petsAsync = ref.watch(myPetsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myPetsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPetSheet(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addPet),
      ),
      body: petsAsync.when(
        data: (pets) => pets.isEmpty
            ? RefreshIndicator(
                onRefresh: _refreshPets,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.45,
                      child: _EmptyPets(
                        onAdd: () => _showAddPetSheet(context),
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshPets,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: pets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PetCard(
                    pet: pets[i],
                    onEdit: () => _showEditPetSheet(context, pets[i]),
                  ),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(appErrorMessage(context, e))),
      ),
    );
  }

  void _showAddPetSheet(BuildContext context) {
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

  void _showEditPetSheet(BuildContext context, Pet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditPetSheet(
        pet: pet,
        onSaved: () => ref.invalidate(myPetsProvider),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyPets extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPets({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_rounded,
              size: 80,
              color: AppTheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noPetsYetTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noPetsYetSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l10n.addPet),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Especies (chips) ─────────────────────────────────────────────────────────

class _SpeciesChip extends StatelessWidget {
  final PetSpecies species;
  final bool selected;
  final VoidCallback onTap;

  const _SpeciesChip({
    required this.species,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(species.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                species.localizedLabel(l10n),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeciesWrap extends StatelessWidget {
  final PetSpecies selected;
  final ValueChanged<PetSpecies> onChanged;

  const _SpeciesWrap({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PetSpecies.values
          .map(
            (s) => _SpeciesChip(
              species: s,
              selected: selected == s,
              onTap: () => onChanged(s),
            ),
          )
          .toList(),
    );
  }
}

// ─── Avatar formulario (foto / emoji) ─────────────────────────────────────────

class _PetFormPhotoAvatar extends StatelessWidget {
  final PetSpecies species;
  final File? localFile;
  final String? networkUrl;
  final VoidCallback onTap;
  final bool uploading;

  const _PetFormPhotoAvatar({
    required this.species,
    required this.onTap,
    this.localFile,
    this.networkUrl,
    this.uploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: uploading ? null : onTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      border: Border.all(color: AppTheme.divider, width: 2),
                    ),
                    child: ClipOval(
                      child: localFile != null
                          ? Image.file(
                              localFile!,
                              fit: BoxFit.cover,
                              width: 96,
                              height: 96,
                            )
                          : (networkUrl != null && networkUrl!.isNotEmpty)
                              ? Image.network(
                                  networkUrl!,
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 96,
                                  errorBuilder: (_, __, ___) =>
                                      _emojiFallback(species),
                                )
                              : _emojiFallback(species),
                    ),
                  ),
                ),
              ),
              if (uploading)
                Positioned.fill(
                  child: ClipOval(
                    child: Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            uploading ? l10n.uploadingPhoto : l10n.tapToAddPhoto,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emojiFallback(PetSpecies s) {
    return Center(
      child: Text(s.emoji, style: const TextStyle(fontSize: 44)),
    );
  }
}

void _showPetPhotoSourceSheet(
  BuildContext context, {
  required void Function(ImageSource source) onChosen,
  VoidCallback? onRemove,
}) {
  final l10n = context.l10n;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.takePhoto),
            onTap: () {
              Navigator.pop(sheetCtx);
              onChosen(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.chooseFromGallery),
            onTap: () {
              Navigator.pop(sheetCtx);
              onChosen(ImageSource.gallery);
            },
          ),
          if (onRemove != null)
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: Text(
                l10n.removeProfilePhoto,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                onRemove();
              },
            ),
        ],
      ),
    ),
  );
}

// ─── Tarjeta de mascota ───────────────────────────────────────────────────────

class _PetCard extends ConsumerWidget {
  final Pet pet;
  final VoidCallback onEdit;
  const _PetCard({required this.pet, required this.onEdit});

  Widget _emojiAvatar() {
    return Container(
      width: 56,
      height: 56,
      color: AppTheme.primary.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        pet.species.emoji,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }

  Widget _listAvatar() {
    final photo = pet.photoUrl;
    final hasPhoto = photo != null && photo.isNotEmpty;

    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: hasPhoto
            ? Image.network(
                photo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _emojiAvatar(),
              )
            : _emojiAvatar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            _listAvatar(),
            const SizedBox(width: 14),
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
                    '${pet.species.emoji} ${pet.species.localizedLabel(l10n)}',
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
                      _calculateAge(pet.birthDate!, l10n),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppTheme.textSecondary),
              tooltip: l10n.editPetTooltip,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.textSecondary,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.deletePetTitle),
                    content: Text(l10n.deletePetConfirm(pet.name)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
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
      ),
    );
  }

  String _calculateAge(DateTime birthDate, AppLocalizations l10n) {
    final now = DateTime.now();
    final years = now.year - birthDate.year;
    final months = now.month - birthDate.month;
    final totalMonths = years * 12 + months;

    if (totalMonths < 1) return l10n.ageLessThanOneMonth;
    if (totalMonths < 12) return l10n.ageMonths(totalMonths);
    if (totalMonths < 24) return l10n.ageOneYear;
    return l10n.ageYears(totalMonths ~/ 12);
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
  File? _pickedPhoto;
  bool _loading = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (x != null && mounted) {
      setState(() => _pickedPhoto = File(x.path));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.nameRequiredError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = ref.read(authRepositoryProvider).currentUser!;
      final repo = ref.read(petRepositoryProvider);
      final pet = Pet(
        id: '',
        ownerId: user.id,
        name: _nameCtrl.text.trim(),
        species: _species,
        breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
        birthDate: _birthDate,
      );
      final newId = await repo.addPet(pet);

      if (_pickedPhoto != null) {
        final url = await repo.uploadPetPhoto(
          ownerId: user.id,
          petId: newId,
          file: _pickedPhoto!,
        );
        await repo.updatePet(
          Pet(
            id: newId,
            ownerId: user.id,
            name: pet.name,
            species: pet.species,
            breed: pet.breed,
            birthDate: pet.birthDate,
            photoUrl: url,
          ),
        );
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = appErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Padding(
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
            Text(
              l10n.newPet,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _PetFormPhotoAvatar(
              species: _species,
              localFile: _pickedPhoto,
              onTap: () => _showPetPhotoSourceSheet(
                context,
                onChosen: _pickImage,
              ),
              uploading: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.nameRequired),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.species,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            _SpeciesWrap(
              selected: _species,
              onChanged: (s) => setState(() => _species = s),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _breedCtrl,
              decoration: InputDecoration(labelText: l10n.breedOptional),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 365)),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  helpText: l10n.birthDate,
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
                          ? l10n.birthDateOptional
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
              AppErrorBanner(message: _error!),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.savePet),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditPetSheet extends ConsumerStatefulWidget {
  final Pet pet;
  final VoidCallback onSaved;
  const _EditPetSheet({required this.pet, required this.onSaved});

  @override
  ConsumerState<_EditPetSheet> createState() => _EditPetSheetState();
}

class _EditPetSheetState extends ConsumerState<_EditPetSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late PetSpecies _species;
  DateTime? _birthDate;
  File? _pickedPhoto;
  bool _removePhoto = false;
  bool _loading = false;
  bool _uploadingPhoto = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (x != null && mounted) {
      setState(() {
        _pickedPhoto = File(x.path);
        _removePhoto = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.pet.name);
    _breedCtrl = TextEditingController(text: widget.pet.breed ?? '');
    _species = widget.pet.species;
    _birthDate = widget.pet.birthDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.nameRequiredError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = ref.read(petRepositoryProvider);
      String? photoUrl = widget.pet.photoUrl;

      if (_removePhoto && _pickedPhoto == null) {
        photoUrl = null;
      } else if (_pickedPhoto != null) {
        setState(() => _uploadingPhoto = true);
        photoUrl = await repo.uploadPetPhoto(
          ownerId: widget.pet.ownerId,
          petId: widget.pet.id,
          file: _pickedPhoto!,
        );
        if (mounted) setState(() => _uploadingPhoto = false);
      }

      final updatedPet = Pet(
        id: widget.pet.id,
        ownerId: widget.pet.ownerId,
        name: _nameCtrl.text.trim(),
        species: _species,
        breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
        birthDate: _birthDate,
        photoUrl: photoUrl,
      );
      await repo.updatePet(updatedPet);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = appErrorMessage(context, e));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _uploadingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayUrl = (_pickedPhoto == null && !_removePhoto)
        ? widget.pet.photoUrl
        : null;

    return SingleChildScrollView(
      child: Padding(
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
            Text(
              l10n.editPet,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _PetFormPhotoAvatar(
              species: _species,
              localFile: _pickedPhoto,
              networkUrl: displayUrl,
              onTap: () => _showPetPhotoSourceSheet(
                context,
                onChosen: _pickImage,
                onRemove: () {
                  setState(() {
                    _pickedPhoto = null;
                    _removePhoto = true;
                  });
                },
              ),
              uploading: _uploadingPhoto,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.nameRequired),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.species,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            _SpeciesWrap(
              selected: _species,
              onChanged: (s) => setState(() => _species = s),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _breedCtrl,
              decoration: InputDecoration(labelText: l10n.breedOptional),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  helpText: l10n.birthDate,
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
                          ? l10n.birthDateOptional
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
              AppErrorBanner(message: _error!),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }
}
