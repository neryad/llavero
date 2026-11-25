import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/controllers/settings_controller.dart';

import '../support/memory_secure_value_store.dart';

void main() {
  group('SettingsController', () {
    test('persists the selected language and restores it on startup', () async {
      final secureValues = MemorySecureValueStore();
      final controller = SettingsController(store: secureValues);
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.languageCode, isNull);

      await controller.setLanguageCode('es');

      expect(controller.languageCode, 'es');
      expect(secureValues.values[SettingsController.languageStorageKey], 'es');

      final restored = SettingsController(store: secureValues);
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.languageCode, 'es');
    });

    test('rejects unsupported language codes', () async {
      final controller = SettingsController(store: MemorySecureValueStore());
      addTearDown(controller.dispose);

      await expectLater(controller.setLanguageCode('fr'), throwsArgumentError);
    });

    test(
      'shows a backup reminder when no completed backup is stored',
      () async {
        final controller = SettingsController(
          store: MemorySecureValueStore(),
          clock: () => DateTime.utc(2026, 11, 25),
        );

        await controller.initialize();

        expect(controller.lastEncryptedBackupAt, isNull);
        expect(controller.needsBackupReminder, isTrue);
      },
    );

    test('shows reminder only after more than thirty days', () async {
      final store = MemorySecureValueStore()
        ..values[SettingsController.backupCompletedAtStorageKey] = DateTime.utc(
          2026,
          10,
          26,
        ).toIso8601String();
      final controller = SettingsController(
        store: store,
        clock: () => DateTime.utc(2026, 11, 25),
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.needsBackupReminder, isFalse);

      final overdue = SettingsController(
        store: store,
        clock: () => DateTime.utc(2026, 11, 25, 0, 0, 1),
      );
      addTearDown(overdue.dispose);

      await overdue.initialize();
      expect(overdue.needsBackupReminder, isTrue);
    });

    test('persists and restores the completed encrypted-backup date', () async {
      final store = MemorySecureValueStore();
      final completedAt = DateTime.utc(2026, 11, 20, 12);
      final controller = SettingsController(
        store: store,
        clock: () => DateTime.utc(2026, 11, 25),
      );
      addTearDown(controller.dispose);

      await controller.recordEncryptedBackup(completedAt: completedAt);

      expect(controller.lastEncryptedBackupAt, completedAt);
      expect(
        store.values[SettingsController.backupCompletedAtStorageKey],
        completedAt.toIso8601String(),
      );

      final restored = SettingsController(
        store: store,
        clock: () => DateTime.utc(2026, 11, 25),
      );
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.lastEncryptedBackupAt, completedAt);
      expect(restored.needsBackupReminder, isFalse);
    });

    test('ignores malformed stored backup dates without crashing', () async {
      final store = MemorySecureValueStore()
        ..values[SettingsController.backupCompletedAtStorageKey] = 'not-a-date';
      final controller = SettingsController(
        store: store,
        clock: () => DateTime.utc(2026, 11, 25),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.lastEncryptedBackupAt, isNull);
      expect(controller.needsBackupReminder, isTrue);
      expect(
        store.values.containsKey(
          SettingsController.backupCompletedAtStorageKey,
        ),
        isFalse,
      );
    });
  });
}
