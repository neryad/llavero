import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/utils/wifi_qr.dart';

void main() {
  test('escapes reserved characters in Wi-Fi network names and passwords', () {
    final payload = buildWifiQrPayload(
      networkName: 'Family; Wi,Fi',
      password: r'p\ass:word',
      securityType: 'WPA2',
    );

    expect(payload, r'WIFI:T:WPA;S:Family\; Wi\,Fi;P:p\\ass\:word;;');
  });

  test('creates an open-network payload without a password', () {
    expect(
      buildWifiQrPayload(
        networkName: 'Guest',
        password: null,
        securityType: 'None',
      ),
      'WIFI:T:nopass;S:Guest;;',
    );
  });

  test('rejects a missing network name', () {
    expect(
      () => buildWifiQrPayload(
        networkName: ' ',
        password: null,
        securityType: 'WPA',
      ),
      throwsArgumentError,
    );
  });
}
