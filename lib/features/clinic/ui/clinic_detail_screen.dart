import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(clinic.name),
                  background: clinic.logoUrl != null
                      ? Image.network(clinic.logoUrl!, fit: BoxFit.cover)
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.local_hospital, size: 64),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

// ─── Bottom sheet de especialidades ──────────────────────────────────────────

class _SpecialtySheet extends StatelessWidget {
  final List<Specialty> specialties;
  final String clinicId;

  const _SpecialtySheet({required this.specialties, required this.clinicId});

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
