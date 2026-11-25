import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/vault_crypto.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/data/models/vault_category.dart';
import 'package:llavero/data/vault_storage.dart';

void main() {
  group('VaultStorage', () {
    late Directory directory;
    late VaultStorage storage;
    final dataKey = SecretKey(List<int>.filled(32, 7));

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('llavero-vault-test-');
      storage = VaultStorage(directory: directory);
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test(
      'saves entries encrypted and restores them from the private file',
      () async {
        final entries = <VaultEntry>[_entry()];

        await storage.save(entries: entries, dataKey: dataKey);

        final file = await _vaultFile(directory);
        final persisted = await file.readAsString();
        expect(persisted, isNot(contains('Wi-Fi familiar')));
        expect(persisted, isNot(contains('secreto-para-test')));
        expect(
          (await storage.load(dataKey: dataKey)).map((entry) => entry.toJson()),
          equals(entries.map((entry) => entry.toJson())),
        );
        expect(await directory.list().length, 1);
      },
    );

    test('returns an empty list when no vault file exists', () async {
      expect(await storage.load(dataKey: dataKey), isEmpty);
    });

    test(
      'reads v1 data and stores custom categories in the encrypted v2 file',
      () async {
        final legacyEntry = _entry();
        final legacyCleartext = utf8.encode(
          jsonEncode(<String, Object?>{
            'version': 1,
            'entries': <Map<String, Object?>>[legacyEntry.toJson()],
          }),
        );
        final encrypted = await VaultCrypto().encryptPayload(
          legacyCleartext,
          dataKey: dataKey,
          associatedData: utf8.encode('llavero.vault.v1'),
        );
        final file = File('${directory.path}/vault.llavero');
        await file.writeAsString(
          jsonEncode(<String, Object>{
            'version': 1,
            'nonce': base64Encode(encrypted.nonce),
            'ciphertext': base64Encode(encrypted.cipherText),
            'mac': base64Encode(encrypted.mac.bytes),
          }),
        );

        final legacyContents = await storage.loadContents(dataKey: dataKey);
        expect(legacyContents.entries.single.toJson(), legacyEntry.toJson());
        expect(legacyContents.customCategories, isEmpty);

        const customCategory = VaultCategory(
          id: 'custom-family',
          name: 'Familia',
        );
        await storage.save(
          entries: legacyContents.entries,
          customCategories: const <VaultCategory>[customCategory],
          dataKey: dataKey,
        );

        final persistedEnvelope =
            jsonDecode(await file.readAsString()) as Map<String, Object?>;
        final persistedCleartext = await VaultCrypto().decryptPayload(
          _secretBoxFrom(persistedEnvelope),
          dataKey: dataKey,
          associatedData: utf8.encode('llavero.vault.v1'),
        );
        final persistedPayload =
            jsonDecode(utf8.decode(persistedCleartext)) as Map<String, Object?>;
        expect(persistedPayload['version'], 2);
        expect(persistedPayload, isNot(contains('Familia')));

        final restored = await storage.loadContents(dataKey: dataKey);
        expect(restored.entries.single.toJson(), legacyEntry.toJson());
        expect(
          restored.customCategories.single.toJson(),
          customCategory.toJson(),
        );
      },
    );

    test('rejects a vault opened with a different data key', () async {
      await storage.save(entries: <VaultEntry>[_entry()], dataKey: dataKey);

      await expectLater(
        storage.load(dataKey: SecretKey(List<int>.filled(32, 8))),
        throwsA(isA<VaultAuthenticationException>()),
      );
    });

    test('detects tampering with the encrypted vault file', () async {
      await storage.save(entries: <VaultEntry>[_entry()], dataKey: dataKey);
      final file = await _vaultFile(directory);
      final envelope =
          jsonDecode(await file.readAsString()) as Map<String, Object?>;
      final ciphertext = base64Decode(envelope['ciphertext']! as String);
      ciphertext[0] ^= 1;
      envelope['ciphertext'] = base64Encode(ciphertext);
      await file.writeAsString(jsonEncode(envelope));

      await expectLater(
        storage.load(dataKey: dataKey),
        throwsA(isA<VaultAuthenticationException>()),
      );
    });

    test(
      'reports invalid vault metadata without returning its contents',
      () async {
        final file = File('${directory.path}/vault.llavero');
        await file.writeAsString(
          jsonEncode(<String, Object>{
            'version': 99,
            'sensitive': 'private-envelope-content',
          }),
        );

        await expectLater(
          storage.load(dataKey: dataKey),
          throwsA(
            isA<CorruptVaultException>().having(
              (error) => error.toString(),
              'message',
              isNot(contains('private-envelope-content')),
            ),
          ),
        );
      },
    );
  });
}

SecretBox _secretBoxFrom(Map<String, Object?> envelope) {
  return SecretBox(
    base64Decode(envelope['ciphertext']! as String),
    nonce: base64Decode(envelope['nonce']! as String),
    mac: Mac(base64Decode(envelope['mac']! as String)),
  );
}

Future<File> _vaultFile(Directory directory) async {
  return directory.list().where((entity) => entity is File).cast<File>().single;
}

VaultEntry _entry() {
  final now = DateTime.utc(2026, 3, 10);
  return VaultEntry(
    id: 'wifi-1',
    title: 'Wi-Fi familiar',
    category: 'wifi',
    fields: const <EntryField>[
      EntryField(
        label: 'Contraseña',
        value: 'secreto-para-test',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}
