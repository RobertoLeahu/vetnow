
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/clinic_provider.dart';

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
                          text: '${clinic.address}, ${clinic.city}'),
                      if (clinic.phone != null)
                        _InfoRow(icon: Icons.phone, text: clinic.phone!),
                      if (clinic.email != null)
                        _InfoRow(icon: Icons.email, text: clinic.email!),
                      if (clinic.description != null) ...[
                        const SizedBox(height: 16),
                        const Text('Sobre nosotros',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(clinic.description!,
                            style: const TextStyle(color: Colors.grey)),
                      ],

                      // Especialidades
                      if (clinic.specialties.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text('Especialidades',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
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
                        onPressed: () =>
                            context.push('/appointment/new/${clinic.id}'),
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