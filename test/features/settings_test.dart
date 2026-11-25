import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/controllers/settings_controller.dart';
import 'package:llavero/features/settings/settings_screen.dart';
import 'package:llavero/l10n/generated/app_localizations.dart';

import '../support/memory_secure_value_store.dart';

void main() {
  testWidgets('shows appearance and security controls with safe defaults', (
    WidgetTester tester,
  ) async {
    final controllers = AppControllers(secureValues: MemorySecureValueStore());
    addTearDown(controllers.dispose);

    await tester.pumpWidget(
      AppScope(
        controllers: controllers,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-theme-mode')), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-auto-lock')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings-clipboard-clear')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('settings-screenshot-protection')),
      findsOneWidget,
    );
    expect(controllers.settings.themeMode, AppThemeMode.system);
    expect(controllers.settings.autoLockDuration, AutoLockDuration.immediate);
    expect(controllers.settings.screenshotProtectionEnabled, isTrue);
  });

  testWidgets('saves the selected auto-lock interval', (
    WidgetTester tester,
  ) async {
    final controllers = AppControllers(secureValues: MemorySecureValueStore());
    addTearDown(controllers.dispose);

    await tester.pumpWidget(
      AppScope(
        controllers: controllers,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-auto-lock')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 minute'));
    await tester.pumpAndSettle();

    expect(controllers.settings.autoLockDuration, AutoLockDuration.minute1);
  });
}
