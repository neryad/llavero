import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_typography.dart';

/// A large, accessible numeric keypad shared by PIN creation and unlock.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.keyPrefix,
    required this.deleteLabel,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.enabled = true,
  });

  final String keyPrefix;
  final String deleteLabel;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const rows = <List<String?>>[
      <String?>['1', '2', '3'],
      <String?>['4', '5', '6'],
      <String?>['7', '8', '9'],
      <String?>[null, '0', null],
    ];

    return Column(
      children: <Widget>[
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...<Widget>[
          if (rowIndex > 0) const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (
                var columnIndex = 0;
                columnIndex < rows[rowIndex].length;
                columnIndex++
              ) ...<Widget>[
                if (columnIndex > 0) const SizedBox(width: 8),
                Expanded(
                  child: _buildKey(
                    context,
                    digit: rows[rowIndex][columnIndex],
                    rowIndex: rowIndex,
                    columnIndex: columnIndex,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildKey(
    BuildContext context, {
    required String? digit,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (digit != null) {
      final theme = Theme.of(context);
      return SizedBox(
        height: 56,
        child: TextButton(
          key: ValueKey<String>('$keyPrefix-digit-$digit'),
          onPressed: enabled
              ? () {
                  unawaited(HapticFeedback.selectionClick());
                  onDigitPressed(digit);
                }
              : null,
          child: Text(
            digit,
            style:
                theme.extension<AppTypography>()?.secret ??
                theme.textTheme.titleLarge,
          ),
        ),
      );
    }

    if (rowIndex == 3 && columnIndex == 0) {
      return SizedBox(
        height: 56,
        child: Semantics(
          button: true,
          label: deleteLabel,
          child: IconButton(
            key: ValueKey<String>('$keyPrefix-delete'),
            onPressed: enabled
                ? () {
                    unawaited(HapticFeedback.selectionClick());
                    onDeletePressed();
                  }
                : null,
            icon: const Icon(Icons.backspace_outlined),
          ),
        ),
      );
    }

    return const SizedBox(height: 56);
  }
}
