import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/theme/app_theme.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/features/entry/entry_detail_screen.dart';
import 'package:llavero/l10n/generated/app_localizations.dart';

import '../support/memory_secure_value_store.dart';
import '../support/memory_vault_storage.dart';

void main() {
  testWidgets('keeps secrets hidden and hides them again after ten seconds', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(tester, _entry());

    expect(find.text('246810'), findsNothing);
    expect(find.byKey(const ValueKey('secret-mask-0')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reveal-secret-0')));
    await tester.pump();
    expect(find.text('246810'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(find.text('246810'), findsNothing);
  });

  testWidgets('supports favorite, duplicate and move-to-trash actions', (
    WidgetTester tester,
  ) async {
    final controllers = await _pumpDetail(tester, _entry());

    await tester.tap(find.byKey(const ValueKey('toggle-favorite-button')));
    await tester.pump();
    expect(controllers.entries.entries.single.isFavorite, isTrue);

    await tester.tap(find.byKey(const ValueKey('duplicate-entry-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(controllers.entries.entries, hasLength(2));

    await tester.tap(find.byKey(const ValueKey('move-to-trash-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-delete-entry-button')));
    await tester.pumpAndSettle();
    expect(
      controllers.entries.entries
          .singleWhere((entry) => entry.id == 'entry-1')
          .deletedAt,
      isNotNull,
    );
  });

  testWidgets('copies a field without revealing it on screen', (
    WidgetTester tester,
  ) async {
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await _pumpDetail(tester, _entry());

    await tester.tap(find.byKey(const ValueKey('copy-field-0')));
    await tester.pump();

    expect(
      calls.any(
        (call) =>
            call.method == 'Clipboard.setData' &&
            (call.arguments as Map<Object?, Object?>)['text'] == '246810',
      ),
      isTrue,
    );
    expect(find.text('246810'), findsNothing);
  });

  testWidgets('shows a QR only for Wi-Fi entries', (WidgetTester tester) async {
    await _pumpDetail(tester, _entry(category: 'wifi'));
    expect(find.byKey(const ValueKey('wifi-qr-code')), findsOneWidget);
  });

  testWidgets('does not show Wi-Fi QR for another category', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(tester, _entry(category: 'email'));
    expect(find.byKey(const ValueKey('wifi-qr-code')), findsNothing);
  });
}

Future<AppControllers> _pumpDetail(
  WidgetTester tester,
  VaultEntry entry,
) async {
  final storage = MemoryVaultStorage()..entries = <VaultEntry>[entry];
  final controllers = AppControllers(
    secureValues: MemorySecureValueStore(),
    vaultStorage: storage,
  );
  addTearDown(controllers.dispose);
  await controllers.entries.unlock(dataKey: SecretKey(List<int>.filled(32, 5)));
  await tester.pumpWidget(
    AppScope(
      controllers: controllers,
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: EntryDetailScreen(entryId: entry.id),
      ),
    ),
  );
  await tester.pump();
  return controllers;
}

VaultEntry _entry({String category = 'pin'}) {
  final now = DateTime.utc(2026, 3, 10);
  return VaultEntry(
    id: 'entry-1',
    title: 'Código de casa',
    category: category,
    fields: const <EntryField>[
      EntryField(
        label: 'Código',
        value: '246810',
        type: EntryFieldType.numberPin,
        isSecret: true,
      ),
      EntryField(
        label: 'Nombre de la red',
        value: 'Red familiar',
        type: EntryFieldType.text,
        isSecret: false,
      ),
      EntryField(
        label: 'Contraseña',
        value: 'clave-wifi',
        type: EntryFieldType.secret,
        isSecret: true,
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}
