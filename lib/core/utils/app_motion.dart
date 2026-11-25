import 'package:flutter/material.dart';

abstract final class AppMotion {
  static Duration duration(BuildContext context, Duration preferred) {
    return MediaQuery.of(context).disableAnimations ? Duration.zero : preferred;
  }
}
