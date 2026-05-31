import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/appointment_provider.dart';
import '../../../app/theme.dart';
import '../../../core/datetime/app_date_format.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../shared/models/appointment.dart';
import '../../pet/providers/pet_provider.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appointmentsAsync = ref.watch(myAppointmentsProvider);
    final petsAsync = ref.watch(myPetsProvider);
    final selectedPetId = ref.watch(selectedPetFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointmentsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: appointmentsAsync.when(
            data: (all) {
              final filteredAll = _filterByPet(all, selectedPetId);
              final upcoming = filteredAll.where((a) => a.isUpcoming).length;
              final done = filteredAll.where((a) => a.isDone).length;
              final cancelled = filteredAll.where((a) => a.isCancelled).length;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    petsAsync.when(
                      data: (pets) => DropdownButtonFormField<String?>(
                        initialValue: selectedPetId,
                        borderRadius: BorderRadius.circular(12),
                        decoration: InputDecoration(
                          labelText: l10n.petFilterLabel,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(l10n.allPets),
                          ),
                          ...pets.map(
                            (p) => DropdownMenuItem<String?>(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(selectedPetFilterProvider.notifier).state =
                              value;
                        },
                      ),
                      loading: () => const SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(l10n.petsLoadError),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _TabChip(
                            label: l10n.tabScheduled(upcoming),
                            index: 0,
                            controller: _tabController,
                          ),
                          const SizedBox(width: 8),
                          _TabChip(
                            label: l10n.tabCompleted(done),
                            index: 1,
                            controller: _tabController,
                          ),
                          const SizedBox(width: 8),
                          _TabChip(
                            label: l10n.tabCancelled(cancelled),
                            index: 2,
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
          final filteredAll = _filterByPet(all, selectedPetId);
          final upcoming = _sortByScheduledAt(
            filteredAll.where((a) => a.isUpcoming),
          );
          final done = _sortByScheduledAt(
            filteredAll.where((a) => a.isDone),
          );
          final cancelled = _sortByScheduledAt(
            filteredAll.where((a) => a.isCancelled),
          );

          return TabBarView(
            controller: _tabController,
            children: [
              _AppointmentList(
                appointments: upcoming,
                emptyTitle: l10n.noScheduledAppointmentsTitle,
                emptySubtitle: l10n.noScheduledAppointmentsSubtitle,
                onRefresh: _refreshAppointments,
              ),
              _AppointmentList(
                appointments: done,
                emptyTitle: l10n.noCompletedAppointmentsTitle,
                emptySubtitle: l10n.completedAppointmentsSubtitle,
                onRefresh: _refreshAppointments,
              ),
              _AppointmentList(
                appointments: cancelled,
                emptyTitle: l10n.noCancelledAppointmentsTitle,
                emptySubtitle: '',
                showDeleteButton: true,
                onRefresh: _refreshAppointments,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(appErrorMessage(context, e))),
      ),
    );
  }

  List<Appointment> _filterByPet(List<Appointment> all, String? selectedPetId) {
    if (selectedPetId == null) return all;
    return all.where((a) => a.petId == selectedPetId).toList();
  }

  List<Appointment> _sortByScheduledAt(Iterable<Appointment> appointments) {
    final sorted = appointments.toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return sorted;
  }

  Future<void> _refreshAppointments() async {
    ref.invalidate(myAppointmentsProvider);
    await ref.read(myAppointmentsProvider.future);
  }
}

class _AppointmentList extends ConsumerWidget {
  final List<Appointment> appointments;
  final String emptyTitle;
  final String emptySubtitle;
  final bool showDeleteButton;
  final Future<void> Function() onRefresh;

  const _AppointmentList({
    required this.appointments,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
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
                        Icons.calendar_month_rounded,
                        size: 80,
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 20),
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
        itemBuilder: (_, i) => _AppointmentCard(
          appointment: appointments[i],
          showDeleteButton: showDeleteButton,
        ),
      ),
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  final bool showDeleteButton;

  const _AppointmentCard({
    required this.appointment,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final fmt = dateFormat(appointmentCardPattern(locale), locale);

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
                  appointment.clinicName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _StatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            appointment.specialtyName,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 13,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  appointment.clinicAddress,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.phone_rounded,
                size: 13,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  appointment.clinicPhone,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                fmt.format(appointment.scheduledAt),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.pets_rounded,
                size: 13,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  appointment.petName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (appointment.isUpcoming) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.cancelAppointment),
                    content: Text(l10n.cancelAppointmentConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(l10n.no),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(
                          l10n.yesCancel,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(appointmentRepositoryProvider)
                      .cancelAppointment(appointment.id);
                  ref.invalidate(myAppointmentsProvider);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(l10n.cancelAppointment),
            ),
          ],
          if (showDeleteButton && appointment.isCancelled) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.deleteAppointment),
                    content: Text(l10n.deleteAppointmentConfirm),
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
                if (confirm == true && context.mounted) {
                  try {
                    await ref
                        .read(appointmentRepositoryProvider)
                        .deleteAppointment(appointment.id);
                    ref.invalidate(myAppointmentsProvider);
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

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

class _TabChip extends StatefulWidget {
  final String label;
  final int index;
  final TabController controller;
  const _TabChip({
    required this.label,
    required this.index,
    required this.controller,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.controller.index == widget.index;
    return GestureDetector(
      onTap: () => widget.controller.animateTo(widget.index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
