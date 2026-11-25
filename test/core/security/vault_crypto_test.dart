import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/vault_crypto.dart';

void main() {
  group('VaultCrypto', () {
    test('uses the iteration count stored with wrapped key metadata', () async {
      const pin = '582941';
      const iterations = VaultCrypto.iterationCount + 1;
      final salt = List<int>.generate(16, (index) => index);
      final keyBytes = List<int>.generate(32, (index) => index + 1);
      final cipher = AesGcm.with256bits();
      final wrappingKey = await Pbkdf2.hmacSha256(
        iterations: iterations,
        bits: 256,
      ).deriveKeyFromPassword(password: pin, nonce: salt);
      final encrypted = await cipher.encrypt(
        keyBytes,
        secretKey: wrappingKey,
        nonce: cipher.newNonce(),
        aad: utf8.encode('llavero.wrapped-dek.v1'),
      );
      final material = WrappedKeyMaterial(
        salt: salt,
        kdfIterations: iterations,
        nonce: encrypted.nonce,
        encryptedDataKey: encrypted.cipherText,
        mac: encrypted.mac.bytes,
      );

      final unwrapped = await VaultCrypto().unwrapDataEncryptionKey(
        pin: pin,
        keyMaterial: material,
      );

      expect(await unwrapped.extractBytes(), equals(keyBytes));
    });

    test('wraps and unwraps a random 256-bit data key with the PIN', () async {
      final crypto = VaultCrypto();
      final generated = await crypto.createVaultKey(pin: '582941');

      expect(await generated.dataEncryptionKey.extractBytes(), hasLength(32));
      expect(generated.keyMaterial.kdfIterations, VaultCrypto.iterationCount);
      expect(generated.keyMaterial.salt, hasLength(16));
      expect(generated.keyMaterial.nonce, hasLength(12));

      final unwrapped = await crypto.unwrapDataEncryptionKey(
        pin: '582941',
        keyMaterial: generated.keyMaterial,
      );

      expect(
        await unwrapped.extractBytes(),
        equals(await generated.dataEncryptionKey.extractBytes()),
      );
    });

    test(
      'rejects a wrong PIN without exposing authentication details',
      () async {
        final crypto = VaultCrypto();
        final generated = await crypto.createVaultKey(pin: '582941');

        await expectLater(
          crypto.unwrapDataEncryptionKey(
            pin: '582942',
            keyMaterial: generated.keyMaterial,
          ),
          throwsA(isA<VaultAuthenticationException>()),
        );
      },
    );

    test('encrypts and decrypts a payload with AES-256-GCM', () async {
      final crypto = VaultCrypto();
      final dataKey = SecretKey(List<int>.generate(32, (index) => index));
      final cleartext = <int>[10, 20, 30, 40, 50];

      final encrypted = await crypto.encryptPayload(
        cleartext,
        dataKey: dataKey,
      );
      final decrypted = await crypto.decryptPayload(
        encrypted,
        dataKey: dataKey,
      );

      expect(decrypted, equals(cleartext));
    });

    test('detects an altered encrypted payload', () async {
      final crypto = VaultCrypto();
      final dataKey = SecretKey(List<int>.generate(32, (index) => index));
      final encrypted = await crypto.encryptPayload(<int>[
        10,
        20,
        30,
        40,
        50,
      ], dataKey: dataKey);
      final changedCiphertext = List<int>.from(encrypted.cipherText)..[0] ^= 1;
      final tampered = SecretBox(
        changedCiphertext,
        nonce: encrypted.nonce,
        mac: encrypted.mac,
      );

      await expectLater(
        crypto.decryptPayload(tampered, dataKey: dataKey),
        throwsA(isA<VaultAuthenticationException>()),
      );
    });
  });
}
