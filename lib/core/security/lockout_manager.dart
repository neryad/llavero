import 'dart:async';
import 'dart:convert';

import 'secure_value_store.dart';

/// A serializable record of failed PIN attempts and the active lockout.
class LockoutState {
  const LockoutState({required this.failedAttempts, this.lockedUntil});

  static const LockoutState empty = LockoutState(failedAttempts: 0);

  final int failedAttempts;
  final DateTime? lockedUntil;

  Duration remainingAt(DateTime now) {
    final expiry = lockedUntil;
    if (expiry == null || !expiry.isAfter(now)) {
      return Duration.zero;
    }
    return expiry.difference(now);
  }
}

/// Persistence boundary for lockout state.
abstract interface class LockoutStateStore {
  Future<LockoutState> read();

  Future<void> write(LockoutState state);
}

/// Stores the entire lockout state in one secure-storage value.
class SecureLockoutStateStore implements LockoutStateStore {
  SecureLockoutStateStore(this._secureValues);

  static const String storageKey = 'llavero.lockout-state.v1';

  final SecureValueStore _secureValues;

  @override
  Future<LockoutState> read() async {
    final encoded = await _secureValues.read(storageKey);
    if (encoded == null) {
      return LockoutState.empty;
    }

    try {
      final value = jsonDecode(encoded);
      if (value is! Map<String, dynamic>) {
        throw const FormatException();
      }
      final failedAttempts = value['failedAttempts'];
      final lockedUntil = value['lockedUntilEpochMillis'];
      if (failedAttempts is! int ||
          failedAttempts < 0 ||
          (lockedUntil != null && lockedUntil is! int) ||
          (failedAttempts < 5 && lockedUntil != null)) {
        throw const FormatException();
      }

      return LockoutState(
        failedAttempts: failedAttempts,
        lockedUntil: lockedUntil == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                lockedUntil as int,
                isUtc: true,
              ),
      );
    } on FormatException {
      throw const CorruptLockoutStateException();
    }
  }

  @override
  Future<void> write(LockoutState state) {
    final value = <String, Object?>{
      'failedAttempts': state.failedAttempts,
      'lockedUntilEpochMillis': state.lockedUntil
          ?.toUtc()
          .millisecondsSinceEpoch,
    };
    return _secureValues.write(storageKey, jsonEncode(value));
  }
}

/// Applies the persisted escalating lockout policy after incorrect PINs.
class LockoutManager {
  LockoutManager({required this.store, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const int firstLockoutAttempt = 5;
  static const List<Duration> lockoutDurations = <Duration>[
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(hours: 1),
  ];

  final LockoutStateStore store;
  final DateTime Function() _clock;
  Future<void> _pendingWrite = Future<void>.value();

  Future<LockoutState> loadState() => store.read();

  Future<LockoutState> recordFailure() => _serialize(_recordFailure);

  Future<LockoutState> _recordFailure() async {
    final current = await store.read();
    final now = _clock().toUtc();
    if (current.remainingAt(now) > Duration.zero) {
      return current;
    }

    final failedAttempts = current.failedAttempts + 1;
    final lockedUntil = failedAttempts < firstLockoutAttempt
        ? null
        : now.add(_durationForAttempt(failedAttempts));
    final updated = LockoutState(
      failedAttempts: failedAttempts,
      lockedUntil: lockedUntil,
    );
    await store.write(updated);
    return updated;
  }

  Future<LockoutState> recordSuccess() => _serialize(() async {
    await store.write(LockoutState.empty);
    return LockoutState.empty;
  });

  Duration _durationForAttempt(int failedAttempts) {
    final index = (failedAttempts - firstLockoutAttempt).clamp(
      0,
      lockoutDurations.length - 1,
    );
    return lockoutDurations[index];
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        result.complete(await action());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }
}

/// Signals unreadable persisted lockout state without exposing its contents.
class CorruptLockoutStateException implements Exception {
  const CorruptLockoutStateException();

  @override
  String toString() => 'Stored lockout state is invalid.';
}
