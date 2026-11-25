import 'dart:async';

import 'package:flutter/material.dart';

import 'controllers/auto_lock_coordinator.dart';
import 'controllers/settings_controller.dart';
import 'core/app_routes.dart';
import 'core/app_scope.dart';
import 'core/security/screen_protection_service.dart';
import 'core/theme/app_theme.dart';
import 'features/bootstrap/bootstrap_screen.dart';
import 'features/entry/entry_form_screen.dart';
import 'features/home/home_screen.dart';
import 'features/lock/lock_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/entry/entry_detail_screen.dart';
import 'features/backup/export_import_screen.dart';
import 'features/security/security_health_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/trash/trash_screen.dart';
import 'l10n/generated/app_localizations.dart';

class LlaveroApp extends StatefulWidget {
  const LlaveroApp({super.key, this.controllers, this.locale, this.themeMode});

  final AppControllers? controllers;
  final Locale? locale;
  final ThemeMode? themeMode;

  @override
  State<LlaveroApp> createState() => _LlaveroAppState();
}

class _LlaveroAppState extends State<LlaveroApp> with WidgetsBindingObserver {
  late final AppControllers _controllers;
  late final bool _ownsControllers;
  late final AutoLockCoordinator _autoLockCoordinator;
  final ScreenProtectionService _screenProtectionService =
      const ScreenProtectionService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isInBackground = false;
  bool _lockRoutePending = false;
  bool? _lastScreenProtectionSetting;

  @override
  void initState() {
    super.initState();
    _controllers = widget.controllers ?? AppControllers();
    _ownsControllers = widget.controllers == null;
    _autoLockCoordinator = AutoLockCoordinator(
      settings: _controllers.settings,
      isVaultUnlocked: () => _controllers.lock.isUnlocked,
      lockVault: () {
        _controllers.lock.lock();
        _lockRoutePending = true;
        if (!_isInBackground) {
          _showLockScreen();
        }
      },
    );
    _controllers.settings.addListener(_syncScreenProtection);
    _syncScreenProtection();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controllers.settings.removeListener(_syncScreenProtection);
    _autoLockCoordinator.dispose();
    if (_ownsControllers) {
      _controllers.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isInBackground = false;
      _autoLockCoordinator.onForegrounded();
      unawaited(_controllers.clipboardClear.clearIfExpired());
      if (_lockRoutePending) {
        _showLockScreen();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (!_isInBackground) {
        _isInBackground = true;
        _autoLockCoordinator.onBackgrounded();
      }
    }
  }

  void _showLockScreen() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null || !_lockRoutePending) {
      return;
    }
    _lockRoutePending = false;
    navigator.pushNamedAndRemoveUntil(AppRoutes.lock, (_) => false);
  }

  void _syncScreenProtection() {
    final enabled = _controllers.settings.screenshotProtectionEnabled;
    if (_lastScreenProtectionSetting == enabled) {
      return;
    }
    _lastScreenProtectionSetting = enabled;
    unawaited(
      _screenProtectionService.setEnabled(enabled).catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controllers: _controllers,
      child: AnimatedBuilder(
        animation: _controllers.settings,
        builder: (context, _) => MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          initialRoute: AppRoutes.bootstrap,
          locale:
              widget.locale ??
              (_controllers.settings.languageCode == null
                  ? null
                  : Locale(_controllers.settings.languageCode!)),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: widget.themeMode ?? _themeModeFromSettings,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  ThemeMode get _themeModeFromSettings =>
      switch (_controllers.settings.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.bootstrap:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BootstrapScreen(),
        );
      case AppRoutes.onboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );
      case AppRoutes.lock:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LockScreen(),
        );
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case AppRoutes.entryForm:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => EntryFormScreen(
            entryId: settings.arguments is String
                ? settings.arguments! as String
                : null,
          ),
        );
      case AppRoutes.entryDetail:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => EntryDetailScreen(
            entryId: settings.arguments is String
                ? settings.arguments! as String
                : '',
          ),
        );
      case AppRoutes.trash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const TrashScreen(),
        );
      case AppRoutes.exportImport:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ExportImportScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );
      case AppRoutes.securityHealth:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SecurityHealthScreen(),
        );
      default:
        return null;
    }
  }
}
