import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/app_routes.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/theme/app_theme.dart';
import 'package:llavero/features/entry/entry_detail_screen.dart';
import 'package:llavero/features/entry/entry_form_screen.dart';
import 'package:llavero/features/home/home_screen.dart';
import 'package:llavero/features/trash/trash_screen.dart';
import 'package:llavero/l10n/generated/app_localizations.dart';

import '../support/memory_secure_value_store.dart';
import '../support/memory_vault_storage.dart';

void main() {
  testWidgets('creates, searches, edits, trashes and restores an entry', (
    WidgetTester tester,
  ) async {
    final controllers = AppControllers(
      secureValues: MemorySecureValueStore(),
      vaultStorage: MemoryVaultStorage(),
    );
    addTearDown(controllers.dispose);
    await controllers.entries.unlock(
      dataKey: SecretKey(List<int>.filled(32, 6)),
    );
    final detailRouteArguments = <Object?>[];
    final formRouteArguments = <Object?>[];

    await tester.pumpWidget(
      AppScope(
        controllers: controllers,
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const HomeScreen(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.entryForm:
                formRouteArguments.add(settings.arguments);
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => EntryFormScreen(
                    entryId: settings.arguments is String
                        ? settings.arguments! as String
                        : null,
                  ),
                );
              case AppRoutes.entryDetail:
                detailRouteArguments.add(settings.arguments);
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) =>
                      EntryDetailScreen(entryId: settings.arguments! as String),
                );
              case AppRoutes.trash:
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => const TrashScreen(),
                );
            }
            return null;
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('add-entry-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-category-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wi-Fi').last);
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('entry-title-field')),
      'Red familiar',
    );
    await tester.enterText(
      find.byKey(const ValueKey('field-value-0')),
      'CasaNet',
    );
    await tester.enterText(
      find.byKey(const ValueKey('field-value-1')),
      'flow-secret',
    );
    await _saveForm(tester);

    final entryId = controllers.entries.entries.single.id;
    expect(controllers.entries.entries.single.title, 'Red familiar');
    expect(formRouteArguments.first, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('entry-search-field')),
      'Red familiar',
    );
    await tester.pump();
    final entryCard = find.byKey(ValueKey('entry-$entryId'));
    await tester.ensureVisible(entryCard);
    await tester.tap(entryCard);
    await tester.pumpAndSettle();
    expect(detailRouteArguments.single, entryId);
    expect(find.text('flow-secret'), findsNothing);
    expect(find.byKey(const ValueKey('secret-mask-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('edit-entry-button')));
    await tester.pumpAndSettle();
    expect(formRouteArguments.last, entryId);
    await tester.enterText(
      find.byKey(const ValueKey('entry-title-field')),
      'Red familiar actualizada',
    );
    await _saveForm(tester);
    await tester.pumpAndSettle();
    expect(find.text('Red familiar actualizada'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('move-to-trash-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-delete-entry-button')));
    await tester.pumpAndSettle();
    expect(
      controllers.entries.entries
          .singleWhere((entry) => entry.id == entryId)
          .deletedAt,
      isNotNull,
    );

    await tester.enterText(
      find.byKey(const ValueKey('entry-search-field')),
      '',
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Papelera'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('trash-restore-$entryId')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      controllers.entries.entries
          .singleWhere((entry) => entry.id == entryId)
          .deletedAt,
      isNull,
    );
  });
}

Future<void> _saveForm(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  final saveButton = find.byKey(const ValueKey('save-entry-button'));
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
