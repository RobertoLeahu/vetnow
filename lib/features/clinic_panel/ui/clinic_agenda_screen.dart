import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/datetime/app_date_format.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_ext.dart';
import '../../appointment/providers/appointment_provider.dart';
import '../../../shared/models/appointment.dart';
import '../providers/clinic_panel_provider.dart';

/// Filtro rápido de la agenda por rango de fechas (hora local).
enum AgendaDateFilter { today, tomorrow, thisWeek, all }

extension AgendaDateFilterX on AgendaDateFilter {
  String label(AppLocalizations l10n) => switch (this) {
    AgendaDateFilter.today => l10n.today,
    AgendaDateFilter.tomorrow => l10n.tomorrow,
    AgendaDateFilter.thisWeek => l10n.thisWeek,
    AgendaDateFilter.all => l10n.allAppointments,
  };
}

class ClinicAgendaScreen extends ConsumerStatefulWidget {
  /// Índice del chip inicial: 0 Pendientes, 1 Confirmadas, 2 Realizadas, 3 Canceladas.
  final int initialTabIndex;

  const ClinicAgendaScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<ClinicAgendaScreen> createState() => _ClinicAgendaScreenState();
}

class _ClinicAgendaScreenState extends ConsumerState<ClinicAgendaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  AgendaDateFilter _dateFilter = AgendaDateFilter.all;

  @override
  void initState() {
    super.initState();
    final tab = widget.initialTabIndex.clamp(0, 3);
    _tabController = TabController(length: 4, vsync: this, initialIndex: tab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(clinicAppointmentsProvider);
    await ref.read(clinicAppointmentsProvider.future);
  }

  static DateTime _dateOnlyLocal(DateTime utcOrLocal) {
    final l = utcOrLocal.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  bool _matchesDateFilter(Appointment a) {
    switch (_dateFilter) {
      case AgendaDateFilter.all:
        return true;
      case AgendaDateFilter.today:
        final d = _dateOnlyLocal(a.scheduledAt);
        final today = _dateOnlyLocal(DateTime.now());
        return d == today;
      case AgendaDateFilter.tomorrow:
        final d = _dateOnlyLocal(a.scheduledAt);
        final today = _dateOnlyLocal(DateTime.now());
        final tomorrow = today.add(const Duration(days: 1));
        return d == tomorrow;
      case AgendaDateFilter.thisWeek:
        final d = _dateOnlyLocal(a.scheduledAt);
        final today = _dateOnlyLocal(DateTime.now());
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return !d.isBefore(monday) && !d.isAfter(sunday);
    }
  }

  List<Appointment> _applyDateFilter(List<Appointment> all) {
    if (_dateFilter == AgendaDateFilter.all) return all;
    return all.where(_matchesDateFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final clinicAsync = ref.watch(myClinicProvider);
    final appointmentsAsync = ref.watch(clinicAppointmentsProvider);

    return clinicAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.agendaTitle)),
        body: Center(child: Text(appErrorMessage(context, e))),
      ),
      data: (clinic) {
        if (clinic == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.agendaTitle)),
            body: Center(child: Text(l10n.clinicProfileNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.agendaTitle),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(112),
              child: appointmentsAsync.when(
                data: (all) {
                  final filtered = _applyDateFilter(all);
                  final pending = filtered.where((a) => a.isPending).length;
                  final confirmed = filtered.where((a) => a.isConfirmed).length;
                  final done = filtered.where((a) => a.isDone).length;
                  final cancelled = filtered.where((a) => a.isCancelled).length;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      children: [
                        DropdownButtonFormField<AgendaDateFilter>(
                          key: ValueKey(_dateFilter),
                          initialValue: _dateFilter,
                          borderRadius: BorderRadius.circular(12),
                          decoration: InputDecoration(
                            labelText: l10n.dateFilter,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          items: AgendaDateFilter.values
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(f.label(l10n)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _dateFilter = v);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _AgendaTabChip(
                                label: l10n.tabPending(pending),
                                index: 0,
                                controller: _tabController,
                              ),
                              const SizedBox(width: 8),
                              _AgendaTabChip(
                                label: l10n.tabConfirmedCount(confirmed),
                                index: 1,
                                controller: _tabController,
                              ),
                              const SizedBox(width: 8),
                              _AgendaTabChip(
                                label: l10n.tabCompleted(done),
                                index: 2,
                                controller: _tabController,
                              ),
                              const SizedBox(width: 8),
                              _AgendaTabChip(
                                label: l10n.tabCancelled(cancelled),
                                index: 3,
                                controller: _tabController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(height: 112),
                error: (_, __) => const SizedBox(height: 112),
              ),
            ),
          ),
          body: appointmentsAsync.when(
            data: (all) {
              final filtered = _applyDateFilter(all);
              final pending = filtered.where((a) => a.isPending).toList();
              final confirmed = filtered.where((a) => a.isConfirmed).toList();
              final done = filtered.where((a) => a.isDone).toList();
              final cancelled = filtered.where((a) => a.isCancelled).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _AgendaList(
                    appointments: pending,
                    emptyTitle: l10n.noPendingAppointments,
                    emptySubtitle: l10n.newBookingsAppearHere,
                    onRefresh: _onRefresh,
                    showConfirm: true,
                  ),
                  _AgendaList(
                    appointments: confirmed,
                    emptyTitle: l10n.noConfirmedAppointments,
                    emptySubtitle: '',
                    onRefresh: _onRefresh,
                    showMarkDone: true,
                  ),
                  _AgendaList(
                    appointments: done,
                    emptyTitle: l10n.noCompletedAppointmentsClinic,
                    emptySubtitle: '',
                    onRefresh: _onRefresh,
                  ),
                  _AgendaList(
                    appointments: cancelled,
                    emptyTitle: l10n.noCancelledAppointmentsClinic,
                    emptySubtitle: '',
                    onRefresh: _onRefresh,
                    showDeleteButton: true,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(appErrorMessage(context, e))),
          ),
        );
      },
    );
  }
}

class _AgendaList extends ConsumerWidget {
  final List<Appointment> appointments;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final bool showConfirm;
  final bool showMarkDone;
  final bool showDeleteButton;

  const _AgendaList({
    required this.appointments,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    this.showConfirm = false,
    this.showMarkDone = false,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.35,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note_rounded,
                        size: 72,
                        color: AppTheme.primary.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        emptyTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (emptySubtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          emptySubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ClinicAgendaCard(
          appointment: appointments[i],
          showConfirm: showConfirm,
          showMarkDone: showMarkDone,
          showDeleteButton: showDeleteButton,
        ),
      ),
    );
  }
}

class _ClinicAgendaCard extends ConsumerWidget {
  final Appointment appointment;
  final bool showConfirm;
  final bool showMarkDone;
  final bool showDeleteButton;

  const _ClinicAgendaCard({
    required this.appointment,
    this.showConfirm = false,
    this.showMarkDone = false,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final dateFmt = dateFormat(appointmentCardPattern(locale), locale);
    final ownerName = appointment.ownerFullName?.trim().isNotEmpty == true
        ? appointment.ownerFullName!
        : l10n.notAvailable;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  dateFmt.format(appointment.scheduledAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _AgendaStatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            specialtyLocalizedLabel(l10n, appointment.specialtyName),
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 15,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ownerName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.pets_rounded,
                size: 15,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                appointment.petName,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (showConfirm && appointment.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.confirmAppointment),
                          content: Text(l10n.confirmAppointmentBody),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: Text(l10n.no),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Text(l10n.yesConfirm),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) {
                        try {
                          await ref
                              .read(appointmentRepositoryProvider)
                              .confirmAppointment(appointment.id);
                          ref.invalidate(clinicAppointmentsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            showAppError(context, e);
                          }
                        }
                      }
                    },
                    child: Text(l10n.confirm),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.denyAppointment),
                          content: Text(l10n.denyAppointmentBody),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: Text(l10n.no),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Text(
                                l10n.yesDeny,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) {
                        try {
                          await ref
                              .read(appointmentRepositoryProvider)
                              .rejectAppointmentByClinic(appointment.id);
                          ref.invalidate(clinicAppointmentsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            showAppError(context, e);
                          }
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: Text(l10n.deny),
                  ),
                ),
              ],
            ),
          ],
          if (showMarkDone && appointment.isConfirmed) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.markAsDoneTitle),
                    content: Text(l10n.markAsDoneBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(l10n.no),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(l10n.yesMark),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  try {
                    await ref
                        .read(appointmentRepositoryProvider)
                        .markAppointmentDone(appointment.id);
                    ref.invalidate(clinicAppointmentsProvider);
                  } catch (e) {
                    if (context.mounted) {
                      showAppError(context, e);
                    }
                  }
                }
              },
              child: Text(l10n.markAsDone),
            ),
          ],
          if (showDeleteButton && appointment.isCancelled) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.deleteAppointment),
                    content: Text(l10n.deleteAppointmentClinicBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(l10n.no),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(
                          l10n.yesDelete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  try {
                    await ref
                        .read(appointmentRepositoryProvider)
                        .deleteAppointment(appointment.id);
                    ref.invalidate(clinicAppointmentsProvider);
                  } catch (e) {
                    if (context.mounted) {
                      showAppError(context, e);
                    }
                  }
                }
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(l10n.delete),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AgendaStatusBadge extends StatelessWidget {
  final String status;
  const _AgendaStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = switch (status) {
      'confirmed' => (label: l10n.statusConfirmed, color: AppTheme.primary),
      'cancelled' => (label: l10n.statusCancelled, color: Colors.red),
      'done' => (label: l10n.statusDone, color: Colors.grey),
      _ => (label: l10n.statusPending, color: Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AgendaTabChip extends StatefulWidget {
  final String label;
  final int index;
  final TabController controller;

  const _AgendaTabChip({
    required this.label,
    required this.index,
    required this.controller,
  });

  @override
  State<_AgendaTabChip> createState() => _AgendaTabChipState();
}

class _AgendaTabChipState extends State<_AgendaTabChip> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTab);
  }

  void _onTab() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.controller.index == widget.index;
    return GestureDetector(
      onTap: () => widget.controller.animateTo(widget.index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.divider,
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
