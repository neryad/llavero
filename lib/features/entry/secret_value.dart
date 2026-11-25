import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';

class SecretValue extends StatefulWidget {
  const SecretValue({
    super.key,
    required this.value,
    required this.isSecret,
    required this.index,
  });

  final String value;
  final bool isSecret;
  final int index;

  @override
  State<SecretValue> createState() => _SecretValueState();
}

class _SecretValueState extends State<SecretValue> {
  Timer? _hideTimer;
  bool _isRevealed = false;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!widget.isSecret) {
      return SelectableText(widget.value, style: theme.textTheme.bodyLarge);
    }
    final strings = AppLocalizations.of(context);
    final typography = theme.extension<AppTypography>()!;
    return Row(
      children: [
        Expanded(
          child: SelectableText(
            _isRevealed ? widget.value : '••••••',
            key: ValueKey(
              _isRevealed
                  ? 'secret-value-${widget.index}'
                  : 'secret-mask-${widget.index}',
            ),
            style: typography.secret,
          ),
        ),
        IconButton(
          key: ValueKey('reveal-secret-${widget.index}'),
          tooltip: _isRevealed ? strings.hide : strings.reveal,
          onPressed: _toggleVisibility,
          icon: Icon(
            _isRevealed
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ],
    );
  }

  void _toggleVisibility() {
    _hideTimer?.cancel();
    setState(() => _isRevealed = !_isRevealed);
    if (_isRevealed) {
      _hideTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() => _isRevealed = false);
        }
      });
    }
  }
}
