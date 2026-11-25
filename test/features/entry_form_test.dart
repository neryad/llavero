import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/theme/app_theme.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/features/entry/entry_form_screen.dart';
import 'package:llavero/l10n/generated/app_localizations.dart';

import '../support/memory_secure_value_store.dart';
import '../support/memory_vault_storage.dart';

void main() {
  testWidgets('keeps form content within tablet width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpForm(tester);

    final formContent = find.byKey(const ValueKey('entry-form-content'));
    expect(formContent, findsOneWidget);
    expect(tester.getSize(formContent).width, lessThanOrEqualTo(720));
  });

  testWidgets('a Wi-Fi template creates localized editable fields', (
    WidgetTester tester,
  ) async {
    await _pumpForm(tester);
    await _chooseCategory(tester, 'Wi-Fi');

    expect(find.text('Nombre de la red'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Tipo de seguridad'), findsOneWidget);
    expect(find.byKey(const ValueKey('field-value-1')), findsOneWidget);
  });

  testWidgets('saves title, person and Wi-Fi template values', (
    WidgetTester tester,
  ) async {
    final controllers = await _pumpForm(tester);
    await _chooseCategory(tester, 'Wi-Fi');
    await tester.enterText(
      find.byKey(const ValueKey('entry-title-field')),
      'Red familiar',
    );
    await tester.enterText(
      find.byKey(const ValueKey('entry-person-field')),
      'Mamá',
    );
    await tester.enterText(find.byKey(const ValueKey('field-value-0')), 'Casa');
    await tester.enterText(
      find.byKey(const ValueKey('field-value-1')),
      'secreto-wifi',
    );

    await _saveForm(tester);

    final entry = controllers.entries.entries.single;
    expect(entry.title, 'Red familiar');
    expect(entry.person, 'Mamá');
    expect(entry.category, 'wifi');
    expect(entry.fields[0].value, 'Casa');
    expect(entry.fields[1].value, 'secreto-wifi');
  });

  testWidgets('creates a custom category and reorders/removes its fields', (
    WidgetTester tester,
  ) async {
    final controllers = await _pumpForm(tester);
    await tester.tap(find.byKey(const ValueKey('create-category-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('custom-category-name-field')),
      'Familia',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('custom-category-name-field')),
          )
          .controller
          ?.text,
      'Familia',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-category-button')));
    await tester.pumpAndSettle();
    expect(controllers.entries.customCategories, hasLength(1));

    final addField = find.byKey(const ValueKey('add-field-button'));
    await tester.ensureVisible(addField);
    await tester.tap(addField);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('field-label-0')));
    await tester.enterText(
      find.byKey(const ValueKey('field-label-0')),
      'Primero',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('field-value-0')));
    await tester.enterText(find.byKey(const ValueKey('field-value-0')), 'uno');
    await tester.ensureVisible(addField);
    await tester.tap(addField);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('field-label-1')));
    await tester.enterText(
      find.byKey(const ValueKey('field-label-1')),
      'Segundo',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('field-value-1')));
    await tester.enterText(find.byKey(const ValueKey('field-value-1')), 'dos');
    await tester.tap(find.byKey(const ValueKey('field-move-up-1')));
    await tester.pump();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('field-label-0')))
          .controller
          ?.text,
      'Segundo',
    );
    await tester.tap(find.byKey(const ValueKey('field-remove-1')));
    await tester.pump();
    expect(find.byKey(const ValueKey('field-label-1')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('entry-title-field')),
      'Dato de familia',
    );
    await _saveForm(tester);

    expect(find.text('Escribe un título para la entrada.'), findsNothing);
    expect(find.text('Cada campo necesita un nombre.'), findsNothing);
    expect(
      find.text(
        'No se pudo guardar. Comprueba la bóveda e inténtalo de nuevo.',
      ),
      findsNothing,
    );
    expect(find.text('Entrada guardada'), findsOneWidget);
    expect(controllers.entries.customCategories.single.name, 'Familia');
    expect(controllers.entries.entries.single.fields, hasLength(1));
    expect(controllers.entries.entries.single.fields.single.label, 'Segundo');
  });

  testWidgets('suggests a person already used in the vault', (
    WidgetTester tester,
  ) async {
    await _pumpForm(tester, initialEntries: <VaultEntry>[_existingEntry()]);

    await tester.enterText(
      find.byKey(const ValueKey('entry-person-field')),
      'Mam',
    );
    await tester.pumpAndSettle();
    expect(find.text('Mamá'), findsOneWidget);
    await tester.tap(find.text('Mamá'));
    await tester.pump();

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('entry-person-field')),
          )
          .controller
          ?.text,
      'Mamá',
    );
  });

  testWidgets('streaming service presets fill the service field', (
    WidgetTester tester,
  ) async {
    await _pumpForm(tester);
    await _chooseCategory(tester, 'Streaming');
    final presetField = find.byKey(const ValueKey('streaming-preset-field'));
    await tester.ensureVisible(presetField);
    await tester.tap(presetField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Netflix').last);
    await tester.pump();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('field-value-0')))
          .controller
          ?.text,
      'Netflix',
    );
  });

  testWidgets('generates and inserts a passphrase in a secret field', (
    WidgetTester tester,
  ) async {
    await _pumpForm(tester);
    await _chooseCategory(tester, 'Wi-Fi');
    final generatorButton = find.byKey(const ValueKey('field-generate-1'));
    await tester.ensureVisible(generatorButton);
    await tester.tap(generatorButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Frase de paso'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('generate-password-button')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('use-generated-password-button')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('use-generated-password-button')),
    );
    await tester.pumpAndSettle();

    final generated = tester
        .widget<TextFormField>(find.byKey(const ValueKey('field-value-1')))
        .controller!
        .text;
    expect(generated.split('-'), hasLength(5));
    expect(generated, isNotEmpty);
  });

  testWidgets('asks before discarding unsaved changes', (
    WidgetTester tester,
  ) async {
    await _pumpForm(tester);
    await tester.enterText(
      find.byKey(const ValueKey('entry-title-field')),
      'Cambios pendientes',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.tap(find.byTooltip('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('¿Descartar cambios?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('entry-title-field')), findsOneWidget);

    await tester.tap(find.byTooltip('Atrás'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar cambios'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('open-entry-form')), findsOneWidget);
  });
}

Future<AppControllers> _pumpForm(
  WidgetTester tester, {
  List<VaultEntry> initialEntries = const <VaultEntry>[],
}) async {
  final storage = MemoryVaultStorage()
    ..entries = List<VaultEntry>.of(initialEntries);
  final controllers = AppControllers(
    secureValues: MemorySecureValueStore(),
    vaultStorage: storage,
  );
  addTearDown(controllers.dispose);
  await controllers.entries.unlock(dataKey: SecretKey(List<int>.filled(32, 3)));
  await tester.pumpWidget(
    AppScope(
      controllers: controllers,
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const ValueKey('open-entry-form'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const EntryFormScreen(),
                  ),
                ),
                child: const Text('Abrir formulario'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open-entry-form')));
  await tester.pumpAndSettle();
  return controllers;
}

VaultEntry _existingEntry() {
  final now = DateTime.utc(2026, 8, 1);
  return VaultEntry(
    id: 'existing-entry',
    title: 'Cuenta familiar',
    category: 'other',
    person: 'Mamá',
    fields: const <EntryField>[],
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _chooseCategory(WidgetTester tester, String category) async {
  await tester.tap(find.byKey(const ValueKey('entry-category-field')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(category).last);
  await tester.pump();
  expect(
    tester
        .widget<DropdownButtonFormField<String>>(
          find.byKey(const ValueKey('entry-category-field')),
        )
        .initialValue,
    category == 'Wi-Fi' ? 'wifi' : 'streaming',
  );
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
