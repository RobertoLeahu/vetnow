import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/clinic_provider.dart';
import '../../../app/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/specialty.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final firstName = profile?.fullName.split(' ').first ?? '';
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final clinicsAsync = ref.watch(clinicSearchProvider);
    final filters = ref.watch(searchFiltersProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Icon(Icons.pets_rounded, size: 36, color: AppTheme.primary),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          const TextSpan(text: 'Hola, '),
                          TextSpan(
                            text: '$firstName.',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buscador
                    TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText:
                            'Encuentra clínicas o especialistas por ubicación',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (v) => ref
                          .read(searchFiltersProvider.notifier)
                          .update((s) => s.copyWith(city: v)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Chips de especialidades
            SliverToBoxAdapter(
              child: specialtiesAsync.when(
                data: (specialties) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center, // Centra los chips horizontalmente
                    spacing: 8.0, // Espacio horizontal entre los chips
                    runSpacing:
                        8.0, // Espacio vertical entre las líneas de chips
                    children: [
                      _SpecialtyChip(
                        label: 'Todas',
                        selected: filters.specialtyId == null,
                        onTap: () => ref
                            .read(searchFiltersProvider.notifier)
                            .update((s) => s.copyWith(clearSpecialty: true)),
                      ),

                      ...specialties.map(
                        (s) {
                          return _SpecialtyChip(
                            label: s.name,
                            selected: filters.specialtyId == s.id,
                            onTap: () => ref
                                .read(searchFiltersProvider.notifier)
                                .update((f) => f.copyWith(specialtyId: s.id)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Ajustar el loading para que ocupe algo más
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Título sección
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Clínicas disponibles',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Lista de clínicas
            clinicsAsync.when(
              data: (clinics) => clinics.isEmpty
                  ? SliverToBoxAdapter(
                      child: _EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No hay clínicas con estos filtros',
                        subtitle: 'Prueba con otra ciudad o especialidad',
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: _ClinicCard(clinic: clinics[i]),
                        ),
                        childCount: clinics.length,
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SpecialtyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final Clinic clinic;
  const _ClinicCard({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search/clinic/${clinic.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: clinic.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(clinic.logoUrl!, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.local_hospital_rounded,
                      color: AppTheme.primary,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        clinic.city,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (clinic.specialties.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: clinic.specialties
                          .take(2)
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                s.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
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
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
