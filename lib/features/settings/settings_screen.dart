import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/settings_controller.dart';
import '../../core/app_routes.dart';
import '../../core/app_scope.dart';
import '../../core/security/pin_validator.dart';
import '../../l10n/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListenableBuilder(
            listenable: controllers,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                _sectionTitle(context, strings.settingsAppearance),
                _dropdown<AppThemeMode>(
                  key: const ValueKey('settings-theme-mode'),
                  label: strings.settingsTheme,
                  value: controllers.settings.themeMode,
                  options: <AppThemeMode, String>{
                    AppThemeMode.system: strings.settingsThemeSystem,
                    AppThemeMode.light: strings.settingsThemeLight,
                    AppThemeMode.dark: strings.settingsThemeDark,
                  },
                  onChanged: controllers.settings.setThemeMode,
                ),
                _dropdown<String>(
                  key: const ValueKey('settings-language'),
                  label: strings.settingsLanguage,
                  value: controllers.settings.languageCode ?? '',
                  options: <String, String>{
                    '': strings.settingsLanguageSystem,
                    'es': strings.languageSpanish,
                    'en': strings.languageEnglish,
                  },
                  onChanged: (code) => controllers.settings.setLanguageCode(
                    code.isEmpty ? null : code,
                  ),
                ),
                _sectionTitle(context, strings.settingsSecurity),
                _dropdown<AutoLockDuration>(
                  key: const ValueKey('settings-auto-lock'),
                  label: strings.settingsAutoLock,
                  value: controllers.settings.autoLockDuration,
                  options: <AutoLockDuration, String>{
                    AutoLockDuration.immediate:
                        strings.settingsAutoLockImmediate,
                    AutoLockDuration.seconds30:
                        strings.settingsAutoLock30Seconds,
                    AutoLockDuration.minute1: strings.settingsAutoLock1Minute,
                    AutoLockDuration.minutes5: strings.settingsAutoLock5Minutes,
                  },
                  onChanged: controllers.settings.setAutoLockDuration,
                ),
                _dropdown<ClipboardClearDuration>(
                  key: const ValueKey('settings-clipboard-clear'),
                  label: strings.settingsClipboardClear,
                  value: controllers.settings.clipboardClearDuration,
                  options: <ClipboardClearDuration, String>{
                    ClipboardClearDuration.seconds30:
                        strings.settingsClipboard30Seconds,
                    ClipboardClearDuration.minute1:
                        strings.settingsClipboard1Minute,
                    ClipboardClearDuration.minutes2:
                        strings.settingsClipboard2Minutes,
                  },
                  onChanged: controllers.settings.setClipboardClearDuration,
                ),
                SwitchListTile(
                  key: const ValueKey('settings-screenshot-protection'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.settingsScreenshotProtection),
                  subtitle: Text(strings.settingsScreenshotDescription),
                  value: controllers.settings.screenshotProtectionEnabled,
                  onChanged: (enabled) => _setScreenProtection(enabled),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.password_rounded),
                  title: Text(strings.settingsChangePin),
                  onTap: _changePin,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.settingsBiometrics),
                  subtitle: Text(strings.settingsBiometricsDescription),
                  value: controllers.lock.biometricsEnabled,
                  onChanged: (enabled) => _setBiometrics(enabled),
                ),
                _sectionTitle(context, strings.settingsData),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.health_and_safety_outlined),
                  title: Text(strings.settingsSecurityHealth),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.securityHealth),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.backup_outlined),
                  title: Text(strings.settingsBackup),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.exportImport),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: Text(strings.settingsTrash),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.trash),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _dropdown<T extends Object>({
    required Key key,
    required String label,
    required T value,
    required Map<T, String> options,
    required Future<void> Function(T) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      key: key,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: options.entries
          .map(
            (option) => DropdownMenuItem<T>(
              value: option.key,
              child: Text(option.value),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value != null) {
          unawaited(onChanged(value));
        }
      },
    );
  }

  Future<void> _setScreenProtection(bool enabled) async {
    final settings = AppScope.of(context).settings;
    await settings.setScreenshotProtectionEnabled(enabled);
  }

  Future<void> _setBiometrics(bool enabled) async {
    final controllers = AppScope.of(context);
    final strings = AppLocalizations.of(context);
    final pin = await _askForCurrentPin(strings);
    if (pin == null || !mounted) {
      return;
    }
    try {
      final changed = await controllers.lock.setBiometricsEnabled(
        enabled: enabled,
        pin: pin,
        reason: strings.biometricTitle,
      );
      if (!changed && mounted) {
        _showMessage(strings.settingsBiometricsFailed);
      }
    } on Object {
      if (mounted) {
        _showMessage(strings.settingsBiometricsFailed);
      }
    }
  }

  Future<String?> _askForCurrentPin(AppLocalizations strings) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.settingsCurrentPin),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: AppScope.of(context).lock.pinLength,
          decoration: InputDecoration(labelText: strings.settingsCurrentPin),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(strings.confirm),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _changePin() async {
    final controllers = AppScope.of(context);
    final strings = AppLocalizations.of(context);
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    var selectedLength = controllers.lock.pinLength;
    String? validationMessage;

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(strings.settingsPinDialogTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: currentPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: controllers.lock.pinLength,
                    decoration: InputDecoration(
                      labelText: strings.settingsCurrentPin,
                    ),
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: selectedLength,
                    decoration: InputDecoration(
                      labelText: strings.settingsPinLength,
                    ),
                    items: List<DropdownMenuItem<int>>.generate(
                      5,
                      (index) => DropdownMenuItem<int>(
                        value: index + 4,
                        child: Text('${index + 4}'),
                      ),
                    ),
                    onChanged: (length) {
                      if (length != null) {
                        setDialogState(() => selectedLength = length);
                      }
                    },
                  ),
                  TextField(
                    controller: newPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: selectedLength,
                    decoration: InputDecoration(
                      labelText: strings.settingsNewPin,
                    ),
                  ),
                  TextField(
                    controller: confirmPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: selectedLength,
                    decoration: InputDecoration(
                      labelText: strings.settingsConfirmNewPin,
                      errorText: validationMessage,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final newPin = newPinController.text;
                  if (newPin != confirmPinController.text) {
                    setDialogState(
                      () => validationMessage = strings.settingsPinMismatch,
                    );
                    return;
                  }
                  if (PinValidator.validate(newPin, length: selectedLength) !=
                      null) {
                    setDialogState(
                      () => validationMessage = strings.settingsPinInvalid,
                    );
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: Text(strings.confirm),
              ),
            ],
          ),
        ),
      );
      if (shouldSave != true || !mounted) {
        return;
      }
      final changed = await controllers.lock.changePin(
        currentPin: currentPinController.text,
        newPin: newPinController.text,
      );
      if (mounted) {
        _showMessage(
          changed
              ? strings.settingsPinChanged
              : strings.settingsPinChangeFailed,
        );
      }
    } finally {
      currentPinController.dispose();
      newPinController.dispose();
      confirmPinController.dispose();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
