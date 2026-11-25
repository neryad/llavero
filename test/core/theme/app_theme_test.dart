import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/theme/app_theme.dart';
import 'package:llavero/core/widgets/category_chip.dart';

void main() {
  test('normal theme text and container pairs meet WCAG AA contrast', () {
    final themes = <ThemeData>[AppTheme.light, AppTheme.dark];

    for (final theme in themes) {
      final scheme = theme.colorScheme;
      expect(
        _contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.onSecondary, scheme.secondary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.onTertiary, scheme.tertiary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.onError, scheme.error),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets('selected category labels meet AA contrast in both themes', (
    WidgetTester tester,
  ) async {
    const categoryIds = <String>[
      'wifi',
      'email',
      'streaming',
      'banking',
      'pin',
      'social',
      'devices',
      'documents',
      'other',
    ];

    for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      for (final categoryId in categoryIds) {
        await tester.pumpWidget(
          MaterialApp(
            home: Theme(
              data: theme,
              child: Scaffold(
                body: CategoryChip(
                  categoryId: categoryId,
                  label: categoryId,
                  selected: true,
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
        );

        final actualTheme = Theme.of(tester.element(find.byType(CategoryChip)));
        expect(actualTheme.brightness, theme.brightness);
        expect(actualTheme.colorScheme.onSurface, theme.colorScheme.onSurface);
        final chip = tester.widget<FilterChip>(find.byType(FilterChip));
        final background = Color.alphaBlend(
          chip.selectedColor!,
          theme.colorScheme.surface,
        );
        expect(
          _contrast(chip.labelStyle!.color!, background),
          greaterThanOrEqualTo(4.5),
          reason:
              '$categoryId in ${theme.brightness} theme: '
              'text=${chip.labelStyle!.color}, fill=${chip.selectedColor}, '
              'surface=${theme.colorScheme.surface}, background=$background',
        );
      }
    }
  });
}

double _contrast(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}
