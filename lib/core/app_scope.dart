import 'package:flutter/widgets.dart';

import '../core/security/biometric_key_store.dart';
import '../core/security/key_material_store.dart';
import '../core/security/lockout_manager.dart';
import '../core/security/secure_value_store.dart';
import '../core/security/vault_crypto.dart';
import '../data/vault_storage.dart';
import '../controllers/entries_controller.dart';
import '../controllers/lock_controller.dart';
import '../controllers/settings_controller.dart';

/// Owns the app controllers and forwards their notifications to the widget tree.
class AppControllers extends ChangeNotifier {
  factory AppControllers({
    SecureValueStore? secureValues,
    BiometricKeyStore? biometricKeyStore,
    DeviceAuthenticator? deviceAuthenticator,
    VaultStorage? vaultStorage,
    VaultCrypto? crypto,
    DateTime Function()? clock,
  }) {
    final values = secureValues ?? FlutterSecureValueStore();
    final entries = EntriesController(storage: vaultStorage);
    final lock = LockController(
      keyStore: KeyMaterialStore(values),
      lockout: LockoutManager(
        store: SecureLockoutStateStore(values),
        clock: clock,
      ),
      values: values,
      biometricStore: biometricKeyStore ?? SecureBiometricKeyStore(),
      authenticator: deviceAuthenticator ?? LocalDeviceAuthenticator(),
      vaultEntries: entries,
      crypto: crypto,
      clock: clock,
    );
    return AppControllers._(
      settings: SettingsController(store: values),
      lock: lock,
      entries: entries,
    );
  }

  AppControllers._({
    required this.settings,
    required this.lock,
    required this.entries,
  }) {
    settings.addListener(notifyListeners);
    lock.addListener(notifyListeners);
    entries.addListener(notifyListeners);
  }

  final SettingsController settings;
  final LockController lock;
  final EntriesController entries;

  @override
  void dispose() {
    settings.removeListener(notifyListeners);
    lock.removeListener(notifyListeners);
    entries.removeListener(notifyListeners);
    settings.dispose();
    lock.dispose();
    entries.dispose();
    super.dispose();
  }
}

/// Makes the shared controllers available to widgets below the app root.
class AppScope extends InheritedNotifier<AppControllers> {
  const AppScope({
    super.key,
    required AppControllers controllers,
    required super.child,
  }) : super(notifier: controllers);

  static AppControllers of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw FlutterError('AppScope.of() called without an AppScope ancestor.');
    }
    return scope.notifier!;
  }
}
