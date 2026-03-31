import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/clinic_provider.dart';
import '../../../shared/models/clinic.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final clinicsAsync = ref.watch(clinicSearchProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar clínicas')),
      body: Column(
        children: [
          // Barra de filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  onChanged: (v) => ref
                      .read(searchFiltersProvider.notifier)
                      .update((s) => s.copyWith(city: v)),
                ),
                const SizedBox(height: 12),
                specialtiesAsync.when(
                  data: (specialties) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Especialidad',
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    value: filters.specialtyId,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Todas')),
                      ...specialties.map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          )),
                    ],
                    onChanged: (v) => ref
                        .read(searchFiltersProvider.notifier)
                        .update((s) => s.copyWith(specialtyId: v)),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: clinicsAsync.when(
              data: (clinics) => clinics.isEmpty
                  ? const Center(
                      child: Text('No hay clínicas con estos filtros 🐾'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: clinics.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _ClinicCard(clinic: clinics[i]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final Clinic clinic;
  const _ClinicCard({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/clinic/${clinic.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Logo o placeholder
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: clinic.logoUrl != null
                    ? NetworkImage(clinic.logoUrl!)
                    : null,
                child: clinic.logoUrl == null
                    ? const Icon(Icons.local_hospital, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clinic.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(clinic.city,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ]),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: clinic.specialties
                          .take(3)
                          .map((s) => Chip(
                                label: Text(s.name,
                                    style: const TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}