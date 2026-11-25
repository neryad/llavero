import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_routes.dart';
import '../../core/app_scope.dart';
import '../../l10n/generated/app_localizations.dart';
import '../onboarding/pin_keypad.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  Timer? _countdownTimer;
  String _pin = '';
  String? _errorMessage;
  bool _autoBiometricAttempted = false;
  bool _attemptingUnlock = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lock = AppScope.of(context).lock;
    if (lock.lockoutState.remainingAt(DateTime.now()) > Duration.zero) {
      _startCountdownTimer();
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
    }
    if (_autoBiometricAttempted) {
      return;
    }
    _autoBiometricAttempted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && AppScope.of(context).lock.biometricsEnabled) {
        _unlockWithBiometrics();
      }
    });
  }

  void _startCountdownTimer() {
    if (_countdownTimer != null) {
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (AppScope.of(
              context,
            ).lock.lockoutState.remainingAt(DateTime.now()) <=
            Duration.zero) {
          timer.cancel();
          _countdownTimer = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _shakeController.dispose();
    _pin = '';
    super.dispose();
  }

  void _appendDigit(String digit) {
    final pinLength = AppScope.of(context).lock.pinLength;
    if (_pin.length >= pinLength || _attemptingUnlock || _isLockedOut) {
      return;
    }
    setState(() {
      _pin += digit;
      _errorMessage = null;
    });
    if (_pin.length == pinLength) {
      _unlockWithPin(_pin);
    }
  }

  void _deleteDigit() {
    if (_pin.isEmpty || _attemptingUnlock || _isLockedOut) {
      return;
    }
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }

  bool get _isLockedOut {
    return AppScope.of(context).lock.lockoutState.remainingAt(DateTime.now()) >
        Duration.zero;
  }

  Future<void> _unlockWithPin(String pin) async {
    if (_attemptingUnlock) {
      return;
    }
    setState(() => _attemptingUnlock = true);
    final success = await AppScope.of(context).lock.unlockWithPin(pin);
    if (!mounted) {
      return;
    }
    if (success) {
      _goToHome();
      return;
    }

    setState(() {
      _pin = '';
      _errorMessage = AppLocalizations.of(context).wrongPin;
      _attemptingUnlock = false;
    });
    _shakeController.forward(from: 0);
    unawaited(HapticFeedback.heavyImpact());
  }

  Future<void> _unlockWithBiometrics() async {
    if (_attemptingUnlock) {
      return;
    }
    setState(() {
      _attemptingUnlock = true;
      _errorMessage = null;
    });
    final success = await AppScope.of(context).lock.unlockWithBiometrics();
    if (!mounted) {
      return;
    }
    if (success) {
      _goToHome();
      return;
    }
    setState(() {
      _attemptingUnlock = false;
      _errorMessage = AppLocalizations.of(context).biometricUnlockFailed;
    });
  }

  void _goToHome() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Future<void> _startEraseFlow() async {
    final strings = AppLocalizations.of(context);
    final typedPhrase = await _askForErasePhrase(strings);
    if (typedPhrase == null || !mounted) {
      return;
    }

    final controller = AppScope.of(context).lock;
    var erased = await controller.eraseWithDeviceAuthentication(
      typedConfirmation: typedPhrase,
      confirmationPhrase: strings.eraseConfirmationPhrase,
      reason: strings.eraseDeviceReason,
    );
    if (!erased && mounted) {
      final pin = await _askForErasePin(strings);
      if (pin == null || !mounted) {
        return;
      }
      erased = await controller.eraseWithPin(
        pin: pin,
        typedConfirmation: typedPhrase,
        confirmationPhrase: strings.eraseConfirmationPhrase,
      );
    }

    if (!mounted) {
      return;
    }
    if (erased) {
      _pin = '';
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    } else {
      setState(() => _errorMessage = strings.erasePinIncorrect);
    }
  }

  Future<String?> _askForErasePhrase(AppLocalizations strings) async {
    final textController = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(strings.eraseDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(strings.eraseDialogMessage),
                const SizedBox(height: 16),
                Text(strings.eraseTypePrompt(strings.eraseConfirmationPhrase)),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed:
                    textController.text.trim() ==
                        strings.eraseConfirmationPhrase
                    ? () => Navigator.pop(
                        dialogContext,
                        textController.text.trim(),
                      )
                    : null,
                child: Text(strings.eraseContinue),
              ),
            ],
          ),
        ),
      );
    } finally {
      textController.dispose();
    }
  }

  Future<String?> _askForErasePin(AppLocalizations strings) {
    var pin = '';
    final pinLength = AppScope.of(context).lock.pinLength;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(strings.erasePinFallbackTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(strings.erasePinFallbackDescription),
                const SizedBox(height: 12),
                _pinDots(strings, pin.length, pinLength),
                const SizedBox(height: 12),
                PinKeypad(
                  keyPrefix: 'erase-pin',
                  deleteLabel: strings.deleteDigit,
                  onDigitPressed: (digit) {
                    if (pin.length < pinLength) {
                      setDialogState(() => pin += digit);
                    }
                  },
                  onDeletePressed: () {
                    if (pin.isNotEmpty) {
                      setDialogState(
                        () => pin = pin.substring(0, pin.length - 1),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: pin.length == pinLength
                  ? () => Navigator.pop(dialogContext, pin)
                  : null,
              child: Text(strings.eraseContinue),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final remaining = controllers.lock.lockoutState.remainingAt(DateTime.now());
    final lockoutSeconds =
        remaining.inSeconds +
        (remaining.inMilliseconds.remainder(1000) == 0 ? 0 : 1);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.lock_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.lockTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.lockPinPrompt(controllers.lock.pinLength),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final progress = _shakeController.value;
                      final offset =
                          math.sin(progress * math.pi * 6) * (1 - progress) * 8;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        _pinDots(
                          strings,
                          _pin.length,
                          controllers.lock.pinLength,
                        ),
                        const SizedBox(height: 20),
                        PinKeypad(
                          keyPrefix: 'lock',
                          deleteLabel: strings.deleteDigit,
                          onDigitPressed: _appendDigit,
                          onDeletePressed: _deleteDigit,
                          enabled:
                              !_attemptingUnlock &&
                              !controllers.lock.isBusy &&
                              remaining <= Duration.zero,
                        ),
                      ],
                    ),
                  ),
                  if (remaining > Duration.zero)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        strings.lockoutCountdown(lockoutSeconds),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  if (controllers.lock.biometricsEnabled) ...<Widget>[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _attemptingUnlock || controllers.lock.isBusy
                          ? null
                          : _unlockWithBiometrics,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: Text(strings.unlockBiometrics),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _attemptingUnlock || controllers.lock.isBusy
                        ? null
                        : _startEraseFlow,
                    child: Text(strings.forgotPin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pinDots(AppLocalizations strings, int filledCount, int pinLength) {
    final theme = Theme.of(context);
    return Semantics(
      label: strings.pinDigitsEntered(filledCount, pinLength),
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(pinLength, (index) {
            final filled = index < filledCount;
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
}
