/// Builds the standard Wi-Fi QR payload without exposing it through a route.
String buildWifiQrPayload({
  required String networkName,
  required String? password,
  required String? securityType,
}) {
  final normalizedName = networkName.trim();
  if (normalizedName.isEmpty) {
    throw ArgumentError('Network name is required.');
  }

  final normalizedPassword = password ?? '';
  final normalizedSecurity = securityType?.trim().toLowerCase();
  final isOpen =
      normalizedPassword.isEmpty ||
      normalizedSecurity == 'none' ||
      normalizedSecurity == 'nopass' ||
      normalizedSecurity == 'open';
  final security = isOpen
      ? 'nopass'
      : normalizedSecurity == 'wep'
      ? 'WEP'
      : 'WPA';
  final escapedName = _escapeWifiValue(normalizedName);
  if (security == 'nopass') {
    return 'WIFI:T:nopass;S:$escapedName;;';
  }
  return 'WIFI:T:$security;S:$escapedName;P:${_escapeWifiValue(normalizedPassword)};;';
}

String _escapeWifiValue(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll(':', r'\:');
}
