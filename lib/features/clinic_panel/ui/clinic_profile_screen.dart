import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../shared/appointment_duration.dart' show kAllowedAppointmentDurationsMinutes, kDefaultAppointmentDurationMinutes;
import '../../../shared/models/clinic.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/models/specialty.dart';
import '../../auth/providers/auth_provider.dart';
import '../../clinic/providers/clinic_provider.dart';
import '../providers/clinic_panel_provider.dart';

class ClinicProfileEditScreen extends ConsumerStatefulWidget {
  const ClinicProfileEditScreen({super.key});

  @override
  ConsumerState<ClinicProfileEditScreen> createState() =>
      _ClinicProfileScreenState();
}

class _ClinicProfileScreenState extends ConsumerState<ClinicProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _descCtrl;

  Set<String> _selectedSpecialtyIds = {};
  int _appointmentDurationMinutes = kDefaultAppointmentDurationMinutes;
  List<_DaySchedule> _weekSchedule = [];
  File? _pickedLogo;
  bool _saving = false;
  bool _initialized = false;
  bool _geocodeAutoScheduled = false;
  bool _geocodingInBackground = false;
  /// Evita quedar enganchados a otro perfil si cambia la clínica.
  String? _initializedForClinicId;
  _ClinicProfileBaseline? _baseline;
  Clinic? _loadedClinic;
  int _clinicNullAutoRetries = 0;
  bool _clinicNullRetryInFlight = false;
  bool _clinicNullRetryScheduled = false;
  static const _maxClinicNullAutoRetries = 2;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _descCtrl = TextEditingController();

    _weekSchedule = List.generate(
      7,
      (i) => _DaySchedule(dayOfWeek: i),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(clinicProfileExitHandlerProvider.notifier).state =
          _handleExitRequest;
    });
  }

  @override
  void dispose() {
    final exitHandlerNotifier =
        ref.read(clinicProfileExitHandlerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      exitHandlerNotifier.state = null;
    });
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _initFromClinic(Clinic clinic, List<Schedule> schedules) {
    final sameClinic = _initializedForClinicId == clinic.id;
    if (_initialized && sameClinic) return;
    if (!sameClinic) _geocodeAutoScheduled = false;
    _initialized = true;
    _initializedForClinicId = clinic.id;

    _nameCtrl.text = clinic.name;
    _addressCtrl.text = clinic.address;
    _cityCtrl.text = clinic.city;
    _phoneCtrl.text = clinic.phone ?? '';
    _emailCtrl.text = _resolveClinicEmail(clinic);
    _descCtrl.text = clinic.description ?? '';
    _selectedSpecialtyIds =
        clinic.specialties.map((s) => s.id).toSet();
    _appointmentDurationMinutes = clinic.appointmentDurationMinutes;

    _weekSchedule = List.generate(
      7,
      (i) => _DaySchedule(dayOfWeek: i),
    );
    for (final s in schedules) {
      if (s.dayOfWeek >= 0 && s.dayOfWeek < 7) {
        _weekSchedule[s.dayOfWeek] = _DaySchedule(
          dayOfWeek: s.dayOfWeek,
          active: true,
          openTime: _parseTime(s.openTime),
          closeTime: _parseTime(s.closeTime),
        );
      }
    }
    _loadedClinic = clinic;
    _captureBaseline();
  }

  void _captureBaseline() {
    _baseline = _ClinicProfileBaseline(
      name: _nameCtrl.text,
      address: _addressCtrl.text,
      city: _cityCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      description: _descCtrl.text,
      specialtyIds: Set<String>.from(_selectedSpecialtyIds),
      appointmentDurationMinutes: _appointmentDurationMinutes,
      weekSchedule: _weekSchedule.map((d) => d.copy()).toList(),
      pickedLogoPath: _pickedLogo?.path,
    );
  }

  void _restoreBaseline() {
    final b = _baseline;
    if (b == null) return;

    _nameCtrl.text = b.name;
    _addressCtrl.text = b.address;
    _cityCtrl.text = b.city;
    _phoneCtrl.text = b.phone;
    _emailCtrl.text = b.email;
    _descCtrl.text = b.description;
    _selectedSpecialtyIds = Set<String>.from(b.specialtyIds);
    _appointmentDurationMinutes = b.appointmentDurationMinutes;
    _weekSchedule = b.weekSchedule.map((d) => d.copy()).toList();
    _pickedLogo = b.pickedLogoPath != null ? File(b.pickedLogoPath!) : null;
  }

  bool _hasUnsavedChanges() => _baseline?.differsFrom(
        name: _nameCtrl.text,
        address: _addressCtrl.text,
        city: _cityCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        description: _descCtrl.text,
        specialtyIds: _selectedSpecialtyIds,
        appointmentDurationMinutes: _appointmentDurationMinutes,
        weekSchedule: _weekSchedule,
        pickedLogoPath: _pickedLogo?.path,
      ) ??
      false;

  Future<bool> _handleExitRequest() async {
    if (!_hasUnsavedChanges()) return true;
    if (!mounted) return true;

    final l10n = context.l10n;
    final action = await showDialog<_UnsavedExitAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesBody),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(ctx, _UnsavedExitAction.save),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(l10n.save),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pop(ctx, _UnsavedExitAction.discard),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(l10n.discardChanges),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    switch (action) {
      case _UnsavedExitAction.save:
        final clinic = _loadedClinic;
        if (clinic == null) return false;
        final ok = await _save(clinic);
        return ok;
      case _UnsavedExitAction.discard:
        setState(_restoreBaseline);
        return true;
      case null:
        return false;
    }
  }

  /// Email de la cuenta de registro; no editable en el formulario.
  String _resolveClinicEmail(Clinic clinic) {
    final stored = clinic.email?.trim();
    if (stored != null && stored.isNotEmpty) return stored;
    return ref.read(authRepositoryProvider).currentUser?.email?.trim() ?? '';
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _timeToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _timeLabel(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Registra lat/lng automáticamente si la clínica aún no tiene coordenadas
  /// (p. ej. registrada antes de activar la búsqueda geográfica).
  Future<void> _ensureGeocodedIfNeeded(Clinic clinic) async {
    if (clinic.lat != null && clinic.lng != null) return;
    if (clinic.city.trim().isEmpty) return;
    if (_geocodingInBackground) return;

    setState(() => _geocodingInBackground = true);
    try {
      final repo = ref.read(clinicRepositoryProvider);
      final coords = await repo.geocodeAddress(
        address: clinic.address,
        city: clinic.city,
      );
      if (!mounted || coords == null) return;

      await repo.upsertClinic(
        clinic.copyWith(lat: coords.lat, lng: coords.lng).toMap(),
      );
      ref.invalidate(myClinicProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.locationRegisteredSnack)),
        );
      }
    } finally {
      if (mounted) setState(() => _geocodingInBackground = false);
    }
  }

  Future<void> _pickLogo() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (picked != null) {
      setState(() => _pickedLogo = File(picked.path));
    }
  }

  Future<void> _reloadMyClinic() async {
    if (_clinicNullRetryInFlight) return;
    setState(() => _clinicNullRetryInFlight = true);
    try {
      ref.invalidate(myClinicProvider);
      await ref.read(myClinicProvider.future);
    } finally {
      if (mounted) setState(() => _clinicNullRetryInFlight = false);
    }
  }

  void _scheduleClinicNullAutoRetry() {
    if (_clinicNullRetryInFlight ||
        _clinicNullRetryScheduled ||
        _clinicNullAutoRetries >= _maxClinicNullAutoRetries) {
      return;
    }
    _clinicNullRetryScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _clinicNullRetryScheduled = false;
      if (!mounted) return;
      _clinicNullAutoRetries++;
      await _reloadMyClinic();
    });
  }

  Widget _buildClinicNotFoundBody(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.clinicProfileNotFound,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clinicNullRetryInFlight ? null : _reloadMyClinic,
              child: _clinicNullRetryInFlight
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _save(Clinic clinic) async {
    if (!_formKey.currentState!.validate()) return false;

    setState(() => _saving = true);

    try {
      final repo = ref.read(clinicRepositoryProvider);

      String? logoUrl = clinic.logoUrl;
      if (_pickedLogo != null) {
        logoUrl = await repo.uploadClinicLogo(
          clinicId: clinic.id,
          file: _pickedLogo!,
        );
      }

      final newAddress = _addressCtrl.text.trim();
      final newCity = _cityCtrl.text.trim();

      // Geocodificar solo si la dirección o ciudad ha cambiado, o si todavía
      // no hay coordenadas guardadas. Esto respeta el rate limit de Nominatim.
      double? lat = clinic.lat;
      double? lng = clinic.lng;
      final addressChanged =
          newAddress != clinic.address || newCity != clinic.city;
      var geocodeSucceeded = lat != null && lng != null;
      if (addressChanged || lat == null || lng == null) {
        final coords = await repo.geocodeAddress(
          address: newAddress,
          city: newCity,
        );
        if (coords != null) {
          lat = coords.lat;
          lng = coords.lng;
          geocodeSucceeded = true;
        } else {
          geocodeSucceeded = false;
        }
      }

      final updated = clinic.copyWith(
        name: _nameCtrl.text.trim(),
        address: newAddress,
        city: newCity,
        phone: _phoneCtrl.text.trim(),
        email: _resolveClinicEmail(clinic),
        description: _descCtrl.text.trim(),
        logoUrl: logoUrl,
        lat: lat,
        lng: lng,
        appointmentDurationMinutes: _appointmentDurationMinutes,
      );

      await repo.upsertClinic(updated.toMap());

      await repo.updateSpecialties(
        clinic.id,
        _selectedSpecialtyIds.toList(),
      );

      final activeSchedules = _weekSchedule
          .where((d) => d.active)
          .map((d) => Schedule(
                clinicId: clinic.id,
                dayOfWeek: d.dayOfWeek,
                openTime: _timeToString(d.openTime),
                closeTime: _timeToString(d.closeTime),
              ))
          .toList();

      await repo.upsertSchedules(clinic.id, activeSchedules);

      ref.invalidate(myClinicProvider);
      ref.invalidate(mySchedulesProvider);
      invalidateClinicBookingData(ref, clinic.id);

      if (mounted) {
        _captureBaseline();
        final l10n = context.l10n;
        final msg = geocodeSucceeded
            ? l10n.profileUpdated
            : l10n.profileSavedNoLocation;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: geocodeSucceeded ? null : Colors.orange.shade800,
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        showAppError(context, e);
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final clinicAsync = ref.watch(myClinicProvider);
    final schedulesAsync = ref.watch(mySchedulesProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return clinicAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(appErrorMessage(context, e))),
      ),
      data: (clinic) {
        if (clinic == null) {
          if (_clinicNullAutoRetries < _maxClinicNullAutoRetries) {
            _scheduleClinicNullAutoRetry();
          }
          return Scaffold(
            appBar: AppBar(title: Text(l10n.myClinicTitle)),
            body: _clinicNullRetryInFlight ||
                    _clinicNullAutoRetries < _maxClinicNullAutoRetries
                ? const Center(child: CircularProgressIndicator())
                : _buildClinicNotFoundBody(context),
          );
        }

        // [myClinicProvider] suele resolverse antes que [mySchedulesProvider].
        // Si inicializamos con schedules vacíos, _initialized queda true y los
        // horarios guardados nunca se cargan. Esperar a tener datos de horarios.
        return schedulesAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.myClinicTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: Text(l10n.myClinicTitle)),
            body: Center(child: Text(appErrorMessage(context, e))),
          ),
          data: (schedules) {
            _initFromClinic(clinic, schedules);

            if (!_geocodeAutoScheduled) {
              _geocodeAutoScheduled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _ensureGeocodedIfNeeded(clinic);
              });
            }

            return PopScope(
              canPop: !_hasUnsavedChanges(),
              onPopInvokedWithResult: (didPop, _) async {
                if (didPop) return;
                final canLeave = await _handleExitRequest();
                if (!mounted || !canLeave) return;
                Navigator.of(context).pop();
              },
              child: Scaffold(
              appBar: AppBar(
                title: Text(l10n.myClinicTitle),
                actions: [
                  _saving
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: () => _save(clinic),
                          icon: const Icon(Icons.check_rounded),
                          tooltip: l10n.saveTooltip,
                        ),
                ],
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    if (clinic.lat == null || clinic.lng == null)
                      _buildLocationBanner(clinic),
                    _buildLogoSection(clinic),
                    const SizedBox(height: 24),
                    _buildInfoSection(),
                    const SizedBox(height: 24),
                    _buildSpecialtiesSection(
                      specialtiesAsync.valueOrNull ?? [],
                    ),
                    const SizedBox(height: 24),
                    _buildAppointmentDurationSection(),
                    const SizedBox(height: 24),
                    _buildScheduleSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(clinic),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocationBanner(Clinic clinic) {
    final l10n = context.l10n;
    final hasAddress = clinic.city.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_off_rounded, color: Colors.amber.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _geocodingInBackground
                  ? l10n.registeringLocation
                  : hasAddress
                      ? l10n.locationBannerNeedsSave
                      : l10n.locationBannerEnterCity,
              style: TextStyle(
                fontSize: 13,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logo ────────────────────────────────────────────────────────

  Widget _buildLogoSection(Clinic clinic) {
    final hasLogo = _pickedLogo != null || (clinic.logoUrl?.isNotEmpty ?? false);

    return Center(
      child: GestureDetector(
        onTap: _pickLogo,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: AppTheme.surface,
              backgroundImage: _pickedLogo != null
                  ? FileImage(_pickedLogo!)
                  : (clinic.logoUrl != null && clinic.logoUrl!.isNotEmpty
                      ? NetworkImage(clinic.logoUrl!) as ImageProvider
                      : null),
              child: !hasLogo
                  ? const Icon(Icons.storefront_rounded,
                      size: 40, color: AppTheme.textSecondary)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info básica ─────────────────────────────────────────────────

  Widget _buildInfoSection() {
    final l10n = context.l10n;
    return _Section(
      title: l10n.basicInformation,
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: l10n.clinicName,
            prefixIcon: const Icon(Icons.business_rounded),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressCtrl,
          decoration: InputDecoration(
            labelText: l10n.address,
            prefixIcon: const Icon(Icons.location_on_rounded),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cityCtrl,
          decoration: InputDecoration(
            labelText: l10n.city,
            prefixIcon: const Icon(Icons.location_city_rounded),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.phone,
            prefixIcon: const Icon(Icons.phone_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailCtrl,
          readOnly: true,
          enableInteractiveSelection: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.contactEmail,
            prefixIcon: const Icon(Icons.email_rounded),
            filled: true,
            fillColor: AppTheme.surface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.description,
            prefixIcon: const Icon(Icons.description_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Especialidades ──────────────────────────────────────────────

  Widget _buildSpecialtiesSection(List<Specialty> catalog) {
    final l10n = context.l10n;
    return _Section(
      title: l10n.specialties,
      children: [
        if (catalog.isEmpty)
          Text(l10n.loadingSpecialties)
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: catalog.map((s) {
              final selected = _selectedSpecialtyIds.contains(s.id);
              return FilterChip(
                label: Text(s.name),
                selected: selected,
                selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                checkmarkColor: AppTheme.primary,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedSpecialtyIds.add(s.id);
                    } else {
                      _selectedSpecialtyIds.remove(s.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── Duración de citas ───────────────────────────────────────────

  Widget _buildAppointmentDurationSection() {
    final l10n = context.l10n;
    return _Section(
      title: l10n.appointmentDurationTitle,
      children: [
        Text(
          l10n.appointmentDurationHelp,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: _appointmentDurationMinutes,
          decoration: InputDecoration(
            labelText: l10n.durationPerAppointment,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          items: kAllowedAppointmentDurationsMinutes
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(formatAppointmentDurationLabel(m, l10n)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _appointmentDurationMinutes = value);
          },
        ),
      ],
    );
  }

  // ── Horarios ────────────────────────────────────────────────────

  Widget _buildScheduleSection() {
    final l10n = context.l10n;
    final dayNames = weekdayNames(l10n);
    return _Section(
      title: l10n.weeklyHours,
      children: List.generate(7, (i) {
        final day = _weekSchedule[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Switch(
                  value: day.active,
                  activeTrackColor: AppTheme.primary,
                  onChanged: (v) => setState(
                    () => _weekSchedule[i] = day.copyWith(active: v),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: Text(
                  dayNames[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: day.active
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
              if (day.active) ...[
                _timePill(
                  label: _timeLabel(day.openTime),
                  onTap: () => _pickTime(i, isOpen: true),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('–'),
                ),
                _timePill(
                  label: _timeLabel(day.closeTime),
                  onTap: () => _pickTime(i, isOpen: false),
                ),
              ] else
                Text(
                  l10n.closed,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _timePill({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Future<void> _pickTime(int dayIndex, {required bool isOpen}) async {
    final current = isOpen
        ? _weekSchedule[dayIndex].openTime
        : _weekSchedule[dayIndex].closeTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isOpen) {
          _weekSchedule[dayIndex] =
              _weekSchedule[dayIndex].copyWith(openTime: picked);
        } else {
          _weekSchedule[dayIndex] =
              _weekSchedule[dayIndex].copyWith(closeTime: picked);
        }
      });
    }
  }

  // ── Botones ─────────────────────────────────────────────────────

  Widget _buildSaveButton(Clinic clinic) {
    return ElevatedButton.icon(
      onPressed: _saving ? null : () => _save(clinic),
      icon: const Icon(Icons.save_rounded, size: 18),
      label: Text(context.l10n.saveChanges),
    );
  }

}

// ── Helpers ──────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _DaySchedule {
  final int dayOfWeek;
  final bool active;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const _DaySchedule({
    required this.dayOfWeek,
    this.active = false,
    this.openTime = const TimeOfDay(hour: 9, minute: 0),
    this.closeTime = const TimeOfDay(hour: 19, minute: 0),
  });

  _DaySchedule copyWith({
    bool? active,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  }) =>
      _DaySchedule(
        dayOfWeek: dayOfWeek,
        active: active ?? this.active,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
      );

  _DaySchedule copy() => _DaySchedule(
        dayOfWeek: dayOfWeek,
        active: active,
        openTime: openTime,
        closeTime: closeTime,
      );

  bool sameAs(_DaySchedule other) =>
      active == other.active &&
      openTime.hour == other.openTime.hour &&
      openTime.minute == other.openTime.minute &&
      closeTime.hour == other.closeTime.hour &&
      closeTime.minute == other.closeTime.minute;
}

enum _UnsavedExitAction { save, discard }

class _ClinicProfileBaseline {
  final String name;
  final String address;
  final String city;
  final String phone;
  final String email;
  final String description;
  final Set<String> specialtyIds;
  final int appointmentDurationMinutes;
  final List<_DaySchedule> weekSchedule;
  final String? pickedLogoPath;

  const _ClinicProfileBaseline({
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.description,
    required this.specialtyIds,
    required this.appointmentDurationMinutes,
    required this.weekSchedule,
    required this.pickedLogoPath,
  });

  bool differsFrom({
    required String name,
    required String address,
    required String city,
    required String phone,
    required String email,
    required String description,
    required Set<String> specialtyIds,
    required int appointmentDurationMinutes,
    required List<_DaySchedule> weekSchedule,
    required String? pickedLogoPath,
  }) {
    if (name != this.name) return true;
    if (address != this.address) return true;
    if (city != this.city) return true;
    if (phone != this.phone) return true;
    if (email != this.email) return true;
    if (description != this.description) return true;
    if (pickedLogoPath != this.pickedLogoPath) return true;
    if (specialtyIds.length != this.specialtyIds.length) return true;
    if (!specialtyIds.containsAll(this.specialtyIds)) return true;
    if (appointmentDurationMinutes != this.appointmentDurationMinutes) {
      return true;
    }
    for (var i = 0; i < weekSchedule.length; i++) {
      if (!weekSchedule[i].sameAs(this.weekSchedule[i])) return true;
    }
    return false;
  }
}
