import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../../../l10n/l10n_ext.dart';
import '../providers/clinic_provider.dart';
import 'clinic_list_card.dart';

class FavoriteClinicsScreen extends ConsumerWidget {
  final String title;

  const FavoriteClinicsScreen({super.key, required this.title});

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(favoriteClinicsProvider);
    await ref.read(favoriteClinicsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favoritesAsync = ref.watch(favoriteClinicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: favoritesAsync.when(
        data: (clinics) {
          if (clinics.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 48,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noSavedClinicsTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noSavedClinicsSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/search'),
                      icon: const Icon(Icons.search_rounded, size: 16),
                      label: Text(l10n.findClinics),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _onRefresh(ref),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: clinics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => ClinicListCard(clinic: clinics[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(appErrorMessage(context, e)),
          ),
        ),
      ),
    );
  }
}
