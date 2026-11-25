import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/security/security_health_analyzer.dart';
import '../../l10n/generated/app_localizations.dart';

class SecurityHealthScreen extends StatelessWidget {
  const SecurityHealthScreen({super.key});

  static const SecurityHealthAnalyzer _analyzer = SecurityHealthAnalyzer();

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.securityHealthTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListenableBuilder(
            listenable: controllers.entries,
            builder: (context, _) {
              final report = _analyzer.analyze(controllers.entries.entries);
              final needsAttention =
                  report.weakSecretCount > 0 || report.reusedSecretCount > 0;
              final colorScheme = Theme.of(context).colorScheme;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  Text(
                    strings.securityHealthDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.key_rounded),
                          title: Text(
                            strings.securityHealthChecked(
                              report.checkedSecretCount,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            needsAttention
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            color: needsAttention
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                          title: Text(
                            strings.securityHealthWeak(report.weakSecretCount),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            report.reusedSecretCount > 0
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            color: report.reusedSecretCount > 0
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                          title: Text(
                            strings.securityHealthReused(
                              report.reusedSecretCount,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    needsAttention
                        ? strings.securityHealthNeedsAttention
                        : strings.securityHealthAllClear,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
