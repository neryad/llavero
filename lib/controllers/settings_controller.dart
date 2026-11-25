import 'package:flutter/foundation.dart';

import '../core/security/secure_value_store.dart';

enum AppThemeMode { system, light, dark }

enum AutoLockDuration {
  immediate(Duration.zero),
  seconds30(Duration(seconds: 30)),
  minute1(Duration(minutes: 1)),
  minutes5(Duration(minutes: 5));

  const AutoLockDuration(this.duration);

  final Duration duration;
}

enum ClipboardClearDuration {
  seconds30(Duration(seconds: 30)),
  minute1(Duration(minutes: 1)),
  minutes2(Duration(minutes: 2));

  const ClipboardClearDuration(this.duration);

  final Duration duration;
}

/// Persists app preferences that are needed before the vault is unlocked.
class SettingsController extends ChangeNotifier {
  SettingsController({
    required SecureValueStore store,
    DateTime Function()? clock,
  }) : _secureValues = store,
       _clock = clock ?? DateTime.now;

  static const String languageStorageKey = 'llavero.language.v1';
  static const String backupCompletedAtStorageKey =
      'llavero.backup.completedAt.v1';
  static const String themeModeStorageKey = 'llavero.theme-mode.v1';
  static const String autoLockDurationStorageKey = 'llavero.auto-lock.v1';
  static const String clipboardClearDurationStorageKey =
      'llavero.clipboard-clear.v1';
  static const String screenshotProtectionStorageKey =
      'llavero.screenshot-protection.v1';
  static const Set<String> supportedLanguageCodes = <String>{'en', 'es'};

  final SecureValueStore _secureValues;
  final DateTime Function() _clock;

  String? _languageCode;
  DateTime? _lastEncryptedBackupAt;
  AppThemeMode _themeMode = AppThemeMode.system;
  AutoLockDuration _autoLockDuration = AutoLockDuration.immediate;
  ClipboardClearDuration _clipboardClearDuration =
      ClipboardClearDuration.seconds30;
  bool _screenshotProtectionEnabled = true;
  bool _initialized = false;

  String? get languageCode => _languageCode;
  DateTime? get lastEncryptedBackupAt => _lastEncryptedBackupAt;
  AppThemeMode get themeMode => _themeMode;
  AutoLockDuration get autoLockDuration => _autoLockDuration;
  ClipboardClearDuration get clipboardClearDuration => _clipboardClearDuration;
  bool get screenshotProtectionEnabled => _screenshotProtectionEnabled;

  bool get needsBackupReminder {
    final lastBackup = _lastEncryptedBackupAt;
    return lastBackup == null ||
        _clock().toUtc().difference(lastBackup) > const Duration(days: 30);
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final savedLanguage = await _secureValues.read(languageStorageKey);
    final savedBackupAt = await _secureValues.read(backupCompletedAtStorageKey);
    final savedThemeMode = await _secureValues.read(themeModeStorageKey);
    final savedAutoLock = await _secureValues.read(autoLockDurationStorageKey);
    final savedClipboardClear = await _secureValues.read(
      clipboardClearDurationStorageKey,
    );
    final savedScreenshotProtection = await _secureValues.read(
      screenshotProtectionStorageKey,
    );
    final parsedBackupAt = savedBackupAt == null
        ? null
        : DateTime.tryParse(savedBackupAt)?.toUtc();
    if (savedBackupAt != null && parsedBackupAt == null) {
      await _secureValues.delete(backupCompletedAtStorageKey);
    }
    _languageCode = supportedLanguageCodes.contains(savedLanguage)
        ? savedLanguage
        : null;
    _lastEncryptedBackupAt = parsedBackupAt;
    _themeMode = AppThemeMode.values.firstWhere(
      (mode) => mode.name == savedThemeMode,
      orElse: () => AppThemeMode.system,
    );
    _autoLockDuration = AutoLockDuration.values.firstWhere(
      (duration) => duration.name == savedAutoLock,
      orElse: () => AutoLockDuration.immediate,
    );
    _clipboardClearDuration = ClipboardClearDuration.values.firstWhere(
      (duration) => duration.name == savedClipboardClear,
      orElse: () => ClipboardClearDuration.seconds30,
    );
    _screenshotProtectionEnabled = savedScreenshotProtection != 'false';
    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await initialize();
    if (_themeMode == mode) {
      return;
    }
    await _secureValues.write(themeModeStorageKey, mode.name);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> setAutoLockDuration(AutoLockDuration duration) async {
    await initialize();
    if (_autoLockDuration == duration) {
      return;
    }
    await _secureValues.write(autoLockDurationStorageKey, duration.name);
    _autoLockDuration = duration;
    notifyListeners();
  }

  Future<void> setClipboardClearDuration(
    ClipboardClearDuration duration,
  ) async {
    await initialize();
    if (_clipboardClearDuration == duration) {
      return;
    }
    await _secureValues.write(clipboardClearDurationStorageKey, duration.name);
    _clipboardClearDuration = duration;
    notifyListeners();
  }

  Future<void> setScreenshotProtectionEnabled(bool enabled) async {
    await initialize();
    if (_screenshotProtectionEnabled == enabled) {
      return;
    }
    await _secureValues.write(
      screenshotProtectionStorageKey,
      enabled.toString(),
    );
    _screenshotProtectionEnabled = enabled;
    notifyListeners();
  }

  Future<void> recordEncryptedBackup({DateTime? completedAt}) async {
    await initialize();
    final timestamp = (completedAt ?? _clock()).toUtc();
    await _secureValues.write(
      backupCompletedAtStorageKey,
      timestamp.toIso8601String(),
    );
    _lastEncryptedBackupAt = timestamp;
    notifyListeners();
  }

  Future<void> setLanguageCode(String? languageCode) async {
    if (languageCode != null &&
        !supportedLanguageCodes.contains(languageCode)) {
      throw ArgumentError.value(languageCode, 'languageCode');
    }
    if (_languageCode == languageCode) {
      return;
    }
    if (languageCode == null) {
      await _secureValues.delete(languageStorageKey);
    } else {
      await _secureValues.write(languageStorageKey, languageCode);
    }
    _languageCode = languageCode;
    _initialized = true;
    notifyListeners();
  }
}
