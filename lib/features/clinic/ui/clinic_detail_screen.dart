import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/clinic_provider.dart';
import '../../../app/theme.dart';
import '../../../shared/models/specialty.dart';

class ClinicDetailScreen extends ConsumerWidget {
  final String clinicId;
  const ClinicDetailScreen({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicAsync = ref.watch(clinicDetailProvider(clinicId));

    return Scaffold(
      body: clinicAsync.when(
        data: (clinic) {
          if (clinic == null) {
            return const Center(child: Text('Clínica no encontrada'));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.background,
                foregroundColor: AppTheme.textPrimary,
                elevation: 0,
                actions: [
                  _FavoriteButton(clinicId: clinicId),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar circular centrado + nombre
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              backgroundImage: clinic.logoUrl != null
                                  ? NetworkImage(clinic.logoUrl!)
                                  : null,
                              child: clinic.logoUrl == null
                                  ? const Icon(
                                      Icons.local_hospital_rounded,
                                      size: 58,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              clinic.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Info básica
                      _InfoRow(
                        icon: Icons.location_on,
                        text: '${clinic.address}, ${clinic.city}',
                      ),
                      if (clinic.phone != null)
                        _InfoRow(icon: Icons.phone, text: clinic.phone!),
                      if (clinic.email != null)
                        _InfoRow(icon: Icons.email, text: clinic.email!),
                      if (clinic.description != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Sobre nosotros',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          clinic.description!,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],

                      // Especialidades
                      if (clinic.specialties.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Especialidades',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: clinic.specialties
                              .map((s) => Chip(label: Text(s.name)))
                              .toList(),
                        ),
                      ],

                      // Botón reserva
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (clinic.specialties.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Esta clínica no tiene especialidades configuradas',
                                ),
                              ),
                            );
                            return;
                          }

                          if (clinic.specialties.length == 1) {
                            invalidateClinicBookingData(ref, clinic.id);
                            context.push(
                              '/search/clinic/${clinic.id}/book',
                              extra: clinic.specialties.first,
                            );
                            return;
                          }

                          // Varias especialidades → bottom sheet
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (ctx) => _SpecialtySheet(
                              ref: ref,
                              specialties: clinic.specialties,
                              clinicId: clinic.id,
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Reservar cita'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ─── Botón de favorito ───────────────────────────────────────────────────────

class _FavoriteButton extends ConsumerWidget {
  final String clinicId;
  const _FavoriteButton({required this.clinicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoriteClinicIdsProvider).valueOrNull ?? {};
    final isFav = ids.contains(clinicId);

    return IconButton(
      icon: Icon(
        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFav ? Colors.red : null,
      ),
      onPressed: () async {
        final user =
            ref.read(authStateProvider).valueOrNull?.session?.user;
        if (user == null) return;
        final repo = ref.read(clinicRepositoryProvider);
        if (isFav) {
          await repo.removeFavorite(user.id, clinicId);
        } else {
          await repo.addFavorite(user.id, clinicId);
        }
        ref.invalidate(favoriteClinicIdsProvider);
        ref.invalidate(favoriteClinicsProvider);
      },
    );
  }
}

// ─── Bottom sheet de especialidades ──────────────────────────────────────────

class _SpecialtySheet extends StatelessWidget {
  final WidgetRef ref;
  final List<Specialty> specialties;
  final String clinicId;

  const _SpecialtySheet({
    required this.ref,
    required this.specialties,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
              'Selecciona especialidad',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...specialties.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  s.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  invalidateClinicBookingData(ref, clinicId);
                  context.push('/search/clinic/$clinicId/book', extra: s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Fila de información ──────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
