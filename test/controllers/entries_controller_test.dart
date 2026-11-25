import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/controllers/entries_controller.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/data/models/vault_category.dart';
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

    test('merges missing IDs and preserves current ID conflicts', () async {
      final storage = VaultStorage(directory: directory);
      final controller = EntriesController(storage: storage);
      addTearDown(controller.dispose);
      await controller.unlock(dataKey: dataKey);

      await controller.replaceContents(
        VaultContents(
          entries: <VaultEntry>[
            _entry(id: 'same-entry', title: 'Current entry'),
            _entry(id: 'current-only', title: 'Keep this entry'),
          ],
          customCategories: const <VaultCategory>[
            VaultCategory(id: 'same-category', name: 'Current category'),
            VaultCategory(id: 'current-category', name: 'Keep this category'),
          ],
        ),
      );

      await controller.mergeContents(
        VaultContents(
          entries: <VaultEntry>[
            _entry(id: 'same-entry', title: 'Backup entry'),
            _entry(id: 'backup-only', title: 'Add this entry'),
          ],
          customCategories: const <VaultCategory>[
            VaultCategory(id: 'same-category', name: 'Backup category'),
            VaultCategory(id: 'backup-category', name: 'Add this category'),
          ],
        ),
      );

      expect(controller.entries, hasLength(3));
      expect(
        controller.entries
            .firstWhere((entry) => entry.id == 'same-entry')
            .title,
        'Current entry',
      );
      expect(controller.customCategories, hasLength(3));
      expect(
        controller.customCategories
            .firstWhere((category) => category.id == 'same-category')
            .name,
        'Current category',
      );

      final reopened = EntriesController(storage: storage);
      addTearDown(reopened.dispose);
      await reopened.unlock(dataKey: dataKey);
      expect(reopened.entries.map((entry) => entry.id).toSet(), {
        'same-entry',
        'current-only',
        'backup-only',
      });
      expect(reopened.customCategories, hasLength(3));
    });

    test(
      'replaces all entries and categories with imported contents',
      () async {
        final controller = EntriesController(
          storage: VaultStorage(directory: directory),
        );
        addTearDown(controller.dispose);
        await controller.unlock(dataKey: dataKey);

        await controller.replaceContents(
          VaultContents(
            entries: <VaultEntry>[_entry(id: 'old', title: 'Old entry')],
            customCategories: const <VaultCategory>[
              VaultCategory(id: 'old-category', name: 'Old category'),
            ],
          ),
        );
        final imported = VaultContents(
          entries: <VaultEntry>[
            _entry(id: 'restored', title: 'Restored entry'),
          ],
          customCategories: const <VaultCategory>[
            VaultCategory(id: 'restored-category', name: 'Restored category'),
          ],
        );

        await controller.replaceContents(imported);

        expect(controller.entries.map((entry) => entry.id), ['restored']);
        expect(controller.customCategories, imported.customCategories);
      },
    );

    test(
      'keeps memory and persisted contents unchanged when import save fails',
      () async {
        final storage = FailingVaultStorage(directory: directory);
        final controller = EntriesController(storage: storage);
        addTearDown(controller.dispose);
        await controller.unlock(dataKey: dataKey);
        final existing = await controller.addEntry(
          title: 'Existing entry',
          category: 'other',
        );
        storage.failWrites = true;

        await expectLater(
          controller.replaceContents(
            VaultContents(
              entries: <VaultEntry>[_entry(id: 'imported', title: 'Imported')],
              customCategories: const <VaultCategory>[
                VaultCategory(id: 'imported-category', name: 'Imported'),
              ],
            ),
          ),
          throwsStateError,
        );

        expect(controller.entries.single.id, existing.id);
        expect(controller.customCategories, isEmpty);
        final reopened = EntriesController(
          storage: VaultStorage(directory: directory),
        );
        addTearDown(reopened.dispose);
        await reopened.unlock(dataKey: dataKey);
        expect(reopened.entries.single.id, existing.id);
        expect(reopened.customCategories, isEmpty);
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

    test('rejects empty or duplicate custom category names', () async {
      final controller = EntriesController(
        storage: VaultStorage(directory: directory),
      );
      addTearDown(controller.dispose);
      await controller.unlock(dataKey: dataKey);

      await expectLater(
        controller.addCustomCategory('  '),
        throwsArgumentError,
      );
      await controller.addCustomCategory('  Familia  ');
      await expectLater(
        controller.addCustomCategory('familia'),
        throwsArgumentError,
      );

      expect(controller.customCategories.single.name, 'Familia');
    });

    test('preserves entries and categories across subsequent saves', () async {
      final controller = EntriesController(
        storage: VaultStorage(directory: directory),
      );
      addTearDown(controller.dispose);
      await controller.unlock(dataKey: dataKey);

      final original = await controller.addEntry(
        title: 'Acceso de casa',
        category: 'other',
      );
      await controller.addCustomCategory('Familia');
      await controller.addEntry(
        title: 'Acceso familiar',
        category: controller.customCategories.single.id,
      );

      expect(
        controller.entries.map((entry) => entry.id),
        contains(original.id),
      );
      expect(controller.entries, hasLength(2));
      expect(controller.customCategories.single.name, 'Familia');
    });

    test('purges entries at 30 days but keeps newer deleted entries', () async {
      var now = DateTime.utc(2026, 1, 1);
      final controller = EntriesController(
        storage: VaultStorage(directory: directory),
        clock: () => now,
      );
      addTearDown(controller.dispose);
      await controller.unlock(dataKey: dataKey);
      final older = await controller.addEntry(
        title: 'Antigua',
        category: 'other',
      );
      await controller.moveToTrash(older.id);
      now = DateTime.utc(2026, 1, 2);
      final newer = await controller.addEntry(
        title: 'Reciente',
        category: 'other',
      );
      await controller.moveToTrash(newer.id);

      final purged = await controller.purgeExpiredTrash(
        now: DateTime.utc(2026, 1, 31),
      );

      expect(purged, 1);
      expect(controller.entries.map((entry) => entry.id), contains(newer.id));
      expect(
        controller.entries.map((entry) => entry.id),
        isNot(contains(older.id)),
      );
    });

    test('duplicates an entry with a fresh id and no trash state', () async {
      final now = DateTime.utc(2026, 3, 10);
      final controller = EntriesController(
        storage: VaultStorage(directory: directory),
        clock: () => now,
      );
      addTearDown(controller.dispose);
      await controller.unlock(dataKey: dataKey);
      final original = await controller.addEntry(
        title: 'Wi-Fi casa',
        category: 'wifi',
        fields: const <EntryField>[
          EntryField(
            label: 'Contraseña',
            value: 'secreto',
            type: EntryFieldType.secret,
            isSecret: true,
          ),
        ],
        isFavorite: true,
      );
      await controller.moveToTrash(original.id);

      final duplicate = await controller.duplicateEntry(original.id);

      expect(duplicate.id, isNot(original.id));
      expect(duplicate.title, original.title);
      expect(duplicate.fields.single.value, 'secreto');
      expect(duplicate.isFavorite, isTrue);
      expect(duplicate.deletedAt, isNull);
      expect(controller.entries, hasLength(2));
    });

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

VaultEntry _entry({required String id, required String title}) {
  return VaultEntry(
    id: id,
    title: title,
    category: 'other',
    fields: const <EntryField>[],
    createdAt: DateTime.utc(2026, 11, 25),
    updatedAt: DateTime.utc(2026, 11, 25),
  );
}

class FailingVaultStorage extends VaultStorage {
  FailingVaultStorage({required Directory directory})
    : super(directory: directory);

  bool failWrites = false;

  @override
  Future<void> save({
    required List<VaultEntry> entries,
    List<VaultCategory> customCategories = const <VaultCategory>[],
    required SecretKey dataKey,
  }) async {
    if (failWrites) {
      throw StateError('Simulated storage write failure.');
    }
    await super.save(
      entries: entries,
      customCategories: customCategories,
      dataKey: dataKey,
    );
  }
}
