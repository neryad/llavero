import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'vault_crypto.dart';

/// Stores a second copy of the data key behind the platform biometric gate.
abstract interface class BiometricKeyStore {
  Future<void> write(List<int> keyBytes);

  Future<List<int>?> read();

  Future<void> delete();
}

/// Uses Keychain biometric access control and Android's biometric Keystore.
class SecureBiometricKeyStore implements BiometricKeyStore {
  SecureBiometricKeyStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions.biometric(
              enforceBiometrics: true,
              requireBiometricsPerOperation: true,
              biometricType: AndroidBiometricType.strongBiometricOnly,
              storageNamespace: 'llavero-biometric-key',
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
              accessControlFlags: <AccessControlFlag>[
                AccessControlFlag.biometryCurrentSet,
              ],
            ),
          );

  static const String storageKey = 'llavero.biometric-dek.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(List<int> keyBytes) async {
    if (keyBytes.length != VaultCrypto.keyLength) {
      throw const BiometricKeyUnavailableException();
    }
    await _storage.write(key: storageKey, value: base64Encode(keyBytes));
  }

  @override
  Future<List<int>?> read() async {
    final encoded = await _storage.read(key: storageKey);
    if (encoded == null) {
      return null;
    }

    try {
      final bytes = base64Decode(encoded);
      if (bytes.length != VaultCrypto.keyLength) {
        throw const FormatException();
      }
      return bytes;
    } on FormatException {
      throw const BiometricKeyUnavailableException();
    }
  }

  @override
  Future<void> delete() => _storage.delete(key: storageKey);
}

/// Boundary around device authentication so lock behavior can be unit tested.
abstract interface class DeviceAuthenticator {
  Future<bool> checkAvailability();

  Future<bool> authenticate({required String reason});
}

/// Uses local device biometrics for a destructive action.
class LocalDeviceAuthenticator implements DeviceAuthenticator {
  LocalDeviceAuthenticator({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<bool> checkAvailability() async {
    try {
      return await _authentication.isDeviceSupported() &&
          (await _authentication.getAvailableBiometrics()).isNotEmpty;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on Object {
      return false;
    }
  }
}

/// Hides invalid or unavailable biometric key material from callers.
class BiometricKeyUnavailableException implements Exception {
  const BiometricKeyUnavailableException();

  @override
  String toString() => 'Biometric key is unavailable.';
}
