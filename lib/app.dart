import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/bootstrap/bootstrap_screen.dart';
import 'features/home/placeholder_screen.dart';
import 'features/lock/lock_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/generated/app_localizations.dart';

class LlaveroApp extends StatefulWidget {
  const LlaveroApp({
    super.key,
    this.controllers,
    this.locale,
    this.themeMode = ThemeMode.system,
  });

  final AppControllers? controllers;
  final Locale? locale;
  final ThemeMode themeMode;

  @override
  State<LlaveroApp> createState() => _LlaveroAppState();
}

class _LlaveroAppState extends State<LlaveroApp> {
  late final AppControllers _controllers;
  late final bool _ownsControllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.controllers ?? AppControllers();
    _ownsControllers = widget.controllers == null;
  }

  @override
  void dispose() {
    if (_ownsControllers) {
      _controllers.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controllers: _controllers,
      child: AnimatedBuilder(
        animation: _controllers.settings,
        builder: (context, _) => MaterialApp(
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
          themeMode: widget.themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

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
          builder: (_) => const PlaceholderScreen(),
        );
      default:
        return null;
    }
  }
}
