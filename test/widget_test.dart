// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/app.dart';
import 'package:llavero/core/app_scope.dart';
import 'package:llavero/core/theme/app_typography.dart';

import 'support/memory_secure_value_store.dart';

void main() {
  testWidgets('shows Spanish onboarding with the light theme', (
    WidgetTester tester,
  ) async {
    final controllers = AppControllers(secureValues: MemorySecureValueStore());
    await tester.pumpWidget(
      LlaveroApp(
        controllers: controllers,
        locale: const Locale('es'),
        themeMode: ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a Llavero'), findsOneWidget);
    expect(find.text('Todo offline, todo tuyo'), findsOneWidget);

    final context = tester.element(find.text('Bienvenido a Llavero'));
    final theme = Theme.of(context);
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, const Color(0xFF2F5D62));
    expect(theme.colorScheme.tertiary, const Color(0xFF4C8C6B));
    expect(theme.textTheme.bodyLarge?.fontFamily, 'Plus Jakarta Sans');
    expect(
      theme.extension<AppTypography>()!.secret.fontFamily,
      'JetBrains Mono',
    );
  });

  testWidgets('shows English onboarding with the dark theme', (
    WidgetTester tester,
  ) async {
    final controllers = AppControllers(secureValues: MemorySecureValueStore());
    await tester.pumpWidget(
      LlaveroApp(
        controllers: controllers,
        locale: const Locale('en'),
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Llavero'), findsOneWidget);
    expect(find.text('Offline, all yours'), findsOneWidget);

    final context = tester.element(find.text('Welcome to Llavero'));
    final theme = Theme.of(context);
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, const Color(0xFF6FB3B8));
    expect(theme.colorScheme.tertiary, const Color(0xFF7CC59B));
  });

  testWidgets('exposes shared controllers through AppScope', (
    WidgetTester tester,
  ) async {
    final controllers = AppControllers();
    AppControllers? exposedControllers;

    await tester.pumpWidget(
      AppScope(
        controllers: controllers,
        child: Builder(
          builder: (context) {
            exposedControllers = AppScope.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(exposedControllers, same(controllers));
    controllers.dispose();
  });
}
