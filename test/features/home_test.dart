import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/theme/app_theme.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/data/vault_storage.dart';
import 'package:llavero/features/home/home_screen.dart';
import 'package:llavero/l10n/generated/app_localizations.dart';

import '../support/memory_secure_value_store.dart';

void main() {
  testWidgets('shows a clear empty state when the vault has no entries', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    expect(find.byKey(const ValueKey('empty-vault-state')), findsOneWidget);
    expect(find.byKey(const ValueKey('add-entry-button')), findsOneWidget);
  });

  testWidgets('does not show or search secret values from entry cards', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, withEntry: true);

    expect(find.text('Wi-Fi de casa'), findsOneWidget);
    expect(find.text('SECRET-VALUE-DO-NOT-DISPLAY'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('entry-search-field')),
      'SECRET-VALUE-DO-NOT-DISPLAY',
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('empty-search-results')), findsOneWidget);
    expect(find.byKey(const ValueKey('entry-wifi')), findsNothing);
    expect(find.text('Wi-Fi de casa'), findsNothing);
  });
}

Future<void> _pumpHome(WidgetTester tester, {bool withEntry = false}) async {
  final directory = (await tester.runAsync(
    () => Directory.systemTemp.createTemp('llavero-home-test-'),
  ))!;
  final controllers = AppControllers(
    secureValues: MemorySecureValueStore(),
    vaultStorage: VaultStorage(directory: directory),
  );
  await tester.runAsync(
    () =>
        controllers.entries.unlock(dataKey: SecretKey(List<int>.filled(32, 4))),
  );
  if (withEntry) {
    await tester.runAsync(
      () => controllers.entries.addEntry(
        title: 'Wi-Fi de casa',
        category: 'wifi',
        person: 'Mamá',
        fields: const <EntryField>[
          EntryField(
            label: 'Contraseña',
            value: 'SECRET-VALUE-DO-NOT-DISPLAY',
            type: EntryFieldType.secret,
            isSecret: true,
          ),
        ],
      ),
    );
  }
  addTearDown(() async {
    controllers.dispose();
    await tester.runAsync(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
  });

  await tester.pumpWidget(
    AppScope(
      controllers: controllers,
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pump();
}
