import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/lockout_manager.dart';

import '../../support/memory_secure_value_store.dart';

void main() {
  group('LockoutManager', () {
    test('starts a 30-second lock after five failed attempts', () async {
      var now = DateTime.utc(2026, 1, 1);
      final manager = _createManager(MemorySecureValueStore(), () => now);

      for (var attempt = 0; attempt < 4; attempt++) {
        final state = await manager.recordFailure();
        expect(state.lockedUntil, isNull);
      }
      final fifthFailure = await manager.recordFailure();

      expect(fifthFailure.failedAttempts, 5);
      expect(fifthFailure.lockedUntil, now.add(const Duration(seconds: 30)));
      expect(fifthFailure.remainingAt(now), const Duration(seconds: 30));
    });

    test(
      'escalates lockouts through one minute, five, fifteen, and sixty minutes',
      () async {
        var now = DateTime.utc(2026, 1, 1);
        final manager = _createManager(MemorySecureValueStore(), () => now);
        const expectedDurations = <Duration>[
          Duration(seconds: 30),
          Duration(minutes: 1),
          Duration(minutes: 5),
          Duration(minutes: 15),
          Duration(hours: 1),
        ];

        for (var failedAttempt = 1; failedAttempt <= 9; failedAttempt++) {
          final state = await manager.recordFailure();
          if (failedAttempt < 5) {
            expect(state.lockedUntil, isNull);
            continue;
          }

          final expectedDuration = expectedDurations[failedAttempt - 5];
          expect(state.lockedUntil, now.add(expectedDuration));
          now = state.lockedUntil!;
        }
      },
    );

    test(
      'persists failed attempts and active lockout across instances',
      () async {
        var now = DateTime.utc(2026, 1, 1);
        final secureValues = MemorySecureValueStore();
        final manager = _createManager(secureValues, () => now);
        for (var attempt = 0; attempt < 5; attempt++) {
          await manager.recordFailure();
        }

        final reopenedManager = _createManager(secureValues, () => now);
        final restored = await reopenedManager.loadState();

        expect(restored.failedAttempts, 5);
        expect(restored.lockedUntil, now.add(const Duration(seconds: 30)));
      },
    );

    test('does not count another failure while a lockout is active', () async {
      var now = DateTime.utc(2026, 1, 1);
      final manager = _createManager(MemorySecureValueStore(), () => now);
      for (var attempt = 0; attempt < 5; attempt++) {
        await manager.recordFailure();
      }

      final state = await manager.recordFailure();

      expect(state.failedAttempts, 5);
      expect(state.lockedUntil, now.add(const Duration(seconds: 30)));
    });

    test('counts simultaneous failures without losing attempts', () async {
      final manager = _createManager(
        MemorySecureValueStore(),
        () => DateTime.utc(2026, 1, 1),
      );

      await Future.wait(
        List<Future<LockoutState>>.generate(5, (_) => manager.recordFailure()),
      );

      final state = await manager.loadState();
      expect(state.failedAttempts, 5);
      expect(
        state.lockedUntil,
        DateTime.utc(2026, 1, 1).add(const Duration(seconds: 30)),
      );
    });

    test('clears failed attempts after a successful authentication', () async {
      final now = DateTime.utc(2026, 1, 1);
      final manager = _createManager(MemorySecureValueStore(), () => now);
      for (var attempt = 0; attempt < 5; attempt++) {
        await manager.recordFailure();
      }

      final state = await manager.recordSuccess();

      expect(state.failedAttempts, 0);
      expect(state.lockedUntil, isNull);
    });
  });
}

LockoutManager _createManager(
  MemorySecureValueStore secureValues,
  DateTime Function() clock,
) {
  return LockoutManager(
    store: SecureLockoutStateStore(secureValues),
    clock: clock,
  );
}
