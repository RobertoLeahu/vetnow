import 'dart:async';

import 'package:flutter/widgets.dart';

/// Refresca citas periódicamente y al volver de background.
/// Llama [onSync] cada minuto y en `AppLifecycleState.resumed`.
class AppointmentSyncScheduler {
  AppointmentSyncScheduler({required this.onSync});

  final VoidCallback onSync;

  static const _syncInterval = Duration(minutes: 1);

  Timer? _timer;
  _ResumeObserver? _lifecycleObserver;

  void start() {
    _lifecycleObserver = _ResumeObserver(onSync);
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
    _timer = Timer.periodic(_syncInterval, (_) => onSync());
  }

  void stop() {
    _timer?.cancel();
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
      _lifecycleObserver = null;
    }
  }
}

class _ResumeObserver with WidgetsBindingObserver {
  _ResumeObserver(this._onResume);

  final VoidCallback _onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResume();
    }
  }
}
