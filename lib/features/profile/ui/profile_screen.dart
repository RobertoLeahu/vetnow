import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clinic/providers/clinic_provider.dart';
import '../../../app/theme.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../shared/models/clinic.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider).valueOrNull;
    final favoritesAsync = ref.watch(favoriteClinicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),

          // Nombre
          Center(
            child: Text(
              profile?.fullName ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Opciones de perfil
          _ProfileMenuItem(
            icon: Icons.pets_rounded,
            label: l10n.myPets,
            onTap: () => context.go('/pets'),
          ),
          _ProfileMenuItem(
            icon: Icons.calendar_month_rounded,
            label: l10n.myAppointments,
            onTap: () => context.go('/appointments'),
          ),

          const SizedBox(height: 32),

          // Sección guardados
          Text(
            l10n.saved,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          favoritesAsync.when(
            data: (favorites) => _SavedClinicsSection(
              clinics: favorites.take(3).toList(),
              onShowMore: favorites.length > 3
                  ? () => context.push('/profile/favorites')
                  : null,
            ),
            loading: () => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(appErrorMessage(context, e)),
            ),
          ),

          const SizedBox(height: 32),

          // Logout
          OutlinedButton.icon(
            onPressed: () => _confirmAndSignOut(context, ref),
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: Text(l10n.signOut),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go('/login');
    } catch (e) {
      if (context.mounted) showAppError(context, e);
    }
  }
}

class _SavedClinicsSection extends StatelessWidget {
  final List<Clinic> clinics;
  final VoidCallback? onShowMore;

  const _SavedClinicsSection({
    required this.clinics,
    this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (clinics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              l10n.noSavedClinicsTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.noSavedClinicsSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
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
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < clinics.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTheme.divider),
            _SavedClinicTile(clinic: clinics[i]),
          ],
          if (onShowMore != null) ...[
            const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: TextButton(
                  onPressed: onShowMore,
                  child: Text(
                    l10n.showMore,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SavedClinicTile extends StatelessWidget {
  final Clinic clinic;

  const _SavedClinicTile({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/search/clinic/${clinic.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: clinic.logoUrl != null && clinic.logoUrl!.isNotEmpty
                  ? NetworkImage(clinic.logoUrl!)
                  : null,
              child: clinic.logoUrl == null || clinic.logoUrl!.isEmpty
                  ? const Icon(
                      Icons.local_hospital_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clinic.city,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
          title: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondary,
          ),
          onTap: onTap,
        ),
        const Divider(color: AppTheme.divider, height: 1),
      ],
    );
  }
}
