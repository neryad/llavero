import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/theme/app_theme.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/features/trash/trash_screen.dart';
import 'package:llavero/l10n/generated/app_localizations.dart';

import '../support/memory_secure_value_store.dart';
import '../support/memory_vault_crypto.dart';
import '../support/memory_vault_storage.dart';

void main() {
  testWidgets('purges entries past 30 days and restores or deletes remaining', (
    WidgetTester tester,
  ) async {
    final storage = MemoryVaultStorage()
      ..entries = <VaultEntry>[
        _trashedEntry(
          'expired',
          'Antigua',
          DateTime.now().subtract(const Duration(days: 31)),
        ),
        _trashedEntry(
          'restore',
          'Restaurar',
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        _trashedEntry(
          'permanent',
          'Borrar',
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    final controllers = AppControllers(
      secureValues: MemorySecureValueStore(),
      vaultStorage: storage,
      crypto: MemoryVaultCrypto(),
    );
    addTearDown(controllers.dispose);
    await controllers.lock.createVault(pin: MemoryVaultCrypto.correctPin);

    await tester.pumpWidget(
      AppScope(
        controllers: controllers,
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const TrashScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('trash-entry-expired')), findsNothing);
    expect(find.byKey(const ValueKey('trash-entry-restore')), findsOneWidget);
    expect(find.byKey(const ValueKey('trash-entry-permanent')), findsOneWidget);
    expect(find.text('no-debe-mostrarse'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('trash-restore-restore')));
    await tester.pump();
    expect(
      controllers.entries.entries
          .singleWhere((entry) => entry.id == 'restore')
          .deletedAt,
      isNull,
    );

    await tester.tap(find.byKey(const ValueKey('trash-delete-permanent')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-delete-forever')));
    await tester.pumpAndSettle();
    final pinField = find.byKey(const ValueKey('reauthenticate-pin-field'));
    expect(pinField, findsOneWidget);
    await tester.enterText(pinField, '111111');
    await tester.tap(find.byKey(const ValueKey('confirm-reauthentication')));
    await tester.pumpAndSettle();
    expect(
      find.text('PIN incorrecto o bloqueo activo. No se realizó la acción.'),
      findsOneWidget,
    );
    expect(
      controllers.entries.entries.any((entry) => entry.id == 'permanent'),
      isTrue,
    );

    await tester.enterText(pinField, MemoryVaultCrypto.correctPin);
    await tester.tap(find.byKey(const ValueKey('confirm-reauthentication')));
    await tester.pumpAndSettle();
    expect(
      controllers.entries.entries.any((entry) => entry.id == 'permanent'),
      isFalse,
    );
  });
}

VaultEntry _trashedEntry(String id, String title, DateTime deletedAt) {
  return VaultEntry(
    id: id,
    title: title,
    category: 'pin',
    fields: const <EntryField>[
      EntryField(
        label: 'Código',
        value: 'no-debe-mostrarse',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
    ],
    createdAt: deletedAt.subtract(const Duration(days: 1)),
    updatedAt: deletedAt,
    deletedAt: deletedAt,
  );
}
