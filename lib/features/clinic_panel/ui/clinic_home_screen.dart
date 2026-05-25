import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/datetime/app_date_format.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/l10n_ext.dart';
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
    final stats = ref.watch(clinicAppointmentStatsProvider);

    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final today = dateFormat(todayHeaderPattern(locale), locale)
        .format(DateTime.now());

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
              expandedHeight: 100,
              backgroundColor: AppTheme.background,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                background: _ClinicHeader(
                  clinicName: clinic?.name,
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
                  _SectionLabel(label: l10n.today),
                  const SizedBox(height: 10),
                  _TodayAppointmentsCard(
                    isLoading: appointmentsLoading,
                    appointments: todayAppointments,
                    onTapAgenda: () =>
                        context.go('/clinic-agenda', extra: 1),
                  ),

                  const SizedBox(height: 20),

                  // ── Pacientes de hoy ─────────────────────────────
                  _SectionLabel(label: l10n.todayPatients),
                  const SizedBox(height: 10),
                  _TodayPatientsCarousel(
                    isLoading: appointmentsLoading,
                    appointments: todayConfirmedAppointments,
                  ),

                  const SizedBox(height: 20),

                  // ── Citas por confirmar ──────────────────────────
                  if (!allAsync.isLoading && pendingCount > 0) ...[
                    _SectionLabel(label: l10n.pendingYourConfirmation),
                    const SizedBox(height: 10),
                    _PendingConfirmCard(
                      count: pendingCount,
                      onTap: () => context.go('/clinic-agenda'),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Resumen de citas ─────────────────────────────
                  _SectionLabel(label: l10n.activitySummary),
                  const SizedBox(height: 10),
                  _AppointmentsSummaryCard(
                    isLoading: appointmentsLoading,
                    stats: stats,
                    onTapAgenda: () => context.go('/clinic-agenda'),
                  ),

                  const SizedBox(height: 20),

                  // ── Accesos rápidos ──────────────────────────────
                  _SectionLabel(label: l10n.quickAccess),
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
  final String dateLabel;

  const _ClinicHeader({
    required this.clinicName,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clinicName ?? l10n.myClinicFallback,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 13,
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
    final l10n = context.l10n;
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
                  l10n.completeYourProfile,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.completeProfileBannerBody,
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
            child: Text(l10n.complete),
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
    final l10n = context.l10n;
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l10n.confirmedAppointmentsToday,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (appointments.isEmpty)
                  Text(
                    l10n.noAppointmentsTodayEnjoy,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70),
                  )
                else ...[
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    appointments.length == 1
                        ? l10n.nextAppointment
                        : l10n.nextAppointments,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.viewFullAgenda,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
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
    final l10n = context.l10n;
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
                    l10n.appointmentsAwaitingConfirmation(count),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.acceptOrRejectFromAgenda,
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
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.calendar_month_rounded,
            label: l10n.agendaTitle,
            subtitle: l10n.manageYourAppointments,
            onTap: () => context.go('/clinic-agenda'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.people_rounded,
            label: l10n.patientsTitle,
            subtitle: l10n.medicalRecords,
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

// ── Resumen de citas ──────────────────────────────────────────────────────────

class _AppointmentsSummaryCard extends StatelessWidget {
  final bool isLoading;
  final ClinicAppointmentStats stats;
  final VoidCallback onTapAgenda;

  const _AppointmentsSummaryCard({
    required this.isLoading,
    required this.stats,
    required this.onTapAgenda,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.appointmentsOverview,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapAgenda,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.viewAgenda,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppTheme.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryPeriodLabel(
            icon: Icons.today_rounded,
            label: l10n.today,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryStatTile(
                  value: '${stats.todayScheduled}',
                  label: l10n.scheduled,
                  icon: Icons.event_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStatTile(
                  value: '${stats.todayDone}',
                  label: l10n.statCompleted,
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryStatTile(
                  value: '${stats.todayConfirmed}',
                  label: l10n.statConfirmed,
                  icon: Icons.verified_rounded,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStatTile(
                  value: '${stats.todayPending}',
                  label: l10n.toConfirm,
                  icon: Icons.hourglass_top_rounded,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          if (stats.uniquePatientsToday > 0) ...[
            const SizedBox(height: 10),
            _SummaryHighlightRow(
              icon: Icons.pets_rounded,
              text: l10n.confirmedPatientsToday(stats.uniquePatientsToday),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _SummaryPeriodLabel(
            icon: Icons.date_range_rounded,
            label: l10n.thisWeek,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryStatTile(
                  value: '${stats.weekScheduled}',
                  label: l10n.scheduled,
                  icon: Icons.calendar_month_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStatTile(
                  value: '${stats.weekDone}',
                  label: l10n.statCompleted,
                  icon: Icons.task_alt_rounded,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryStatTile(
                  value: '${stats.weekConfirmed}',
                  label: l10n.statConfirmed,
                  icon: Icons.event_available_rounded,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStatTile(
                  value: '${stats.weekPending}',
                  label: l10n.toConfirm,
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          if (stats.weekCancelled > 0 || stats.todayCancelled > 0) ...[
            const SizedBox(height: 10),
            _SummaryHighlightRow(
              icon: Icons.cancel_outlined,
              text: stats.weekCancelled > 0
                  ? l10n.cancelledThisWeek(stats.weekCancelled)
                  : l10n.cancelledToday(stats.todayCancelled),
              muted: true,
            ),
          ],
          if (stats.pendingConfirmTotal > 0) ...[
            const SizedBox(height: 10),
            _SummaryHighlightRow(
              icon: Icons.notifications_active_outlined,
              text: l10n.totalAwaitingConfirmation(stats.pendingConfirmTotal),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryPeriodLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryPeriodLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SummaryStatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryStatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
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
    );
  }
}

class _SummaryHighlightRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool muted;

  const _SummaryHighlightRow({
    required this.icon,
    required this.text,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: muted
            ? AppTheme.background
            : AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: muted ? AppTheme.textSecondary : AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: muted ? AppTheme.textSecondary : AppTheme.textPrimary,
                fontWeight: muted ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
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
        child: Text(
          context.l10n.noConfirmedPatientsToday,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
