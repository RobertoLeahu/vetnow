import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import '../../../app/theme.dart';
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
    final appointmentsAsync = ref.watch(myAppointmentsProvider);
    final petsAsync = ref.watch(myPetsProvider);
    final selectedPetId = ref.watch(selectedPetFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
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
                        decoration: const InputDecoration(
                          labelText: 'Mascota',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todas las mascotas'),
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
                      error: (_, __) => const SizedBox(
                        height: 40,
                        child: Center(child: Text('No se pudieron cargar mascotas')),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _TabChip(
                            label: 'Programadas ($upcoming)',
                            index: 0,
                            controller: _tabController,
                          ),
                          const SizedBox(width: 8),
                          _TabChip(
                            label: 'Realizadas ($done)',
                            index: 1,
                            controller: _tabController,
                          ),
                          const SizedBox(width: 8),
                          _TabChip(
                            label: 'Canceladas ($cancelled)',
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
          final upcoming = filteredAll.where((a) => a.isUpcoming).toList();
          final done = filteredAll.where((a) => a.isDone).toList();
          final cancelled = filteredAll.where((a) => a.isCancelled).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _AppointmentList(
                appointments: upcoming,
                emptyTitle: 'No tienes citas programadas',
                emptySubtitle: 'Reserva una cita y aparecerá aquí.',
              ),
              _AppointmentList(
                appointments: done,
                emptyTitle: 'No tienes citas realizadas',
                emptySubtitle: 'Aquí verás el historial de tus visitas.',
              ),
              _AppointmentList(
                appointments: cancelled,
                emptyTitle: 'No tienes citas canceladas',
                emptySubtitle: '',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<Appointment> _filterByPet(List<Appointment> all, String? selectedPetId) {
    if (selectedPetId == null) return all;
    return all.where((a) => a.petId == selectedPetId).toList();
  }
}

class _AppointmentList extends ConsumerWidget {
  final List<Appointment> appointments;
  final String emptyTitle;
  final String emptySubtitle;

  const _AppointmentList({
    required this.appointments,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appointments.isEmpty) {
      return Center(
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
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AppointmentCard(appointment: appointments[i]),
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat("EEE d MMM · HH:mm", 'es');

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
              Text(
                appointment.petName,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
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
                    title: const Text('Cancelar cita'),
                    content: const Text(
                      '¿Seguro que quieres cancelar esta cita?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          'Sí, cancelar',
                          style: TextStyle(color: Colors.red),
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
              child: const Text('Cancelar cita'),
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
