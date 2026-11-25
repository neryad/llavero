import 'package:flutter/material.dart';

/// Theme-aware colors used to identify vault entry categories.
@immutable
class CategoryColors extends ThemeExtension<CategoryColors> {
  const CategoryColors({
    required this.wifi,
    required this.email,
    required this.streaming,
    required this.banking,
    required this.pinCode,
    required this.social,
    required this.devices,
    required this.documents,
    required this.other,
  });

  final Color wifi;
  final Color email;
  final Color streaming;
  final Color banking;
  final Color pinCode;
  final Color social;
  final Color devices;
  final Color documents;
  final Color other;

  @override
  CategoryColors copyWith({
    Color? wifi,
    Color? email,
    Color? streaming,
    Color? banking,
    Color? pinCode,
    Color? social,
    Color? devices,
    Color? documents,
    Color? other,
  }) {
    return CategoryColors(
      wifi: wifi ?? this.wifi,
      email: email ?? this.email,
      streaming: streaming ?? this.streaming,
      banking: banking ?? this.banking,
      pinCode: pinCode ?? this.pinCode,
      social: social ?? this.social,
      devices: devices ?? this.devices,
      documents: documents ?? this.documents,
      other: other ?? this.other,
    );
  }

  @override
  CategoryColors lerp(ThemeExtension<CategoryColors>? other, double t) {
    if (other is! CategoryColors) {
      return this;
    }

    return CategoryColors(
      wifi: Color.lerp(wifi, other.wifi, t)!,
      email: Color.lerp(email, other.email, t)!,
      streaming: Color.lerp(streaming, other.streaming, t)!,
      banking: Color.lerp(banking, other.banking, t)!,
      pinCode: Color.lerp(pinCode, other.pinCode, t)!,
      social: Color.lerp(social, other.social, t)!,
      devices: Color.lerp(devices, other.devices, t)!,
      documents: Color.lerp(documents, other.documents, t)!,
      other: Color.lerp(this.other, other.other, t)!,
    );
  }
}
