import 'package:flutter/foundation.dart';

import '../core/security/secure_value_store.dart';

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
  static const Set<String> supportedLanguageCodes = <String>{'en', 'es'};

  final SecureValueStore _secureValues;
  final DateTime Function() _clock;

  String? _languageCode;
  DateTime? _lastEncryptedBackupAt;
  bool _initialized = false;

  String? get languageCode => _languageCode;
  DateTime? get lastEncryptedBackupAt => _lastEncryptedBackupAt;

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
    _initialized = true;
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
