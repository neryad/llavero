import 'package:flutter/material.dart';

import 'core/app_routes.dart';
import 'core/app_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/home/placeholder_screen.dart';
import 'l10n/generated/app_localizations.dart';

class LlaveroApp extends StatefulWidget {
  const LlaveroApp({super.key, this.locale, this.themeMode = ThemeMode.system});

  final Locale? locale;
  final ThemeMode themeMode;

  @override
  State<LlaveroApp> createState() => _LlaveroAppState();
}

class _LlaveroAppState extends State<LlaveroApp> {
  late final AppControllers _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = AppControllers();
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controllers: _controllers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        locale: widget.locale,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: widget.themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
