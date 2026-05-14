import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../shared/models/medical_note.dart';
import '../../../shared/models/pet.dart';
import '../data/medical_notes_repository.dart';
import '../providers/clinic_panel_provider.dart';

// ── ClinicPatientsScreen ──────────────────────────────────────────────────────

class ClinicPatientsScreen extends ConsumerWidget {
  const ClinicPatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(clinicPatientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: patientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: 'No se pudieron cargar los pacientes.',
          onRetry: () => ref.invalidate(clinicPatientsProvider),
        ),
        data: (patients) {
          if (patients.isEmpty) {
            return _EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Sin pacientes aún',
              subtitle:
                  'Los propietarios que reserven citas aparecerán aquí.',
              onRefresh: () => ref.invalidate(clinicPatientsProvider),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(clinicPatientsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final patient = patients[i];
                return _PatientCard(patient: patient);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final ClinicPatient patient;
  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(patient.fullName);
    final lastVisitLabel = DateFormat("d MMM yyyy", 'es')
        .format(patient.lastAppointmentAt);

    return InkWell(
      onTap: () => context.push(
        '/clinic-patients/${patient.ownerId}',
        extra: patient.fullName,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Última cita · $lastVisitLabel',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: AppTheme.textSecondary.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── OwnerPetsScreen ───────────────────────────────────────────────────────────

class OwnerPetsScreen extends ConsumerWidget {
  final String ownerId;
  final String ownerName;

  const OwnerPetsScreen({
    super.key,
    required this.ownerId,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(ownerPetsForClinicProvider(ownerId));

    return Scaffold(
      appBar: AppBar(
        title: Text(ownerName.isNotEmpty ? ownerName : 'Mascotas'),
      ),
      body: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: 'No se pudieron cargar las mascotas.',
          onRetry: () => ref.invalidate(ownerPetsForClinicProvider(ownerId)),
        ),
        data: (pets) {
          if (pets.isEmpty) {
            return _EmptyState(
              icon: Icons.pets_rounded,
              title: 'Sin mascotas registradas',
              subtitle: 'Este propietario no tiene mascotas con visitas.',
              onRefresh: () =>
                  ref.invalidate(ownerPetsForClinicProvider(ownerId)),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(ownerPetsForClinicProvider(ownerId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _PetCard(
                pet: pets[i],
                ownerId: ownerId,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  final String ownerId;

  const _PetCard({required this.pet, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        '/clinic-patients/$ownerId/${pet.id}',
        extra: pet.name,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  pet.species.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _petSubtitle(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _petSubtitle() {
    final parts = <String>[pet.species.label];
    if (pet.breed != null && pet.breed!.isNotEmpty) parts.add(pet.breed!);
    if (pet.birthDate != null) parts.add(_ageLabel(pet.birthDate!));
    return parts.join(' · ');
  }

  String _ageLabel(DateTime birth) {
    final now = DateTime.now();
    final months = (now.year - birth.year) * 12 + now.month - birth.month;
    if (months < 1) return 'recién nacido';
    if (months < 12) return '$months ${months == 1 ? 'mes' : 'meses'}';
    final years = months ~/ 12;
    return '$years ${years == 1 ? 'año' : 'años'}';
  }
}

// ── PetVisitsScreen ───────────────────────────────────────────────────────────

class PetVisitsScreen extends ConsumerWidget {
  final String ownerId;
  final String petId;
  final String petName;

  const PetVisitsScreen({
    super.key,
    required this.ownerId,
    required this.petId,
    required this.petName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(petVisitsProvider(petId));
    final clinicAsync = ref.watch(myClinicProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(petName.isNotEmpty ? petName : 'Historial'),
      ),
      body: clinicAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: 'Error al cargar la clínica.',
          onRetry: () {},
        ),
        data: (clinic) {
          if (clinic == null) {
            return const Center(child: Text('No se encontró la clínica.'));
          }

          return visitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(
              message: 'No se pudo cargar el historial.',
              onRetry: () => ref.invalidate(petVisitsProvider(petId)),
            ),
            data: (visits) {
              if (visits.isEmpty) {
                return _EmptyState(
                  icon: Icons.history_rounded,
                  title: 'Sin visitas realizadas',
                  subtitle:
                      'Aquí aparecerán las visitas marcadas como realizadas.',
                  onRefresh: () => ref.invalidate(petVisitsProvider(petId)),
                );
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(petVisitsProvider(petId)),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: visits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _VisitCard(
                    visit: visits[i],
                    clinicId: clinic.id,
                    petId: petId,
                    ref: ref,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final PetVisit visit;
  final String clinicId;
  final String petId;
  final WidgetRef ref;

  const _VisitCard({
    required this.visit,
    required this.clinicId,
    required this.petId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat("d 'de' MMMM 'de' yyyy · HH:mm", 'es');
    final hasNotes = visit.notes.isNotEmpty;
    final dateShort = DateFormat("d MMM yyyy", 'es');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: fecha + especialidad
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 18,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFmt.format(visit.scheduledAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visit.specialtyName,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 12),

          Text(
            hasNotes
                ? 'Notas clínicas (${visit.notes.length})'
                : 'Notas clínicas',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),

          if (hasNotes)
            ...visit.notes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ClinicalNoteBlock(
                  note: note,
                  dateShort: dateShort,
                  onEdit: () => _showNoteSheet(context, editingNote: note),
                ),
              ),
            ),

          TextButton.icon(
            onPressed: () => _showNoteSheet(context),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(hasNotes ? 'Añadir otra nota' : 'Añadir nota clínica'),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              foregroundColor: AppTheme.primary,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: AppTheme.primary.withValues(alpha: 0.06),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteSheet(BuildContext context, {MedicalNote? editingNote}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _NoteSheet(
        editingNote: editingNote,
        onSave: (text) async {
          Navigator.of(sheetContext).pop();
          try {
            final repo = ref.read(medicalNotesRepositoryProvider);
            if (editingNote == null) {
              await repo.addNote(
                appointmentId: visit.appointmentId,
                clinicId: clinicId,
                content: text,
              );
            } else {
              await repo.updateNote(
                noteId: editingNote.id,
                content: text,
              );
            }
            ref.invalidate(petVisitsProvider(petId));
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al guardar: $e')),
              );
            }
          }
        },
      ),
    );
  }
}

class _ClinicalNoteBlock extends StatelessWidget {
  final MedicalNote note;
  final DateFormat dateShort;
  final VoidCallback onEdit;

  const _ClinicalNoteBlock({
    required this.note,
    required this.dateShort,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.45),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  note.updatedAt != note.createdAt
                      ? 'Editado ${dateShort.format(note.updatedAt)}'
                      : dateShort.format(note.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppTheme.primary,
                ),
                child: const Text(
                  'Editar',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── _NoteSheet ────────────────────────────────────────────────────────────────

class _NoteSheet extends StatefulWidget {
  final MedicalNote? editingNote;
  final Future<void> Function(String text) onSave;

  const _NoteSheet({this.editingNote, required this.onSave});

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.editingNote?.content ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
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
            widget.editingNote == null ? 'Nueva nota' : 'Editar nota',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.editingNote == null
                ? 'Puedes añadir varias notas por visita.'
                : 'Actualiza el texto de esta nota.',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            maxLines: 5,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Ej. Revisión general, vacuna antirrábica aplicada…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
              ),
              filled: true,
              fillColor: AppTheme.surface,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving
                ? null
                : () async {
                    final text = _ctrl.text.trim();
                    if (text.isEmpty) return;
                    setState(() => _saving = true);
                    await widget.onSave(text);
                  },
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.editingNote == null
                        ? 'Guardar nota'
                        : 'Guardar cambios',
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 72,
                      color: AppTheme.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
