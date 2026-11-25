import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/app.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/security/biometric_key_store.dart';
import 'package:llavero/core/security/key_material_store.dart';
import 'package:llavero/core/security/vault_crypto.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/data/models/vault_category.dart';
import 'package:llavero/data/vault_storage.dart';

import '../support/memory_secure_value_store.dart';

void main() {
  group('Onboarding', () {
    late AppControllers controllers;
    late _FakeVaultCrypto crypto;
    late MemorySecureValueStore secureValues;

    setUp(() {
      crypto = _FakeVaultCrypto();
      secureValues = MemorySecureValueStore();
      controllers = AppControllers(
        secureValues: secureValues,
        vaultStorage: _MemoryVaultStorage(),
        biometricKeyStore: _MemoryBiometricKeyStore(),
        deviceAuthenticator: _FakeDeviceAuthenticator(),
        crypto: crypto,
      );
    });

    tearDown(() {
      controllers.dispose();
    });

    test(
      'the app controller can complete vault creation independently',
      () async {
        await controllers.settings.initialize();
        await controllers.lock.initialize();

        await controllers.lock.createVault(pin: '582941');

        expect(controllers.lock.hasVault, isTrue);
        expect(controllers.lock.isUnlocked, isTrue);
      },
    );

    testWidgets(
      'an existing vault starts locked without showing its contents',
      (WidgetTester tester) async {
        await tester.runAsync(
          () => controllers.lock.createVault(pin: '582941'),
        );
        controllers.lock.lock();
        expect(
          controllers.lock.lockoutState.remainingAt(DateTime.now()),
          Duration.zero,
        );

        await tester.pumpWidget(
          LlaveroApp(
            controllers: controllers,
            locale: const Locale('es'),
            themeMode: ThemeMode.light,
          ),
        );
        for (var frame = 0; frame < 6; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.text('Llavero está bloqueado'), findsOneWidget);
        expect(find.text('Introduce tu PIN de 6 dígitos'), findsOneWidget);
        expect(find.text('¿Olvidaste tu PIN?'), findsOneWidget);
        expect(find.text('Tu espacio privado'), findsNothing);
      },
    );

    testWidgets('the mounted app can unlock entries after vault creation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        LlaveroApp(controllers: controllers, themeMode: ThemeMode.light),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(() => controllers.lock.createVault(pin: '582941'));
      await tester.pump();

      expect(controllers.lock.hasVault, isTrue);
      expect(controllers.lock.isUnlocked, isTrue);
    });

    testWidgets(
      'a new vault starts at welcome and changes language instantly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LlaveroApp(controllers: controllers, themeMode: ThemeMode.light),
        );
        await tester.pumpAndSettle();

        expect(find.text('Offline, all yours'), findsOneWidget);

        await tester.tap(find.byKey(const Key('language-es')));
        await tester.pumpAndSettle();

        expect(find.text('Todo offline, todo tuyo'), findsOneWidget);
        expect(find.text('Bienvenido a Llavero'), findsOneWidget);
      },
    );

    testWidgets('creates a vault after matching a valid PIN twice', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        LlaveroApp(
          controllers: controllers,
          locale: const Locale('es'),
          themeMode: ThemeMode.light,
        ),
      );
      for (var frame = 0; frame < 6; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await _tapVisible(tester, find.byKey(const Key('onboarding-next')));
      await _tapVisible(tester, find.byKey(const Key('onboarding-next')));

      for (final digit in '582941'.split('')) {
        await _tapVisible(tester, find.byKey(Key('onboarding-digit-$digit')));
      }
      await _tapVisible(
        tester,
        find.byKey(const Key('onboarding-pin-continue')),
      );

      for (final digit in '582941'.split('')) {
        await _tapVisible(tester, find.byKey(Key('onboarding-digit-$digit')));
      }
      await _tapVisible(
        tester,
        find.byKey(const Key('onboarding-pin-continue')),
      );

      expect(
        find.text('No se puede recuperar un PIN olvidado.'),
        findsOneWidget,
      );
      final createButton = find.byKey(const Key('onboarding-create'));
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      final dynamic onPressed = tester
          .widget<FilledButton>(createButton)
          .onPressed;
      expect(onPressed, isNotNull);
      await tester.runAsync(() async => onPressed());
      await tester.pumpAndSettle();

      expect(crypto.createCalls, 1);
      expect(
        secureValues.values.containsKey(KeyMaterialStore.storageKey),
        isTrue,
      );
      expect(controllers.lock.hasVault, isTrue);
      expect(controllers.lock.isUnlocked, isTrue);
      expect(controllers.lock.isBusy, isFalse);
      expect(find.byKey(const Key('empty-vault-state')), findsOneWidget);
      expect(find.byKey(const Key('add-entry-button')), findsOneWidget);
    });
  });
}

Future<void> _tapVisible(
  WidgetTester tester,
  Finder finder, {
  bool settleAfter = true,
}) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  if (settleAfter) {
    await tester.pumpAndSettle();
  }
}

class _MemoryBiometricKeyStore implements BiometricKeyStore {
  List<int>? _bytes;

  @override
  Future<void> delete() async => _bytes = null;

  @override
  Future<List<int>?> read() async => _bytes;

  @override
  Future<void> write(List<int> keyBytes) async {
    _bytes = List<int>.of(keyBytes);
  }
}

class _MemoryVaultStorage extends VaultStorage {
  @override
  Future<void> delete() async {}

  @override
  Future<List<VaultEntry>> load({required SecretKey dataKey}) async {
    return const <VaultEntry>[];
  }

  @override
  Future<VaultContents> loadContents({required SecretKey dataKey}) async {
    return VaultContents(
      entries: const <VaultEntry>[],
      customCategories: const <VaultCategory>[],
    );
  }

  @override
  Future<void> save({
    required List<VaultEntry> entries,
    List<VaultCategory> customCategories = const <VaultCategory>[],
    required SecretKey dataKey,
  }) async {}
}

class _FakeDeviceAuthenticator implements DeviceAuthenticator {
  @override
  Future<bool> authenticate({required String reason}) async => false;

  @override
  Future<bool> checkAvailability() async => false;
}

class _FakeVaultCrypto extends VaultCrypto {
  static final SecretKey dataKey = SecretKey(List<int>.filled(32, 7));

  int createCalls = 0;

  @override
  Future<GeneratedVaultKey> createVaultKey({required String pin}) async {
    createCalls++;
    return GeneratedVaultKey(
      dataEncryptionKey: dataKey,
      keyMaterial: WrappedKeyMaterial(
        salt: List<int>.filled(VaultCrypto.saltLength, 1),
        kdfIterations: VaultCrypto.iterationCount,
        nonce: List<int>.filled(VaultCrypto.nonceLength, 2),
        encryptedDataKey: List<int>.filled(VaultCrypto.keyLength, 3),
        mac: List<int>.filled(VaultCrypto.authenticationTagLength, 4),
      ),
    );
  }

  @override
  Future<SecretKey> unwrapDataEncryptionKey({
    required String pin,
    required WrappedKeyMaterial keyMaterial,
  }) async {
    if (pin != '582941') {
      throw const VaultAuthenticationException();
    }
    return dataKey;
  }
}
