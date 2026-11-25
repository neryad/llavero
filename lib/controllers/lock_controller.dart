import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../core/security/biometric_key_store.dart';
import '../core/security/key_material_store.dart';
import '../core/security/lockout_manager.dart';
import '../core/security/pin_validator.dart';
import '../core/security/secure_value_store.dart';
import '../core/security/vault_crypto.dart';
import 'entries_controller.dart';

/// Owns PIN, biometric, and persistent lockout behavior for the vault.
class LockController extends ChangeNotifier {
  LockController({
    required KeyMaterialStore keyStore,
    required LockoutManager lockout,
    required SecureValueStore values,
    required BiometricKeyStore biometricStore,
    required DeviceAuthenticator authenticator,
    required EntriesController vaultEntries,
    VaultCrypto? crypto,
    DateTime Function()? clock,
  }) : _keyMaterialStore = keyStore,
       _lockoutManager = lockout,
       _secureValues = values,
       _biometricKeyStore = biometricStore,
       _deviceAuthenticator = authenticator,
       _entries = vaultEntries,
       _crypto = crypto ?? VaultCrypto(),
       _clock = clock ?? DateTime.now;

  static const String biometricEnabledStorageKey =
      'llavero.biometric-enabled.v1';

  final KeyMaterialStore _keyMaterialStore;
  final LockoutManager _lockoutManager;
  final SecureValueStore _secureValues;
  final BiometricKeyStore _biometricKeyStore;
  final DeviceAuthenticator _deviceAuthenticator;
  final EntriesController _entries;
  final VaultCrypto _crypto;
  final DateTime Function() _clock;

  WrappedKeyMaterial? _keyMaterial;
  LockoutState _lockoutState = LockoutState.empty;
  bool _initialized = false;
  bool _hasVault = false;
  bool _biometricsEnabled = false;
  bool _isBusy = false;

  bool get hasVault => _hasVault;

  bool get isUnlocked => _entries.isUnlocked;

  bool get biometricsEnabled => _biometricsEnabled;

  bool get isBusy => _isBusy;

  LockoutState get lockoutState => _lockoutState;

  Future<bool> canUseBiometrics() => _deviceAuthenticator.checkAvailability();

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _keyMaterial = await _keyMaterialStore.load();
    _hasVault = _keyMaterial != null;
    _lockoutState = await _lockoutManager.loadState();
    _biometricsEnabled =
        _hasVault &&
        await _secureValues.read(biometricEnabledStorageKey) == 'true';
    _entries.lock();
    _initialized = true;
    notifyListeners();
  }

  /// Creates the DEK and persists only its PIN-wrapped form.
  Future<void> createVault({
    required String pin,
    bool enableBiometrics = false,
  }) async {
    await initialize();
    if (_hasVault) {
      throw const VaultAlreadyExistsException();
    }
    if (PinValidator.validate(pin) != null) {
      throw const InvalidVaultPinException();
    }
    if (enableBiometrics && !await _deviceAuthenticator.checkAvailability()) {
      throw const BiometricsUnavailableException();
    }

    await _runBusy(() async {
      final generated = await _crypto.createVaultKey(pin: pin);
      var biometricKeySaved = false;
      try {
        if (enableBiometrics) {
          await _biometricKeyStore.write(
            await generated.dataEncryptionKey.extractBytes(),
          );
          biometricKeySaved = true;
        }
        await _keyMaterialStore.save(generated.keyMaterial);
        if (enableBiometrics) {
          await _secureValues.write(biometricEnabledStorageKey, 'true');
        }
        await _lockoutManager.recordSuccess();
        _keyMaterial = generated.keyMaterial;
        _hasVault = true;
        _biometricsEnabled = enableBiometrics;
        _lockoutState = LockoutState.empty;
        await _entries.unlock(dataKey: generated.dataEncryptionKey);
      } catch (_) {
        await _keyMaterialStore.delete();
        await _secureValues.delete(biometricEnabledStorageKey);
        if (biometricKeySaved) {
          await _biometricKeyStore.delete();
        }
        rethrow;
      }
    });
  }

  /// Attempts PIN unlock and persists an incorrect attempt without exposing it.
  Future<bool> unlockWithPin(String pin) async {
    await initialize();
    final material = _keyMaterial;
    if (!_hasVault || material == null || _isBusy) {
      return false;
    }
    _lockoutState = await _lockoutManager.loadState();
    if (_lockoutState.remainingAt(_clock()) > Duration.zero) {
      notifyListeners();
      return false;
    }

    return _runBusy(() async {
      final SecretKey dataKey;
      try {
        dataKey = await _crypto.unwrapDataEncryptionKey(
          pin: pin,
          keyMaterial: material,
        );
      } on VaultAuthenticationException {
        _lockoutState = await _lockoutManager.recordFailure();
        return false;
      }
      await _unlock(dataKey);
      return true;
    });
  }

  /// Reads the platform-gated DEK; any cancel or failure leaves PIN available.
  Future<bool> unlockWithBiometrics() async {
    await initialize();
    if (!_hasVault || !_biometricsEnabled || _isBusy) {
      return false;
    }

    return _runBusy(() async {
      try {
        final bytes = await _biometricKeyStore.read();
        if (bytes == null || bytes.length != VaultCrypto.keyLength) {
          return false;
        }
        await _unlock(SecretKey(bytes));
        return true;
      } on Object {
        return false;
      }
    });
  }

  /// Confirms the PIN without changing the current unlocked session.
  Future<bool> reauthenticateWithPin(String pin) async {
    await initialize();
    final material = _keyMaterial;
    if (!_hasVault || material == null || _isBusy) {
      return false;
    }

    return _runBusy(() async {
      _lockoutState = await _lockoutManager.loadState();
      if (_lockoutState.remainingAt(_clock()) > Duration.zero) {
        return false;
      }
      try {
        await _crypto.unwrapDataEncryptionKey(pin: pin, keyMaterial: material);
      } on VaultAuthenticationException {
        _lockoutState = await _lockoutManager.recordFailure();
        return false;
      }
      _lockoutState = await _lockoutManager.recordSuccess();
      return true;
    });
  }

  /// Confirms enabled device biometrics without changing the unlocked session.
  Future<bool> reauthenticateWithBiometrics({required String reason}) async {
    await initialize();
    if (!_hasVault || !_biometricsEnabled || _isBusy) {
      return false;
    }
    return _runBusy(() async {
      try {
        return await _deviceAuthenticator.authenticate(reason: reason);
      } on Object {
        return false;
      }
    });
  }

  /// Clears the decrypted entries and key when the app returns to a locked state.
  void lock() {
    if (!_entries.isUnlocked) {
      return;
    }
    _entries.lock();
    notifyListeners();
  }

  /// Erases the vault after device authentication and an exact typed phrase.
  Future<bool> eraseWithDeviceAuthentication({
    required String typedConfirmation,
    required String confirmationPhrase,
    required String reason,
  }) async {
    await initialize();
    if (_isBusy ||
        !_hasVault ||
        !_matchesConfirmation(typedConfirmation, confirmationPhrase)) {
      return false;
    }
    return _runBusy(() async {
      if (!await _deviceAuthenticator.authenticate(reason: reason)) {
        return false;
      }
      await _eraseVault();
      return true;
    });
  }

  /// PIN fallback for erase when device authentication is unavailable or fails.
  Future<bool> eraseWithPin({
    required String pin,
    required String typedConfirmation,
    required String confirmationPhrase,
  }) async {
    await initialize();
    final material = _keyMaterial;
    if (_isBusy ||
        !_hasVault ||
        material == null ||
        !_matchesConfirmation(typedConfirmation, confirmationPhrase)) {
      return false;
    }
    return _runBusy(() async {
      _lockoutState = await _lockoutManager.loadState();
      if (_lockoutState.remainingAt(_clock()) > Duration.zero) {
        return false;
      }

      try {
        await _crypto.unwrapDataEncryptionKey(pin: pin, keyMaterial: material);
      } on VaultAuthenticationException {
        _lockoutState = await _lockoutManager.recordFailure();
        return false;
      }
      await _eraseVault();
      return true;
    });
  }

  Future<void> _unlock(SecretKey dataKey) async {
    await _entries.unlock(dataKey: dataKey);
    _lockoutState = await _lockoutManager.recordSuccess();
    notifyListeners();
  }

  Future<void> _eraseVault() async {
    await _entries.eraseVault();
    await _keyMaterialStore.delete();
    await _biometricKeyStore.delete();
    await _secureValues.delete(biometricEnabledStorageKey);
    _lockoutState = await _lockoutManager.recordSuccess();
    _keyMaterial = null;
    _hasVault = false;
    _biometricsEnabled = false;
    notifyListeners();
  }

  bool _matchesConfirmation(String typed, String expected) {
    return expected.isNotEmpty && typed.trim() == expected;
  }

  Future<T> _runBusy<T>(Future<T> Function() action) async {
    _isBusy = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}

class VaultAlreadyExistsException implements Exception {
  const VaultAlreadyExistsException();
}

class InvalidVaultPinException implements Exception {
  const InvalidVaultPinException();
}

class BiometricsUnavailableException implements Exception {
  const BiometricsUnavailableException();
}
