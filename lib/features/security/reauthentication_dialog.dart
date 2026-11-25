import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../l10n/generated/app_localizations.dart';

/// Requests the vault PIN or enabled device biometrics before a sensitive action.
class ReauthenticationDialog extends StatefulWidget {
  const ReauthenticationDialog({
    super.key,
    required this.controllers,
    required this.prompt,
    required this.reason,
  });

  final AppControllers controllers;
  final String prompt;
  final String reason;

  @override
  State<ReauthenticationDialog> createState() => _ReauthenticationDialogState();
}

class _ReauthenticationDialogState extends State<ReauthenticationDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;
  bool _isBusy = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.reauthenticateTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.prompt),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('reauthenticate-pin-field'),
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: strings.reauthenticatePin,
                errorText: _errorMessage,
              ),
            ),
            if (widget.controllers.lock.biometricsEnabled)
              TextButton.icon(
                key: const ValueKey('reauthenticate-biometrics'),
                onPressed: _isBusy ? null : _authenticateWithBiometrics,
                icon: const Icon(Icons.fingerprint_rounded),
                label: Text(strings.reauthenticateWithBiometrics),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('cancel-reauthentication'),
          onPressed: _isBusy ? null : () => Navigator.pop(context, false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          key: const ValueKey('confirm-reauthentication'),
          onPressed: _isBusy ? null : _authenticateWithPin,
          child: _isBusy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(strings.confirm),
        ),
      ],
    );
  }

  Future<void> _authenticateWithPin() {
    final pin = _pinController.text;
    return _runAuthentication(
      () => widget.controllers.lock.reauthenticateWithPin(pin),
    );
  }

  Future<void> _authenticateWithBiometrics() {
    return _runAuthentication(
      () => widget.controllers.lock.reauthenticateWithBiometrics(
        reason: widget.reason,
      ),
    );
  }

  Future<void> _runAuthentication(Future<bool> Function() authenticate) async {
    setState(() => _isBusy = true);
    try {
      if (await authenticate()) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).reauthenticationFailed;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).reauthenticationFailed;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}
