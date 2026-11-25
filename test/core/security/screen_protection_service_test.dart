import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/screen_protection_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('llavero/test-screen-protection');

  test(
    'sends the selected screenshot protection state to the platform',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final service = ScreenProtectionService(channel: channel);

      await service.setEnabled(false);

      expect(calls, hasLength(1));
      expect(calls.single.method, 'setEnabled');
      expect(calls.single.arguments, isFalse);
    },
  );
}
