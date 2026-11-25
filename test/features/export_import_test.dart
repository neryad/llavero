import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/app_routes.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/theme/app_theme.dart';
import 'package:llavero/data/backup/backup_file_gateway.dart';
import 'package:llavero/data/backup/vault_backup_service.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/data/models/vault_category.dart';
import 'package:llavero/data/vault_storage.dart';
import 'package:llavero/features/backup/export_import_screen.dart';
import 'package:llavero/features/home/home_screen.dart';
import 'package:llavero/l10n/generated/app_localizations.dart';

import '../support/memory_secure_value_store.dart';
import '../support/memory_vault_crypto.dart';
import '../support/memory_vault_storage.dart';

void main() {
  testWidgets(
    'Home opens backup screen and clears a completed-backup reminder',
    (tester) async {
      final controllers = await _createControllers();
      addTearDown(controllers.dispose);
      final gateway = FakeBackupFileGateway();

      await tester.pumpWidget(
        _app(
          controllers: controllers,
          gateway: gateway,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('backup-reminder-banner')),
        findsOneWidget,
      );
      await controllers.settings.recordEncryptedBackup(
        completedAt: DateTime.now().toUtc(),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('backup-reminder-banner')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('home-export-import')));
      await tester.pumpAndSettle();

      expect(find.text('Copias y exportaciones'), findsOneWidget);
    },
  );

  testWidgets('validates backup and shows counts before an explicit merge', (
    tester,
  ) async {
    final imported = VaultContents(
      entries: <VaultEntry>[
        _entry(id: 'imported-1', title: 'Cuenta importada'),
        _entry(id: 'imported-2', title: 'Wi-Fi importado'),
      ],
      customCategories: const <VaultCategory>[
        VaultCategory(id: 'family', name: 'Familia'),
      ],
    );
    final backupBytes = Uint8List.fromList(<int>[1, 2, 3]);
    final gateway = FakeBackupFileGateway()..backupBytes = backupBytes;
    final backupService = FakeVaultBackupService(imported);
    final controllers = await _createControllers();
    addTearDown(controllers.dispose);

    await tester.pumpWidget(
      _app(
        controllers: controllers,
        gateway: gateway,
        backupService: backupService,
        home: ExportImportScreen(
          fileGateway: gateway,
          backupService: backupService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('backup-import-button')));
    await tester.pumpAndSettle();
    expect(gateway.pickCalls, 1);

    await tester.enterText(
      find.byKey(const ValueKey('backup-password-field')),
      'family backup passphrase',
    );
    await tester.tap(find.byKey(const ValueKey('backup-password-open')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('backup-import-preview')), findsOneWidget);
    expect(find.byKey(const ValueKey('backup-import-merge')), findsOneWidget);
    expect(find.byKey(const ValueKey('backup-import-replace')), findsOneWidget);
    expect(controllers.entries.entries, isEmpty);

    await tester.tap(find.byKey(const ValueKey('backup-import-merge')));
    await tester.pumpAndSettle();

    expect(controllers.entries.entries.map((entry) => entry.id).toSet(), {
      'imported-1',
      'imported-2',
    });
    expect(controllers.entries.customCategories.single.name, 'Familia');
  });

  testWidgets('requires reauthentication before replacing the current vault', (
    tester,
  ) async {
    final controllers = await _createControllers();
    addTearDown(controllers.dispose);
    final current = await controllers.entries.addEntry(
      title: 'Entrada actual',
      category: 'other',
    );
    final gateway = FakeBackupFileGateway()
      ..backupBytes = Uint8List.fromList(<int>[1, 2, 3]);
    final backupService = FakeVaultBackupService(
      VaultContents(
        entries: <VaultEntry>[
          _entry(id: 'replacement', title: 'Entrada de la copia'),
        ],
        customCategories: const <VaultCategory>[],
      ),
    );

    await tester.pumpWidget(
      _app(
        controllers: controllers,
        gateway: gateway,
        backupService: backupService,
        home: ExportImportScreen(
          fileGateway: gateway,
          backupService: backupService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('backup-import-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('backup-password-field')),
      'family backup passphrase',
    );
    await tester.tap(find.byKey(const ValueKey('backup-password-open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('backup-import-replace')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('backup-replace-confirmation-field')),
      'REEMPLAZAR',
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('backup-replace-confirm')),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const ValueKey('backup-replace-confirm')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('backup-replace-confirmation-field')),
      findsNothing,
    );

    final pinField = find.byKey(const ValueKey('reauthenticate-pin-field'));
    expect(pinField, findsOneWidget);
    await tester.enterText(pinField, '111111');
    await tester.tap(find.byKey(const ValueKey('confirm-reauthentication')));
    await tester.pumpAndSettle();

    expect(controllers.entries.entries.single.id, current.id);
    expect(pinField, findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cancel-reauthentication')));
    await tester.pumpAndSettle();
    expect(controllers.entries.entries.single.id, current.id);
  });

  testWidgets(
    'cancelled or failed reauthentication does not export plaintext',
    (tester) async {
      final gateway = FakeBackupFileGateway();
      final controllers = await _createControllers();
      addTearDown(controllers.dispose);

      await tester.pumpWidget(
        _app(
          controllers: controllers,
          gateway: gateway,
          home: ExportImportScreen(fileGateway: gateway),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('backup-export-json')));
      await tester.pumpAndSettle();
      expect(
        find.text('El archivo contendrá tus secretos en texto claro.'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('confirm-plain-export-warning')),
      );
      await tester.pumpAndSettle();
      final pinField = find.byKey(const ValueKey('reauthenticate-pin-field'));
      await tester.enterText(pinField, '111111');
      await tester.tap(find.byKey(const ValueKey('confirm-reauthentication')));
      await tester.pumpAndSettle();

      expect(gateway.saveCalls, 0);
      expect(gateway.shareCalls, 0);
      expect(pinField, findsOneWidget);
      expect(
        find.text('PIN incorrecto o bloqueo activo. No se realizó la acción.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('cancel-reauthentication')));
      await tester.pumpAndSettle();
      expect(gateway.saveCalls, 0);
      expect(gateway.shareCalls, 0);
    },
  );

  testWidgets('dismissed backup save keeps reminder until a save completes', (
    tester,
  ) async {
    final gateway = FakeBackupFileGateway()..saveResult = false;
    final controllers = await _createControllers();
    addTearDown(controllers.dispose);
    final backupService = FakeVaultBackupService(
      VaultContents(
        entries: const <VaultEntry>[],
        customCategories: const <VaultCategory>[],
      ),
    );

    await tester.pumpWidget(
      _app(
        controllers: controllers,
        gateway: gateway,
        backupService: backupService,
        home: ExportImportScreen(
          fileGateway: gateway,
          backupService: backupService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _createAndSaveEncryptedBackup(tester);
    expect(controllers.settings.needsBackupReminder, isTrue);

    gateway.saveResult = true;
    await _createAndSaveEncryptedBackup(tester);

    expect(gateway.saveCalls, 2);
    expect(controllers.settings.needsBackupReminder, isFalse);
  });
}

Future<void> _createAndSaveEncryptedBackup(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('backup-export-encrypted')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const ValueKey('backup-password-field')),
    'family backup passphrase',
  );
  await tester.enterText(
    find.byKey(const ValueKey('backup-password-confirmation-field')),
    'family backup passphrase',
  );
  await tester.tap(find.byKey(const ValueKey('backup-password-open')));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(const ValueKey('reauthenticate-pin-field')),
    MemoryVaultCrypto.correctPin,
  );
  await tester.tap(find.byKey(const ValueKey('confirm-reauthentication')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const ValueKey('backup-destination-save')));
  await tester.pumpAndSettle();
}

Future<AppControllers> _createControllers() async {
  final controllers = AppControllers(
    secureValues: MemorySecureValueStore(),
    vaultStorage: MemoryVaultStorage(),
    crypto: MemoryVaultCrypto(),
  );
  await controllers.lock.createVault(pin: MemoryVaultCrypto.correctPin);
  await controllers.settings.initialize();
  return controllers;
}

Widget _app({
  required AppControllers controllers,
  required BackupFileGateway gateway,
  required Widget home,
  VaultBackupService? backupService,
}) {
  return AppScope(
    controllers: controllers,
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      home: home,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.exportImport) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => ExportImportScreen(
              fileGateway: gateway,
              backupService: backupService,
            ),
          );
        }
        return null;
      },
    ),
  );
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

class FakeBackupFileGateway implements BackupFileGateway {
  Uint8List? backupBytes;
  bool saveResult = true;
  int pickCalls = 0;
  int saveCalls = 0;
  int shareCalls = 0;
  int printCalls = 0;

  @override
  Future<Uint8List?> pickBackupFile() async {
    pickCalls++;
    return backupBytes;
  }

  @override
  Future<bool> printPdf({required Uint8List bytes}) async {
    printCalls++;
    return true;
  }

  @override
  Future<bool> saveFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    saveCalls++;
    return saveResult;
  }

  @override
  Future<bool> shareFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    shareCalls++;
    return true;
  }
}

class FakeVaultBackupService extends VaultBackupService {
  FakeVaultBackupService(this.contents);

  final VaultContents contents;

  @override
  Future<Uint8List> createBackup({
    required VaultContents contents,
    required String password,
  }) async {
    return Uint8List.fromList(<int>[1, 2, 3]);
  }

  @override
  Future<VaultContents> readBackup({
    required List<int> bytes,
    required String password,
  }) async {
    return contents;
  }
}
