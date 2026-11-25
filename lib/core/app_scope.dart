import 'package:flutter/widgets.dart';

import '../controllers/entries_controller.dart';
import '../controllers/lock_controller.dart';
import '../controllers/settings_controller.dart';

/// Owns the app controllers and forwards their notifications to the widget tree.
class AppControllers extends ChangeNotifier {
  AppControllers()
    : settings = SettingsController(),
      lock = LockController(),
      entries = EntriesController() {
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
