import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../appointment/providers/appointment_provider.dart';
import '../../../shared/models/appointment.dart';
import '../providers/clinic_panel_provider.dart';

class ClinicAgendaScreen extends ConsumerStatefulWidget {
  const ClinicAgendaScreen({super.key});

  @override
  ConsumerState<ClinicAgendaScreen> createState() => _ClinicAgendaScreenState();
}

class _ClinicAgendaScreenState extends ConsumerState<ClinicAgendaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    final clinicAsync = ref.watch(myClinicProvider);
    final appointmentsAsync = ref.watch(clinicAppointmentsProvider);

    return clinicAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Agenda')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (clinic) {
        if (clinic == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Agenda')),
            body: const Center(
              child: Text('No se encontró el perfil de clínica.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Agenda'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(92),
              child: appointmentsAsync.when(
                data: (all) {
                  final pending =
                      all.where((a) => a.isPending).length;
                  final confirmed =
                      all.where((a) => a.isConfirmed).length;
                  final done = all.where((a) => a.isDone).length;
                  final cancelled =
                      all.where((a) => a.isCancelled).length;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: [
                        _AgendaTabChip(
                          label: 'Pendientes ($pending)',
                          index: 0,
                          controller: _tabController,
                        ),
                        _AgendaTabChip(
                          label: 'Confirmadas ($confirmed)',
                          index: 1,
                          controller: _tabController,
                        ),
                        _AgendaTabChip(
                          label: 'Realizadas ($done)',
                          index: 2,
                          controller: _tabController,
                        ),
                        _AgendaTabChip(
                          label: 'Canceladas ($cancelled)',
                          index: 3,
                          controller: _tabController,
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(height: 92),
                error: (_, __) => const SizedBox(height: 92),
              ),
            ),
          ),
          body: appointmentsAsync.when(
            data: (all) {
              final pending = all.where((a) => a.isPending).toList();
              final confirmed = all.where((a) => a.isConfirmed).toList();
              final done = all.where((a) => a.isDone).toList();
              final cancelled = all.where((a) => a.isCancelled).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _AgendaList(
                    appointments: pending,
                    emptyTitle: 'No hay citas pendientes',
                    emptySubtitle: 'Las nuevas reservas aparecerán aquí.',
                    onRefresh: _onRefresh,
                    showConfirm: true,
                  ),
                  _AgendaList(
                    appointments: confirmed,
                    emptyTitle: 'No hay citas confirmadas',
                    emptySubtitle: '',
                    onRefresh: _onRefresh,
                    showMarkDone: true,
                  ),
                  _AgendaList(
                    appointments: done,
                    emptyTitle: 'No hay citas realizadas',
                    emptySubtitle: '',
                    onRefresh: _onRefresh,
                  ),
                  _AgendaList(
                    appointments: cancelled,
                    emptyTitle: 'No hay citas canceladas',
                    emptySubtitle: '',
                    onRefresh: _onRefresh,
                    showDeleteButton: true,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
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
    final dateFmt = DateFormat("EEE d MMM · HH:mm", 'es');
    final ownerName =
        appointment.ownerFullName?.trim().isNotEmpty == true
            ? appointment.ownerFullName!
            : '—';

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
            appointment.specialtyName,
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
            ElevatedButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Confirmar cita'),
                    content: const Text(
                      '¿Confirmas esta cita? El propietario verá el estado actualizado.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        child: const Text('Sí, confirmar'),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Confirmar cita'),
            ),
          ],
          if (showMarkDone && appointment.isConfirmed) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Marcar como realizada'),
                    content: const Text(
                      '¿Marcar esta cita como realizada?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        child: const Text('Sí, marcar'),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Marcar como realizada'),
            ),
          ],
          if (showDeleteButton && appointment.isCancelled) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Eliminar cita'),
                    content: const Text(
                      'Se borrará esta cita del historial. No se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          'Sí, eliminar',
                          style: TextStyle(color: Colors.red),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No se pudo eliminar: $e')),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Eliminar'),
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
    final config = switch (status) {
      'confirmed' => (label: 'Confirmada', color: AppTheme.primary),
      'cancelled' => (label: 'Cancelada', color: Colors.red),
      'done' => (label: 'Realizada', color: Colors.grey),
      _ => (label: 'Pendiente', color: Colors.orange),
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
