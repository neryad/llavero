import 'package:flutter/material.dart';

import '../theme/category_colors.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.title,
    required this.categoryId,
    required this.categoryLabel,
    required this.person,
    required this.isFavorite,
    required this.favoriteTooltip,
    required this.removeFavoriteTooltip,
    required this.onTap,
    this.onFavoriteTap,
  });

  final String title;
  final String categoryId;
  final String categoryLabel;
  final String? person;
  final bool isFavorite;
  final String favoriteTooltip;
  final String removeFavoriteTooltip;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;

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
    final icon = switch (categoryId) {
      'wifi' => Icons.wifi_rounded,
      'email' => Icons.mail_outline_rounded,
      'streaming' => Icons.play_circle_outline_rounded,
      'banking' => Icons.credit_card_rounded,
      'pin' => Icons.dialpad_rounded,
      'social' => Icons.apps_rounded,
      'devices' => Icons.devices_other_rounded,
      'documents' => Icons.badge_outlined,
      _ => Icons.key_rounded,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.16),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        categoryLabel,
                        if (person?.isNotEmpty ?? false) person!,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onFavoriteTap != null)
                IconButton(
                  tooltip: isFavorite ? removeFavoriteTooltip : favoriteTooltip,
                  onPressed: onFavoriteTap,
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFavorite ? theme.colorScheme.secondary : null,
                  ),
                ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
