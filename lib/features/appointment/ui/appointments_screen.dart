import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _TabChip(
                  label: 'Programadas (0)',
                  index: 0,
                  controller: _tabController,
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Realizadas (0)',
                  index: 1,
                  controller: _tabController,
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Canceladas (0)',
                  index: 2,
                  controller: _tabController,
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EmptyAppointments(
            title: 'No tienes citas programadas',
            subtitle: 'Reserva una cita y aparecerá en esta sección.',
          ),
          _EmptyAppointments(
            title: 'No tienes citas realizadas',
            subtitle: 'Aquí verás el historial de tus visitas.',
          ),
          _EmptyAppointments(title: 'No tienes citas canceladas', subtitle: ''),
        ],
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

class _EmptyAppointments extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyAppointments({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 80,
              color: AppTheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
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
}
