import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'category_colors.dart';

abstract final class AppTheme {
  static const _lightBackground = Color(0xFFF7F5F0);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightSurfaceVariant = Color(0xFFECE8DF);
  static const _lightPrimary = Color(0xFF2F5D62);
  static const _lightAccent = Color(0xFFE0A458);
  static const _lightText = Color(0xFF1B2B2E);
  static const _lightSecondaryText = Color(0xFF5F7175);
  static const _lightOutline = Color(0xFFD5D0C5);
  static const _lightSuccess = Color(0xFF4C8C6B);
  static const _lightError = Color(0xFFC8553D);

  static const _darkBackground = Color(0xFF0F1A1C);
  static const _darkSurface = Color(0xFF172426);
  static const _darkSurfaceVariant = Color(0xFF1F3033);
  static const _darkPrimary = Color(0xFF6FB3B8);
  static const _darkAccent = Color(0xFFF0B866);
  static const _darkText = Color(0xFFE6EEEE);
  static const _darkSecondaryText = Color(0xFF8DA3A6);
  static const _darkOutline = Color(0xFF2E4447);
  static const _darkSuccess = Color(0xFF7CC59B);
  static const _darkError = Color(0xFFFF8A73);

  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    background: _lightBackground,
    surface: _lightSurface,
    surfaceVariant: _lightSurfaceVariant,
    primary: _lightPrimary,
    onPrimary: _lightSurface,
    accent: _lightAccent,
    text: _lightText,
    secondaryText: _lightSecondaryText,
    outline: _lightOutline,
    success: _lightSuccess,
    onSuccess: _lightSurface,
    error: _lightError,
    categoryColors: const CategoryColors(
      wifi: Color(0xFF3E8FB0),
      email: Color(0xFFC8553D),
      streaming: Color(0xFF8E5BB5),
      banking: Color(0xFF4C8C6B),
      pinCode: Color(0xFFE0A458),
      social: Color(0xFFD9667F),
      devices: Color(0xFF5F7175),
      documents: Color(0xFF7A8F3B),
      other: Color(0xFF8C7B6B),
    ),
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    background: _darkBackground,
    surface: _darkSurface,
    surfaceVariant: _darkSurfaceVariant,
    primary: _darkPrimary,
    onPrimary: const Color(0xFF06282B),
    accent: _darkAccent,
    text: _darkText,
    secondaryText: _darkSecondaryText,
    outline: _darkOutline,
    success: _darkSuccess,
    onSuccess: const Color(0xFF06282B),
    error: _darkError,
    categoryColors: const CategoryColors(
      wifi: Color(0xFF62B1CD),
      email: Color(0xFFFF8068),
      streaming: Color(0xFFBC8BE0),
      banking: Color(0xFF7CC59B),
      pinCode: Color(0xFFF0B866),
      social: Color(0xFFEF8BA0),
      devices: Color(0xFF8DA3A6),
      documents: Color(0xFFA5BA63),
      other: Color(0xFFB09B88),
    ),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color primary,
    required Color onPrimary,
    required Color accent,
    required Color text,
    required Color secondaryText,
    required Color outline,
    required Color success,
    required Color onSuccess,
    required Color error,
    required CategoryColors categoryColors,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          secondary: accent,
          onSecondary: const Color(0xFF2A1B00),
          tertiary: success,
          onTertiary: onSuccess,
          surface: surface,
          onSurface: text,
          onSurfaceVariant: secondaryText,
          surfaceContainerHighest: surfaceVariant,
          outline: outline,
          error: error,
          onError: brightness == Brightness.light
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF2A1B00),
        );

    final textTheme =
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ).apply(
          fontFamily: 'Plus Jakarta Sans',
          bodyColor: text,
          displayColor: text,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Plus Jakarta Sans',
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[
        categoryColors,
        const AppTypography(
          secret: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
