import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/controllers/settings_controller.dart';

import '../support/memory_secure_value_store.dart';

void main() {
  group('SettingsController', () {
    test('persists the selected language and restores it on startup', () async {
      final secureValues = MemorySecureValueStore();
      final controller = SettingsController(store: secureValues);
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.languageCode, isNull);

      await controller.setLanguageCode('es');

      expect(controller.languageCode, 'es');
      expect(secureValues.values[SettingsController.languageStorageKey], 'es');

      final restored = SettingsController(store: secureValues);
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.languageCode, 'es');
    });

    test('rejects unsupported language codes', () async {
      final controller = SettingsController(store: MemorySecureValueStore());
      addTearDown(controller.dispose);

      await expectLater(controller.setLanguageCode('fr'), throwsArgumentError);
    });
  });
}
