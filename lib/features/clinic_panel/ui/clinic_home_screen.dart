import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../shared/models/appointment.dart';
import '../../../shared/models/pet.dart';
import '../providers/clinic_panel_provider.dart';

class ClinicHomeScreen extends ConsumerStatefulWidget {
  const ClinicHomeScreen({super.key});

  @override
  ConsumerState<ClinicHomeScreen> createState() => _ClinicHomeScreenState();
}

class _ClinicHomeScreenState extends ConsumerState<ClinicHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(clinicAppointmentsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final clinicAsync = ref.watch(myClinicProvider);
    final allAsync = ref.watch(clinicAppointmentsProvider);
    final todayAppointments = ref.watch(todayClinicAppointmentsProvider);
    final todayConfirmedAppointments =
        ref.watch(todayConfirmedClinicAppointmentsProvider);
    final appointmentsLoading = allAsync.isLoading;

    final clinic = clinicAsync.valueOrNull;
    final allAppointments = allAsync.valueOrNull ?? [];
    final pendingCount =
        allAppointments.where((a) => a.isPending).length;

    final today = DateFormat("EEEE, d 'de' MMMM", 'es').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          ref.invalidate(myClinicProvider);
          ref.invalidate(clinicAppointmentsProvider);
          await ref.read(clinicAppointmentsProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            // ── App bar con saludo ───────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 148,
              backgroundColor: AppTheme.background,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                background: _ClinicHeader(
                  clinicName: clinic?.name,
                  logoUrl: clinic?.logoUrl,
                  dateLabel: today,
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Banner perfil incompleto ─────────────────────
                  if (clinicAsync.hasValue &&
                      (clinic == null || !clinic.isProfileComplete))
                    _IncompleteProfileBanner(
                      onTap: () => context.go('/clinic-profile'),
                    ),

                  const SizedBox(height: 20),

                  // ── Citas del día ────────────────────────────────
                  const _SectionLabel(label: 'Hoy'),
                  const SizedBox(height: 10),
                  _TodayAppointmentsCard(
                    isLoading: appointmentsLoading,
                    appointments: todayAppointments,
                    onTapAgenda: () =>
                        context.go('/clinic-agenda', extra: 1),
                  ),

                  const SizedBox(height: 20),

                  // ── Pacientes de hoy ─────────────────────────────
                  const _SectionLabel(label: 'Pacientes de hoy'),
                  const SizedBox(height: 10),
                  _TodayPatientsCarousel(
                    isLoading: appointmentsLoading,
                    appointments: todayConfirmedAppointments,
                  ),

                  const SizedBox(height: 20),

                  // ── Citas por confirmar ──────────────────────────
                  if (!allAsync.isLoading && pendingCount > 0) ...[
                    const _SectionLabel(label: 'Pendiente de tu confirmación'),
                    const SizedBox(height: 10),
                    _PendingConfirmCard(
                      count: pendingCount,
                      onTap: () => context.go('/clinic-agenda'),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Accesos rápidos ──────────────────────────────
                  const _SectionLabel(label: 'Acceso rápido'),
                  const SizedBox(height: 10),
                  _QuickAccessGrid(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cabecera ──────────────────────────────────────────────────────────────────

class _ClinicHeader extends StatelessWidget {
  final String? clinicName;
  final String? logoUrl;
  final String dateLabel;

  const _ClinicHeader({
    required this.clinicName,
    required this.logoUrl,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.surface,
                backgroundImage: (logoUrl != null && logoUrl!.isNotEmpty)
                    ? NetworkImage(logoUrl!) as ImageProvider
                    : null,
                child: (logoUrl == null || logoUrl!.isEmpty)
                    ? const Icon(Icons.storefront_rounded,
                        size: 26, color: AppTheme.textSecondary)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                clinicName ?? 'Mi clínica',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banner perfil incompleto ───────────────────────────────────────────────────

class _IncompleteProfileBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _IncompleteProfileBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.amber.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completa tu perfil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Los propietarios podrán encontrarte cuando completes los datos de tu clínica.',
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber.shade900,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }
}

// ── Etiqueta de sección ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

// ── Tarjeta citas del día ─────────────────────────────────────────────────────

class _TodayAppointmentsCard extends StatelessWidget {
  final bool isLoading;
  final List<Appointment> appointments;
  final VoidCallback onTapAgenda;

  const _TodayAppointmentsCard({
    required this.isLoading,
    required this.appointments,
    required this.onTapAgenda,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoading
          ? const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${appointments.length}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'citas pendientes hoy',
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (appointments.isEmpty)
                  const Text(
                    'Sin citas para hoy. Disfruta el día.',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  )
                else ...[
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    appointments.length == 1
                        ? 'Próxima cita'
                        : 'Próximas citas',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...appointments.take(3).map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _NextAppointmentRow(appointment: a),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onTapAgenda,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver agenda completa',
                          style:
                              TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _NextAppointmentRow extends StatelessWidget {
  final Appointment appointment;
  const _NextAppointmentRow({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(appointment.scheduledAt.toLocal());
    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 15, color: Colors.white70),
        const SizedBox(width: 6),
        Text(
          time,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.pets_rounded, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            appointment.petName,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (appointment.ownerFullName != null) ...[
          const SizedBox(width: 4),
          Text(
            '· ${appointment.ownerFullName}',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// ── Tarjeta citas por confirmar ───────────────────────────────────────────────

class _PendingConfirmCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _PendingConfirmCard({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_active_rounded,
                  color: Colors.orange.shade700, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count ${count == 1 ? 'cita esperando' : 'citas esperando'} confirmación',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Acepta o rechaza desde la agenda',
                    style: TextStyle(
                        fontSize: 12, color: Colors.orange.shade700),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.orange.shade400),
          ],
        ),
      ),
    );
  }
}

// ── Grid accesos rápidos ──────────────────────────────────────────────────────

class _QuickAccessGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.calendar_month_rounded,
            label: 'Agenda',
            subtitle: 'Gestiona tus citas',
            onTap: () => context.go('/clinic-agenda'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.people_rounded,
            label: 'Pacientes',
            subtitle: 'Expedientes médicos',
            onTap: () => context.go('/clinic-patients'),
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carrusel pacientes de hoy ─────────────────────────────────────────────────

class _TodayPatientsCarousel extends StatelessWidget {
  final bool isLoading;
  final List<Appointment> appointments;

  const _TodayPatientsCarousel({
    required this.isLoading,
    required this.appointments,
  });

  /// Dedupe por petId conservando la cita más temprana del día.
  List<Appointment> get _uniquePatients {
    final seen = <String>{};
    final result = <Appointment>[];
    for (final a in appointments) {
      if (seen.add(a.petId)) result.add(a);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 116,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => const _SkeletonPatientChip(),
        ),
      );
    }

    final patients = _uniquePatients;

    if (patients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Ningún paciente con cita confirmada para hoy.',
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: patients.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _TodayPatientChip(appointment: patients[i]),
      ),
    );
  }
}

class _TodayPatientChip extends StatelessWidget {
  final Appointment appointment;
  const _TodayPatientChip({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final time =
        DateFormat('HH:mm').format(appointment.scheduledAt.toLocal());
    final ownerId = appointment.ownerId;
    final petId = appointment.petId;
    final canNavigate = ownerId != null && ownerId.isNotEmpty;

    return GestureDetector(
      onTap: canNavigate
          ? () => context.push(
                '/clinic-patients/$ownerId/$petId',
                extra: appointment.petName,
              )
          : null,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                  backgroundImage: appointment.petPhotoUrl != null &&
                          appointment.petPhotoUrl!.isNotEmpty
                      ? NetworkImage(appointment.petPhotoUrl!) as ImageProvider
                      : null,
                  child: appointment.petPhotoUrl == null ||
                          appointment.petPhotoUrl!.isEmpty
                      ? Text(
                          _speciesEmoji(appointment.petSpecies),
                          style: const TextStyle(fontSize: 14),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.petName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        appointment.ownerFullName ?? '—',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _speciesEmoji(PetSpecies species) => switch (species) {
        PetSpecies.dog => '🐶',
        PetSpecies.cat => '🐱',
        PetSpecies.rabbit => '🐰',
        PetSpecies.hamster => '🐹',
        PetSpecies.bird => '🦜',
        PetSpecies.reptile => '🦎',
        PetSpecies.ferret => '🦦',
        PetSpecies.other => '🐾',
      };
}

class _SkeletonPatientChip extends StatelessWidget {
  const _SkeletonPatientChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppTheme.divider,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 60,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
