import 'package:flutter/material.dart';

@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({required this.secret});

  final TextStyle secret;

  @override
  AppTypography copyWith({TextStyle? secret}) {
    return AppTypography(secret: secret ?? this.secret);
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) {
      return this;
    }

    return AppTypography(secret: TextStyle.lerp(secret, other.secret, t)!);
  }
}
