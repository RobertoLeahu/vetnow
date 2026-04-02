import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import '../data/appointment_repository.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/specialty.dart';
import '../../../shared/models/pet.dart';
import '../../../app/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/clinic/providers/clinic_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String clinicId;
  final Specialty specialty;
  const BookingScreen({
    super.key,
    required this.clinicId,
    required this.specialty,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _step = 0; // 0: fecha, 1: hora, 2: mascota, 3: confirmar

  DateTime? _selectedDate;
  DateTime? _selectedSlot;
  Pet? _selectedPet;
  bool _loading = false;

  List<DateTime> _generateSlots(DateTime date) {
    final slots = <DateTime>[];
    var current = DateTime(date.year, date.month, date.day, 9, 0);
    final end = DateTime(date.year, date.month, date.day, 19, 0);
    while (current.isBefore(end)) {
      slots.add(current);
      current = current.add(const Duration(minutes: 30));
    }
    return slots;
  }

  Future<void> _confirm() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null || _selectedSlot == null || _selectedPet == null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(appointmentRepositoryProvider)
          .createAppointment(
            clinicId: widget.clinicId,
            petId: _selectedPet!.id,
            ownerId: user.id,
            specialtyId: widget.specialty.id,
            scheduledAt: _selectedSlot!,
          );
      ref.invalidate(myAppointmentsProvider);
      ref.invalidate(bookedSlotsProvider);
      if (mounted) _showSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reservar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess() {
    final slot = _selectedSlot!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.primary,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Cita reservada!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat("d 'de' MMMM 'a las' HH:mm", 'es').format(slot),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // 👈 cierra el dialog
              GoRouter.of(dialogContext).go('/appointments'); // 👈 navega
            },
            child: const Text('Ver mis citas'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicAsync = ref.watch(clinicDetailProvider(widget.clinicId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar cita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _step == 0
              ? () => context.pop()
              : () => setState(() => _step--),
        ),
      ),
      body: clinicAsync.when(
        data: (clinic) {
          if (clinic == null) {
            return const Center(child: Text('Clínica no encontrada'));
          }
          return Column(
            children: [
              _StepIndicator(currentStep: _step),
              Expanded(child: _buildStep(clinic)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStep(Clinic clinic) {
    switch (_step) {
      case 0:
        return _StepDate(
          selectedDate: _selectedDate,
          onSelect: (d) => setState(() {
            _selectedDate = d;
            _selectedSlot = null;
            _step = 1;
          }),
        );
      case 1:
        return _StepTime(
          clinicId: widget.clinicId,
          date: _selectedDate!,
          slots: _generateSlots(_selectedDate!),
          selectedSlot: _selectedSlot,
          onSelect: (s) => setState(() {
            _selectedSlot = s;
            _step = 2;
          }),
        );
      case 2:
        return _StepPet(
          selectedPet: _selectedPet,
          onSelect: (p) => setState(() {
            _selectedPet = p;
            _step = 3;
          }),
        );
      case 3:
        return _StepConfirm(
          clinic: clinic,
          specialty: widget.specialty,
          slot: _selectedSlot!,
          pet: _selectedPet!,
          loading: _loading,
          onConfirm: _confirm,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Indicador de pasos ───────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(4, (i) {
          final active = i == currentStep;
          final completed = i < currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: completed || active
                    ? AppTheme.primary
                    : AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Paso 0: Fecha ────────────────────────────────────────────────────────────

class _StepDate extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelect;
  const _StepDate({required this.selectedDate, required this.onSelect});

  @override
  State<_StepDate> createState() => _StepDateState();
}

class _StepDateState extends State<_StepDate> {
  late DateTime _focusedMonth;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selected = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    return Column(
      children: [
        // Cabecera mes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy', 'es').format(_focusedMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Días de semana
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: ['D', 'L', 'M', 'X', 'J', 'V', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Grid de días
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < firstWeekday) return const SizedBox.shrink();
              final day = i - firstWeekday + 1;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              final isPast = date.isBefore(
                DateTime(today.year, today.month, today.day),
              );
              final isSelected =
                  _selected != null && DateUtils.isSameDay(date, _selected);
              final isToday = DateUtils.isSameDay(date, today);

              return GestureDetector(
                onTap: isPast ? null : () => setState(() => _selected = date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : isToday
                        ? AppTheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isPast
                            ? AppTheme.divider
                            : isSelected
                            ? Colors.white
                            : AppTheme.textPrimary,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Spacer(),
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => widget.onSelect(_selected!),
              child: Text(
                "Continuar con el ${DateFormat("d 'de' MMMM", 'es').format(_selected!)}",
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Paso 1: Hora ─────────────────────────────────────────────────────────────

class _StepTime extends ConsumerStatefulWidget {
  final String clinicId;
  final DateTime date;
  final List<DateTime> slots;
  final DateTime? selectedSlot;
  final ValueChanged<DateTime> onSelect;

  const _StepTime({
    required this.clinicId,
    required this.date,
    required this.slots,
    required this.selectedSlot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookedAsync = ref.watch(
      bookedSlotsProvider((clinicId: clinicId, date: date)),
    );

    return bookedAsync.when(
      data: (booked) {
        final bookedTimes = booked
            .map((d) => '${d.hour}:${d.minute.toString().padLeft(2, '0')}')
            .toSet();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Selecciona una hora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: slots.length,
              itemBuilder: (_, i) {
                final slot = slots[i];
                final timeKey =
                    '${slot.hour}:${slot.minute.toString().padLeft(2, '0')}';
                final isBooked = bookedTimes.contains(timeKey);
                final isSelected =
                    selectedSlot != null &&
                    DateUtils.isSameDay(slot, selectedSlot!) &&
                    slot.hour == selectedSlot!.hour &&
                    slot.minute == selectedSlot!.minute;

                return GestureDetector(
                  onTap: isBooked ? null : () => onSelect(slot),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isBooked
                          ? AppTheme.surface
                          : isSelected
                          ? AppTheme.primary
                          : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.divider,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('HH:mm').format(slot),
                        style: TextStyle(
                          color: isBooked
                              ? AppTheme.divider
                              : isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  @override
  ConsumerState<_StepTime> createState() => _StepTimeState();
}

class _StepTimeState extends ConsumerState<_StepTime> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(bookedSlotsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookedAsync = ref.watch(
      bookedSlotsProvider((clinicId: widget.clinicId, date: widget.date)),
    );

    return bookedAsync.when(
      data: (booked) {
        final bookedTimes = booked
            .map((d) => '${d.hour}:${d.minute.toString().padLeft(2, '0')}')
            .toSet();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Selecciona una hora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.slots.length,
              itemBuilder: (_, i) {
                final slot = widget.slots[i];
                final timeKey =
                    '${slot.hour}:${slot.minute.toString().padLeft(2, '0')}';
                final isBooked = bookedTimes.contains(timeKey);
                final isSelected =
                    widget.selectedSlot != null &&
                    DateUtils.isSameDay(slot, widget.selectedSlot!) &&
                    slot.hour == widget.selectedSlot!.hour &&
                    slot.minute == widget.selectedSlot!.minute;

                return GestureDetector(
                  onTap: isBooked ? null : () => widget.onSelect(slot),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isBooked
                          ? AppTheme.surface
                          : isSelected
                          ? AppTheme.primary
                          : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.divider,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('HH:mm').format(slot),
                        style: TextStyle(
                          color: isBooked
                              ? AppTheme.divider
                              : isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// ─── Paso 2: Mascota ──────────────────────────────────────────────────────────

class _StepPet extends ConsumerWidget {
  final Pet? selectedPet;
  final ValueChanged<Pet> onSelect;
  const _StepPet({required this.selectedPet, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(myPetsProvider);

    return petsAsync.when(
      data: (pets) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '¿Para qué mascota es la cita?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (pets.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.pets_rounded,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No tienes mascotas registradas',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/pets'),
                    child: const Text('Añadir mascota'),
                  ),
                ],
              ),
            )
          else
            ...pets.map(
              (p) => _SelectionTile(
                title: p.name,
                subtitle: p.breed,
                icon: Icons.pets_rounded,
                selected: selectedPet?.id == p.id,
                onTap: () => onSelect(p),
              ),
            ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// ─── Paso 3: Confirmación ─────────────────────────────────────────────────────

class _StepConfirm extends StatelessWidget {
  final Clinic clinic;
  final Specialty specialty;
  final DateTime slot;
  final Pet pet;
  final bool loading;
  final VoidCallback onConfirm;

  const _StepConfirm({
    required this.clinic,
    required this.specialty,
    required this.slot,
    required this.pet,
    required this.loading,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Resumen de la cita',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _SummaryCard(
          children: [
            _SummaryRow(
              icon: Icons.local_hospital_rounded,
              label: 'Clínica',
              value: clinic.name,
            ),
            _SummaryRow(
              icon: Icons.medical_services_rounded,
              label: 'Especialidad',
              value: specialty.name,
            ),
            _SummaryRow(
              icon: Icons.calendar_today_rounded,
              label: 'Fecha',
              value: DateFormat("EEEE d 'de' MMMM", 'es').format(slot),
            ),
            _SummaryRow(
              icon: Icons.access_time_rounded,
              label: 'Hora',
              value: DateFormat('HH:mm').format(slot),
            ),
            _SummaryRow(
              icon: Icons.pets_rounded,
              label: 'Mascota',
              value: pet.name,
            ),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: loading ? null : onConfirm,
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Confirmar reserva'),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<Widget> children;
  const _SummaryCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget reutilizable: tile de selección ───────────────────────────────────

class _SelectionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.divider,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
