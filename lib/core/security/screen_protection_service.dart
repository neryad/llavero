import 'package:flutter/services.dart';

/// Toggles the native screenshot and app-switcher privacy protections.
class ScreenProtectionService {
  const ScreenProtectionService({
    this.channel = const MethodChannel('llavero/screen_protection'),
  });

  final MethodChannel channel;

  Future<void> setEnabled(bool enabled) async {
    try {
      await channel.invokeMethod<void>('setEnabled', enabled);
    } on MissingPluginException {
      // Some non-mobile Flutter targets do not register this native channel.
    }
  }
}
