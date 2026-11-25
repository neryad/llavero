import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/key_material_store.dart';
import 'package:llavero/core/security/vault_crypto.dart';

import '../../support/memory_secure_value_store.dart';

void main() {
  group('KeyMaterialStore', () {
    test('persists only wrapped key material and restores it', () async {
      final secureValues = MemorySecureValueStore();
      final store = KeyMaterialStore(secureValues);
      final material = WrappedKeyMaterial(
        salt: List<int>.filled(16, 1),
        kdfIterations: VaultCrypto.iterationCount,
        nonce: List<int>.filled(12, 2),
        encryptedDataKey: List<int>.filled(32, 3),
        mac: List<int>.filled(16, 4),
      );
      const pin = '582941';
      final plaintextKey = base64Encode(
        List<int>.generate(32, (index) => index),
      );

      await store.save(material);
      final persistedValue = secureValues.values.values.single;
      final restored = await store.load();

      expect(persistedValue, isNot(contains(pin)));
      expect(persistedValue, isNot(contains(plaintextKey)));
      expect(restored?.salt, equals(material.salt));
      expect(restored?.kdfIterations, material.kdfIterations);
      expect(restored?.nonce, equals(material.nonce));
      expect(restored?.encryptedDataKey, equals(material.encryptedDataKey));
      expect(restored?.mac, equals(material.mac));
    });

    test('returns null when no key material has been saved', () async {
      final store = KeyMaterialStore(MemorySecureValueStore());

      expect(await store.load(), isNull);
    });

    test('reports corrupt metadata without returning its contents', () async {
      final secureValues = MemorySecureValueStore();
      secureValues.values[KeyMaterialStore.storageKey] = jsonEncode(
        <String, Object>{'version': 1, 'unexpected': 'sensitive payload'},
      );
      final store = KeyMaterialStore(secureValues);

      await expectLater(
        store.load(),
        throwsA(isA<CorruptKeyMaterialException>()),
      );
    });
  });
}
