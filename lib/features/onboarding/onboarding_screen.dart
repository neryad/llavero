import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_scope.dart';
import '../../core/security/pin_validator.dart';
import '../../l10n/generated/app_localizations.dart';
import 'pin_keypad.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String _pin = '';
  String? _firstPin;
  String? _confirmedPin;
  String? _pinError;
  String? _creationError;
  bool _confirmingPin = false;
  bool _checkingBiometrics = true;
  bool _biometricsAvailable = false;
  bool _enableBiometrics = false;
  bool _creatingVault = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkingBiometrics) {
      _checkingBiometrics = false;
      _checkBiometrics();
    }
  }

  Future<void> _checkBiometrics() async {
    final available = await AppScope.of(context).lock.canUseBiometrics();
    if (mounted) {
      setState(() => _biometricsAvailable = available);
    }
  }

  @override
  void dispose() {
    _pin = '';
    _firstPin = null;
    _confirmedPin = null;
    super.dispose();
  }

  void _goNext() {
    setState(() => _step = (_step + 1).clamp(0, 3).toInt());
  }

  void _goBack() {
    if (_step == 2 && _confirmingPin) {
      setState(() {
        _pin = '';
        _firstPin = null;
        _confirmingPin = false;
        _pinError = null;
      });
      return;
    }
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  Future<void> _selectLanguage(String languageCode) {
    return AppScope.of(context).settings.setLanguageCode(languageCode);
  }

  void _appendDigit(String digit) {
    if (_pin.length >= 6) {
      return;
    }
    setState(() {
      _pin += digit;
      _pinError = null;
    });
  }

  void _deleteDigit() {
    if (_pin.isEmpty) {
      return;
    }
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _pinError = null;
    });
  }

  void _submitPin() {
    if (_pin.length != 6) {
      return;
    }
    if (!_confirmingPin) {
      if (PinValidator.validate(_pin) != null) {
        setState(() => _pinError = AppLocalizations.of(context).pinTooEasy);
        return;
      }
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _confirmingPin = true;
        _pinError = null;
      });
      return;
    }

    if (_pin != _firstPin) {
      setState(() {
        _pin = '';
        _firstPin = null;
        _confirmingPin = false;
        _pinError = AppLocalizations.of(context).pinMismatch;
      });
      return;
    }

    setState(() {
      _confirmedPin = _pin;
      _pin = '';
      _confirmingPin = false;
      _pinError = null;
      _step = 3;
    });
  }

  Future<void> _createVault() async {
    final pin = _confirmedPin;
    if (pin == null || _creatingVault) {
      return;
    }
    setState(() {
      _creatingVault = true;
      _creationError = null;
    });

    try {
      await AppScope.of(
        context,
      ).lock.createVault(pin: pin, enableBiometrics: _enableBiometrics);
      if (!mounted) {
        return;
      }
      _confirmedPin = null;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on Object {
      if (mounted) {
        setState(
          () =>
              _creationError = AppLocalizations.of(context).vaultCreationFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _creatingVault = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stepTitles = <String>[
      strings.stepWelcome,
      strings.stepHowItWorks,
      strings.stepCreatePin,
      strings.stepSecurity,
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      if (_step > 0)
                        IconButton(
                          tooltip: strings.back,
                          onPressed: _goBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                        )
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          stepTitles[_step],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildProgress(theme),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.025),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey<int>(_step),
                          child: _buildStep(strings, theme),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(ThemeData theme) {
    return Row(
      children: List<Widget>.generate(4, (index) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
            decoration: BoxDecoration(
              color: index <= _step
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStep(AppLocalizations strings, ThemeData theme) {
    return switch (_step) {
      0 => _buildWelcome(strings, theme),
      1 => _buildHowItWorks(strings, theme),
      2 => _buildPinStep(strings, theme),
      _ => _buildSecurityStep(strings, theme),
    };
  }

  Widget _buildWelcome(AppLocalizations strings, ThemeData theme) {
    return Column(
      key: const ValueKey<String>('welcome-step'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 28),
        _brandIcon(theme),
        const SizedBox(height: 24),
        Text(
          strings.welcomeTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          strings.welcomeMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        Text(
          strings.welcomeTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(strings.languagePickerTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: <Widget>[
            OutlinedButton(
              key: const Key('language-es'),
              onPressed: () => _selectLanguage('es'),
              child: Text(strings.languageSpanish),
            ),
            OutlinedButton(
              key: const Key('language-en'),
              onPressed: () => _selectLanguage('en'),
              child: Text(strings.languageEnglish),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _primaryButton(
          key: const Key('onboarding-next'),
          label: strings.next,
          onPressed: _goNext,
        ),
      ],
    );
  }

  Widget _buildHowItWorks(AppLocalizations strings, ThemeData theme) {
    final items = <(IconData, String, String)>[
      (
        Icons.wifi_off_rounded,
        strings.howOfflineTitle,
        strings.howOfflineDescription,
      ),
      (
        Icons.lock_outline_rounded,
        strings.howEncryptionTitle,
        strings.howEncryptionDescription,
      ),
      (
        Icons.ios_share_rounded,
        strings.howExportTitle,
        strings.howExportDescription,
      ),
    ];

    return Column(
      key: const ValueKey<String>('how-it-works-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 24),
        Text(
          strings.howTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        for (final (icon, title, description) in items) ...<Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(icon, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(description, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        _primaryButton(
          key: const Key('onboarding-next'),
          label: strings.next,
          onPressed: _goNext,
        ),
      ],
    );
  }

  Widget _buildPinStep(AppLocalizations strings, ThemeData theme) {
    return Column(
      key: const ValueKey<String>('pin-step'),
      children: <Widget>[
        const SizedBox(height: 8),
        Text(
          _confirmingPin ? strings.pinConfirmTitle : strings.pinCreateTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          _confirmingPin
              ? strings.pinConfirmDescription
              : strings.pinCreateDescription,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          strings.pinStrengthHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _pinDots(strings, theme),
        if (_pinError != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            _pinError!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        PinKeypad(
          keyPrefix: 'onboarding',
          deleteLabel: strings.deleteDigit,
          onDigitPressed: _appendDigit,
          onDeletePressed: _deleteDigit,
        ),
        const SizedBox(height: 12),
        _primaryButton(
          key: const Key('onboarding-pin-continue'),
          label: _confirmingPin
              ? strings.pinConfirmButton
              : strings.pinContinue,
          onPressed: _pin.length == 6 ? _submitPin : null,
        ),
      ],
    );
  }

  Widget _buildSecurityStep(AppLocalizations strings, ThemeData theme) {
    return Column(
      key: const ValueKey<String>('security-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 16),
        Icon(
          Icons.verified_user_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          strings.biometricTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          strings.biometricDescription,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        if (_biometricsAvailable)
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(strings.biometricSwitchTitle),
            value: _enableBiometrics,
            onChanged: (value) => setState(() => _enableBiometrics = value),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                strings.biometricNotAvailable,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.noPinRecovery,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.forgotPinWarning,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.backupRecommendation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_creationError != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            _creationError!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _primaryButton(
          key: const Key('onboarding-create'),
          label: strings.createFirstEntry,
          onPressed: _creatingVault ? null : _createVault,
          isLoading: _creatingVault,
        ),
      ],
    );
  }

  Widget _brandIcon(ThemeData theme) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(
        Icons.key_rounded,
        size: 44,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _pinDots(AppLocalizations strings, ThemeData theme) {
    return Semantics(
      label: strings.pinDigitsEntered(_pin.length),
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(6, (index) {
            final filled = index < _pin.length;
            return Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: filled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.outline),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required Key key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        key: key,
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
