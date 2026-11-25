import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/vault_crypto.dart';
import 'package:llavero/data/models/entry.dart';
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
