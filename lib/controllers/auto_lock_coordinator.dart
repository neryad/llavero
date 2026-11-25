import 'dart:async';

import 'settings_controller.dart';

typedef AutoLockTimerFactory =
    AutoLockTimer Function(Duration delay, void Function() callback);

abstract interface class AutoLockTimer {
  void cancel();
}

/// Applies the configured lock delay across app background/foreground changes.
class AutoLockCoordinator {
  AutoLockCoordinator({
    required this.settings,
    required this.isVaultUnlocked,
    required this.lockVault,
    DateTime Function()? clock,
    AutoLockTimerFactory? timerFactory,
  }) : _clock = clock ?? DateTime.now,
       _timerFactory = timerFactory ?? _createTimer;

  final SettingsController settings;
  final bool Function() isVaultUnlocked;
  final void Function() lockVault;
  final DateTime Function() _clock;
  final AutoLockTimerFactory _timerFactory;
  AutoLockTimer? _timer;
  DateTime? _backgroundedAt;
  bool _disposed = false;

  void onBackgrounded() {
    if (_disposed) {
      return;
    }
    _cancelTimer();
    if (!isVaultUnlocked()) {
      return;
    }

    final delay = settings.autoLockDuration.duration;
    _backgroundedAt = _clock();
    if (delay == Duration.zero) {
      _backgroundedAt = null;
      lockVault();
      return;
    }

    _timer = _timerFactory(delay, () {
      _timer = null;
      _backgroundedAt = null;
      if (!_disposed && isVaultUnlocked()) {
        lockVault();
      }
    });
  }

  void onForegrounded() {
    final backgroundedAt = _backgroundedAt;
    _cancelTimer();
    _backgroundedAt = null;
    if (backgroundedAt == null || !isVaultUnlocked()) {
      return;
    }
    if (_clock().difference(backgroundedAt) >=
        settings.autoLockDuration.duration) {
      lockVault();
    }
  }

  void dispose() {
    _disposed = true;
    _cancelTimer();
    _backgroundedAt = null;
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static AutoLockTimer _createTimer(Duration delay, void Function() callback) {
    return _DartAutoLockTimer(Timer(delay, callback));
  }
}

class _DartAutoLockTimer implements AutoLockTimer {
  const _DartAutoLockTimer(this._timer);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
