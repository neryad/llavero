import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/data/backup/vault_backup_service.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/data/models/vault_category.dart';
import 'package:llavero/data/vault_storage.dart';

void main() {
  group('VaultBackupService', () {
    final service = VaultBackupService();
    const password = 'family backup passphrase';
    final contents = VaultContents(
      entries: <VaultEntry>[
        VaultEntry(
          id: 'entry-1',
          title: 'Wi-Fi casa',
          category: 'wifi',
          person: 'Familia',
          fields: const <EntryField>[
            EntryField(
              label: 'Contraseña',
              value: 'sample-secret-value',
              type: EntryFieldType.secret,
              isSecret: true,
            ),
          ],
          createdAt: DateTime.utc(2026, 11, 25),
          updatedAt: DateTime.utc(2026, 11, 25),
        ),
        VaultEntry(
          id: 'entry-trash',
          title: 'Entrada eliminada',
          category: 'other',
          fields: const <EntryField>[],
          createdAt: DateTime.utc(2026, 11, 20),
          updatedAt: DateTime.utc(2026, 11, 21),
          deletedAt: DateTime.utc(2026, 11, 22),
        ),
      ],
      customCategories: const <VaultCategory>[
        VaultCategory(id: 'family', name: 'Familia'),
      ],
    );

    test(
      'round-trips active and trashed entries with custom categories',
      () async {
        final bytes = await service.createBackup(
          contents: contents,
          password: password,
        );

        final restored = await service.readBackup(
          bytes: bytes,
          password: password,
        );

        expect(
          restored.entries.map((entry) => entry.toJson()).toList(),
          contents.entries.map((entry) => entry.toJson()).toList(),
        );
        expect(
          restored.customCategories
              .map((category) => category.toJson())
              .toList(),
          contents.customCategories
              .map((category) => category.toJson())
              .toList(),
        );
      },
    );

    test('rejects a password shorter than twelve characters', () async {
      await expectLater(
        service.createBackup(contents: contents, password: 'short'),
        throwsArgumentError,
      );
    });

    test(
      'uses the same generic error for wrong password and tampering',
      () async {
        final bytes = await service.createBackup(
          contents: contents,
          password: password,
        );

        await expectLater(
          service.readBackup(bytes: bytes, password: 'another wrong password'),
          throwsA(isA<BackupFileException>()),
        );

        final envelope = _decodeEnvelope(bytes);
        final ciphertext = base64Decode(envelope['ciphertext']! as String);
        ciphertext[0] ^= 1;
        envelope['ciphertext'] = base64Encode(ciphertext);
        await expectLater(
          service.readBackup(
            bytes: utf8.encode(jsonEncode(envelope)),
            password: password,
          ),
          throwsA(isA<BackupFileException>()),
        );
      },
    );

    test(
      'rejects unsupported versions and out-of-range KDF iterations',
      () async {
        final bytes = await service.createBackup(
          contents: contents,
          password: password,
        );

        final unsupportedVersion = _decodeEnvelope(bytes)
          ..['formatVersion'] = 99;
        await expectLater(
          service.readBackup(
            bytes: utf8.encode(jsonEncode(unsupportedVersion)),
            password: password,
          ),
          throwsA(isA<BackupFileException>()),
        );

        final invalidIterations = _decodeEnvelope(bytes)
          ..['kdfIterations'] = 2000001;
        await expectLater(
          service.readBackup(
            bytes: utf8.encode(jsonEncode(invalidIterations)),
            password: password,
          ),
          throwsA(isA<BackupFileException>()),
        );
      },
    );
  });
}

Map<String, Object?> _decodeEnvelope(List<int> bytes) {
  return Map<String, Object?>.from(jsonDecode(utf8.decode(bytes)) as Map);
}
