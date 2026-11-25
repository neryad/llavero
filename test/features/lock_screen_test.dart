import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/theme/app_theme.dart';
import 'package:llavero/features/lock/lock_screen.dart';
import 'package:llavero/l10n/generated/app_localizations.dart';

import '../support/memory_secure_value_store.dart';
import '../support/memory_vault_crypto.dart';
import '../support/memory_vault_storage.dart';

void main() {
  testWidgets('platform reduced motion suppresses incorrect PIN shake', (
    WidgetTester tester,
  ) async {
    final controllers = AppControllers(
      secureValues: MemorySecureValueStore(),
      vaultStorage: MemoryVaultStorage(),
      crypto: MemoryVaultCrypto(),
    );
    addTearDown(controllers.dispose);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await controllers.lock.createVault(pin: MemoryVaultCrypto.correctPin);
    controllers.lock.lock();

    await tester.pumpWidget(
      AppScope(
        controllers: controllers,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const LockScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _enterWrongPin(tester);
    await tester.pumpAndSettle();
    final screenContext = tester.element(find.byType(LockScreen));
    expect(
      find.text(AppLocalizations.of(screenContext).wrongPin),
      findsOneWidget,
    );

    await _enterWrongPin(tester);
    final wrongPinMessage = find.text(
      AppLocalizations.of(screenContext).wrongPin,
    );
    for (
      var index = 0;
      index < 10 && wrongPinMessage.evaluate().isEmpty;
      index++
    ) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(wrongPinMessage, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 20));

    final shakeTransform = find
        .ancestor(
          of: find.byKey(const ValueKey('lock-digit-1')),
          matching: find.byType(Transform),
        )
        .last;
    final transform = tester.widget<Transform>(shakeTransform);
    expect(transform.transform.getTranslation().x, 0);
  });
}

Future<void> _enterWrongPin(WidgetTester tester) async {
  for (var index = 0; index < MemoryVaultCrypto.correctPin.length; index++) {
    await tester.tap(find.byKey(const ValueKey('lock-digit-1')));
    await tester.pump();
  }
  await tester.pump();
}
