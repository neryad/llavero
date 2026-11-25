import 'package:flutter/material.dart';

import '../theme/category_colors.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.categoryId,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String categoryId;
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<CategoryColors>()!;
    final color = switch (categoryId) {
      'wifi' => colors.wifi,
      'email' => colors.email,
      'streaming' => colors.streaming,
      'banking' => colors.banking,
      'pin' => colors.pinCode,
      'social' => colors.social,
      'devices' => colors.devices,
      'documents' => colors.documents,
      _ => colors.other,
    };

    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      avatar: selected ? null : CircleAvatar(backgroundColor: color, radius: 5),
      selectedColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: selected ? color : theme.colorScheme.outline),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
