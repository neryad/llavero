import 'package:flutter/foundation.dart';

import '../core/security/secure_value_store.dart';

/// Persists app preferences that are needed before the vault is unlocked.
class SettingsController extends ChangeNotifier {
  SettingsController({required SecureValueStore store}) : _secureValues = store;

  static const String languageStorageKey = 'llavero.language.v1';
  static const Set<String> supportedLanguageCodes = <String>{'en', 'es'};

  final SecureValueStore _secureValues;

  String? _languageCode;
  bool _initialized = false;

  String? get languageCode => _languageCode;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final savedLanguage = await _secureValues.read(languageStorageKey);
    _languageCode = supportedLanguageCodes.contains(savedLanguage)
        ? savedLanguage
        : null;
    _initialized = true;
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
