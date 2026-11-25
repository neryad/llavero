import 'dart:async';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/controllers/entries_controller.dart';
import 'package:llavero/controllers/lock_controller.dart';
import 'package:llavero/core/security/biometric_key_store.dart';
import 'package:llavero/core/security/key_material_store.dart';
import 'package:llavero/core/security/lockout_manager.dart';
import 'package:llavero/core/security/vault_crypto.dart';
import 'package:llavero/data/vault_storage.dart';

import '../support/memory_secure_value_store.dart';

void main() {
  group('LockController', () {
    late Directory directory;
    late MemorySecureValueStore secureValues;
    late _MemoryBiometricKeyStore biometricKeys;
    late _FakeDeviceAuthenticator authenticator;
    late _FakeVaultCrypto crypto;
    late EntriesController entries;
    late LockController controller;
    var now = DateTime.utc(2026, 11, 25);

    setUp(() async {
      now = DateTime.utc(2026, 11, 25);
      directory = await Directory.systemTemp.createTemp(
        'llavero-lock-controller-test-',
      );
      secureValues = MemorySecureValueStore();
      biometricKeys = _MemoryBiometricKeyStore();
      authenticator = _FakeDeviceAuthenticator();
      crypto = _FakeVaultCrypto();
      entries = EntriesController(storage: VaultStorage(directory: directory));
      controller = LockController(
        keyStore: KeyMaterialStore(secureValues),
        lockout: LockoutManager(
          store: SecureLockoutStateStore(secureValues),
          clock: () => now,
        ),
        values: secureValues,
        biometricStore: biometricKeys,
        authenticator: authenticator,
        vaultEntries: entries,
        crypto: crypto,
        clock: () => now,
      );
    });

    tearDown(() async {
      controller.dispose();
      entries.dispose();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test(
      'creates an encrypted vault and reopens it with the correct PIN',
      () async {
        await controller.initialize();
        expect(controller.hasVault, isFalse);

        await controller.createVault(pin: '582941');

        expect(controller.hasVault, isTrue);
        expect(controller.isUnlocked, isTrue);
        expect(secureValues.values.values.join(), isNot(contains('582941')));
        controller.lock();
        expect(entries.entries, isEmpty);

        expect(await controller.unlockWithPin('582941'), isTrue);
        expect(controller.isUnlocked, isTrue);
        expect(controller.lockoutState.failedAttempts, 0);
      },
    );

    test('counts wrong PINs and enforces the persisted lockout', () async {
      await controller.createVault(pin: '582941');
      controller.lock();

      for (var attempt = 0; attempt < 5; attempt++) {
        expect(await controller.unlockWithPin('111111'), isFalse);
      }

      expect(controller.lockoutState.failedAttempts, 5);
      expect(
        controller.lockoutState.lockedUntil,
        now.add(const Duration(seconds: 30)),
      );
      expect(await controller.unlockWithPin('582941'), isFalse);

      now = now.add(const Duration(seconds: 30));
      expect(await controller.unlockWithPin('582941'), isTrue);
    });

    test(
      'reauthenticates with PIN without locking or reloading the vault',
      () async {
        await controller.createVault(pin: '582941');
        await entries.addEntry(title: 'Se conserva', category: 'other');

        for (var attempt = 0; attempt < 5; attempt++) {
          expect(await controller.reauthenticateWithPin('111111'), isFalse);
        }
        expect(controller.lockoutState.failedAttempts, 5);
        expect(await controller.reauthenticateWithPin('582941'), isFalse);
        expect(controller.isUnlocked, isTrue);
        expect(entries.entries.single.title, 'Se conserva');

        now = now.add(const Duration(seconds: 30));
        expect(await controller.reauthenticateWithPin('582941'), isTrue);
        expect(controller.lockoutState.failedAttempts, 0);
        expect(controller.isUnlocked, isTrue);
        expect(entries.entries.single.title, 'Se conserva');
      },
    );

    test(
      'reauthenticates with enabled device biometrics without relocking',
      () async {
        authenticator.isAvailable = true;
        await controller.createVault(pin: '582941', enableBiometrics: true);

        expect(
          await controller.reauthenticateWithBiometrics(
            reason: 'Delete an entry',
          ),
          isTrue,
        );
        expect(controller.isUnlocked, isTrue);

        authenticator.result = false;
        expect(
          await controller.reauthenticateWithBiometrics(
            reason: 'Delete an entry',
          ),
          isFalse,
        );
        expect(controller.isUnlocked, isTrue);
      },
    );

    test(
      'unlocks with an enabled biometric key and keeps PIN fallback',
      () async {
        authenticator.isAvailable = true;
        await controller.createVault(pin: '582941', enableBiometrics: true);
        expect(controller.biometricsEnabled, isTrue);
        expect(biometricKeys.bytes, hasLength(VaultCrypto.keyLength));

        controller.lock();
        expect(await controller.unlockWithBiometrics(), isTrue);
        expect(controller.isUnlocked, isTrue);

        controller.lock();
        biometricKeys.readFails = true;
        expect(await controller.unlockWithBiometrics(), isFalse);
        expect(await controller.unlockWithPin('582941'), isTrue);
      },
    );

    test(
      'requires device authentication and exact confirmation before erasing',
      () async {
        await controller.createVault(pin: '582941');
        await entries.addEntry(title: 'Wi-Fi familiar', category: 'wifi');
        controller.lock();
        authenticator.result = false;

        expect(
          await controller.eraseWithDeviceAuthentication(
            typedConfirmation: 'BORRAR TODO',
            confirmationPhrase: 'BORRAR TODO',
            reason: 'Confirm erase',
          ),
          isFalse,
        );
        expect(controller.hasVault, isTrue);
        expect(
          await File('${directory.path}/${VaultStorage.fileName}').exists(),
          isTrue,
        );

        authenticator.result = true;
        expect(
          await controller.eraseWithDeviceAuthentication(
            typedConfirmation: 'BORRAR TODO',
            confirmationPhrase: 'BORRAR TODO',
            reason: 'Confirm erase',
          ),
          isTrue,
        );
        expect(controller.hasVault, isFalse);
        expect(controller.isUnlocked, isFalse);
        expect(
          await File('${directory.path}/${VaultStorage.fileName}').exists(),
          isFalse,
        );
        expect(await KeyMaterialStore(secureValues).load(), isNull);
        expect(biometricKeys.bytes, isNull);
      },
    );

    test(
      'allows PIN fallback to erase only after exact confirmation',
      () async {
        await controller.createVault(pin: '582941');
        controller.lock();

        expect(
          await controller.eraseWithPin(
            pin: '582941',
            typedConfirmation: 'BORRAR',
            confirmationPhrase: 'BORRAR TODO',
          ),
          isFalse,
        );
        expect(controller.hasVault, isTrue);

        expect(
          await controller.eraseWithPin(
            pin: '582941',
            typedConfirmation: 'BORRAR TODO',
            confirmationPhrase: 'BORRAR TODO',
          ),
          isTrue,
        );
        expect(controller.hasVault, isFalse);
      },
    );

    test('does not allow overlapping device and PIN erase attempts', () async {
      await controller.createVault(pin: '582941');
      controller.lock();
      authenticator.pendingResult = Completer<bool>();

      final deviceErase = controller.eraseWithDeviceAuthentication(
        typedConfirmation: 'BORRAR TODO',
        confirmationPhrase: 'BORRAR TODO',
        reason: 'Confirm erase',
      );
      await Future<void>.delayed(Duration.zero);

      final pinErase = await controller.eraseWithPin(
        pin: '582941',
        typedConfirmation: 'BORRAR TODO',
        confirmationPhrase: 'BORRAR TODO',
      );
      authenticator.pendingResult!.complete(false);

      expect(await deviceErase, isFalse);
      expect(pinErase, isFalse);
      expect(controller.hasVault, isTrue);
    });
  });
}

class _MemoryBiometricKeyStore implements BiometricKeyStore {
  List<int>? bytes;
  bool readFails = false;

  @override
  Future<void> delete() async {
    bytes = null;
  }

  @override
  Future<List<int>?> read() async {
    if (readFails) {
      throw const BiometricKeyUnavailableException();
    }
    return bytes;
  }

  @override
  Future<void> write(List<int> keyBytes) async {
    bytes = List<int>.of(keyBytes);
  }
}

class _FakeDeviceAuthenticator implements DeviceAuthenticator {
  bool isAvailable = false;
  bool result = true;
  Completer<bool>? pendingResult;

  @override
  Future<bool> authenticate({required String reason}) {
    return pendingResult?.future ?? Future<bool>.value(result);
  }

  @override
  Future<bool> checkAvailability() async => isAvailable;
}

class _FakeVaultCrypto extends VaultCrypto {
  static const String correctPin = '582941';
  static final SecretKey dataKey = SecretKey(List<int>.filled(32, 7));

  @override
  Future<GeneratedVaultKey> createVaultKey({required String pin}) async {
    return GeneratedVaultKey(
      dataEncryptionKey: dataKey,
      keyMaterial: _wrappedMaterial(),
    );
  }

  @override
  Future<SecretKey> unwrapDataEncryptionKey({
    required String pin,
    required WrappedKeyMaterial keyMaterial,
  }) async {
    if (pin != correctPin) {
      throw const VaultAuthenticationException();
    }
    return dataKey;
  }
}

WrappedKeyMaterial _wrappedMaterial() => WrappedKeyMaterial(
  salt: List<int>.filled(VaultCrypto.saltLength, 1),
  kdfIterations: VaultCrypto.iterationCount,
  nonce: List<int>.filled(VaultCrypto.nonceLength, 2),
  encryptedDataKey: List<int>.filled(VaultCrypto.keyLength, 3),
  mac: List<int>.filled(VaultCrypto.authenticationTagLength, 4),
);
