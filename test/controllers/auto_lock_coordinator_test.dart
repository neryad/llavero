import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/controllers/auto_lock_coordinator.dart';
import 'package:llavero/controllers/settings_controller.dart';

import '../support/memory_secure_value_store.dart';

void main() {
  group('AutoLockCoordinator', () {
    test('locks immediately when the configured delay is zero', () async {
      final settings = SettingsController(store: MemorySecureValueStore());
      await settings.initialize();
      var isLocked = false;
      final timers = <_FakeAutoLockTimer>[];
      final coordinator = AutoLockCoordinator(
        settings: settings,
        isVaultUnlocked: () => !isLocked,
        lockVault: () => isLocked = true,
        timerFactory: (delay, callback) {
          final timer = _FakeAutoLockTimer(delay, callback);
          timers.add(timer);
          return timer;
        },
      );
      addTearDown(() {
        coordinator.dispose();
        settings.dispose();
      });

      coordinator.onBackgrounded();

      expect(isLocked, isTrue);
      expect(timers, isEmpty);
    });

    test(
      'locks after the selected delay while the app stays backgrounded',
      () async {
        final settings = SettingsController(store: MemorySecureValueStore());
        await settings.initialize();
        await settings.setAutoLockDuration(AutoLockDuration.minute1);
        var isLocked = false;
        _FakeAutoLockTimer? timer;
        final coordinator = AutoLockCoordinator(
          settings: settings,
          isVaultUnlocked: () => !isLocked,
          lockVault: () => isLocked = true,
          timerFactory: (delay, callback) =>
              timer = _FakeAutoLockTimer(delay, callback),
        );
        addTearDown(() {
          coordinator.dispose();
          settings.dispose();
        });

        coordinator.onBackgrounded();

        expect(isLocked, isFalse);
        expect(timer?.delay, const Duration(minutes: 1));
        timer!.fire();
        expect(isLocked, isTrue);
      },
    );

    test(
      'cancels the pending lock when the app returns to foreground',
      () async {
        final settings = SettingsController(store: MemorySecureValueStore());
        await settings.initialize();
        await settings.setAutoLockDuration(AutoLockDuration.seconds30);
        var isLocked = false;
        _FakeAutoLockTimer? timer;
        final coordinator = AutoLockCoordinator(
          settings: settings,
          isVaultUnlocked: () => !isLocked,
          lockVault: () => isLocked = true,
          timerFactory: (delay, callback) =>
              timer = _FakeAutoLockTimer(delay, callback),
        );
        addTearDown(() {
          coordinator.dispose();
          settings.dispose();
        });

        coordinator.onBackgrounded();
        coordinator.onForegrounded();
        timer!.fire();

        expect(timer!.isCancelled, isTrue);
        expect(isLocked, isFalse);
      },
    );

    test(
      'locks on return if the device suspended the timer past its deadline',
      () async {
        final settings = SettingsController(store: MemorySecureValueStore());
        await settings.initialize();
        await settings.setAutoLockDuration(AutoLockDuration.seconds30);
        var now = DateTime.utc(2026, 11, 25);
        var isLocked = false;
        final coordinator = AutoLockCoordinator(
          settings: settings,
          isVaultUnlocked: () => !isLocked,
          lockVault: () => isLocked = true,
          clock: () => now,
          timerFactory: (delay, callback) =>
              _FakeAutoLockTimer(delay, callback),
        );
        addTearDown(() {
          coordinator.dispose();
          settings.dispose();
        });

        coordinator.onBackgrounded();
        now = now.add(const Duration(seconds: 31));
        coordinator.onForegrounded();

        expect(isLocked, isTrue);
      },
    );
  });
}

class _FakeAutoLockTimer implements AutoLockTimer {
  _FakeAutoLockTimer(this.delay, this.callback);

  final Duration delay;
  final void Function() callback;
  bool isCancelled = false;

  void fire() {
    if (!isCancelled) {
      callback();
    }
  }

  @override
  void cancel() => isCancelled = true;
}
