import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_scope.dart';
import '../../l10n/generated/app_localizations.dart';

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  bool _started = false;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    _initialize(AppScope.of(context));
  }

  Future<void> _initialize(AppControllers controllers) async {
    try {
      await controllers.settings.initialize();
      await controllers.lock.initialize();
      if (!mounted) {
        return;
      }
      final nextRoute = controllers.lock.hasVault
          ? AppRoutes.lock
          : AppRoutes.onboarding;
      Navigator.of(context).pushReplacementNamed(nextRoute);
    } on Object {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _failed
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    strings.startupFailed,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : Semantics(
                  label: strings.loading,
                  child: const CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
