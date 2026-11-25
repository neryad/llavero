import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/controllers/entries_controller.dart';
import 'package:llavero/data/vault_storage.dart';

void main() {
  group('EntriesController', () {
    late Directory directory;
    late SecretKey dataKey;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'llavero-entries-controller-test-',
      );
      dataKey = SecretKey(List<int>.filled(32, 9));
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test('requires unlock and clears in-memory entries when locked', () async {
      final controller = EntriesController(
        storage: VaultStorage(directory: directory),
      );
      addTearDown(controller.dispose);

      await expectLater(
        controller.addEntry(title: 'Casa', category: 'other'),
        throwsA(isA<VaultLockedException>()),
      );

      await controller.unlock(dataKey: dataKey);
      await controller.addEntry(title: 'Casa', category: 'other');
      controller.lock();

      expect(controller.entries, isEmpty);
      expect(controller.isUnlocked, isFalse);
    });

    test(
      'stays locked when lock is called before a queued unlock starts',
      () async {
        final controller = EntriesController(
          storage: VaultStorage(directory: directory),
        );
        addTearDown(controller.dispose);

        final unlock = controller.unlock(dataKey: dataKey);
        controller.lock();
        await unlock;

        expect(controller.entries, isEmpty);
        expect(controller.isUnlocked, isFalse);
      },
    );

    test(
      'persists a new entry and restores it in a fresh controller',
      () async {
        final controller = EntriesController(
          storage: VaultStorage(directory: directory),
        );
        addTearDown(controller.dispose);
        await controller.unlock(dataKey: dataKey);

        final entry = await controller.addEntry(
          title: 'Cuenta familiar',
          category: 'email',
          person: 'Abuela',
        );

        expect(entry.id, isNotEmpty);
        final reopened = EntriesController(
          storage: VaultStorage(directory: directory),
        );
        addTearDown(reopened.dispose);
        await reopened.unlock(dataKey: dataKey);

        expect(reopened.entries.single.toJson(), equals(entry.toJson()));
      },
    );

    test(
      'updates entries, moves them to trash, restores and purges them',
      () async {
        final timestamps = <DateTime>[
          DateTime.utc(2026, 3, 10),
          DateTime.utc(2026, 3, 11),
          DateTime.utc(2026, 3, 12),
          DateTime.utc(2026, 3, 13),
        ];
        var timestampIndex = 0;
        final controller = EntriesController(
          storage: VaultStorage(directory: directory),
          clock: () => timestamps[timestampIndex++],
        );
        addTearDown(controller.dispose);
        await controller.unlock(dataKey: dataKey);
        final created = await controller.addEntry(
          title: 'Acceso',
          category: 'pin',
        );

        await controller.updateEntry(created.copyWith(title: 'Acceso nuevo'));
        final updated = controller.entries.single;
        expect(updated.title, 'Acceso nuevo');
        expect(updated.createdAt, timestamps[0]);
        expect(updated.updatedAt, timestamps[1]);

        await controller.moveToTrash(created.id);
        expect(controller.entries.single.deletedAt, timestamps[2]);

        await controller.restoreFromTrash(created.id);
        expect(controller.entries.single.deletedAt, isNull);
        expect(controller.entries.single.updatedAt, timestamps[3]);

        await controller.deleteForever(created.id);
        expect(controller.entries, isEmpty);
      },
    );

    test('serializes simultaneous additions without losing an entry', () async {
      final controller = EntriesController(
        storage: VaultStorage(directory: directory),
      );
      addTearDown(controller.dispose);
      await controller.unlock(dataKey: dataKey);

      await Future.wait([
        controller.addEntry(title: 'Casa', category: 'wifi'),
        controller.addEntry(title: 'Correo', category: 'email'),
      ]);

      expect(controller.entries, hasLength(2));
      expect(controller.entries.map((entry) => entry.title).toSet(), {
        'Casa',
        'Correo',
      });
    });
  });
}
