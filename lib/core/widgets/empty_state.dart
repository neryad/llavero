import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.add_rounded,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CustomPaint(
                key: const ValueKey('empty-state-illustration'),
                size: const Size(144, 96),
                painter: _KeyIllustrationPainter(
                  primary: theme.colorScheme.primary,
                  accent: theme.colorScheme.secondary,
                  surface: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              Positioned(
                left: 35,
                top: 37,
                child: ExcludeSemantics(
                  child: Icon(icon, size: 22, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const ValueKey('empty-state-action-button'),
              onPressed: onAction,
              icon: Icon(actionIcon),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _KeyIllustrationPainter extends CustomPainter {
  const _KeyIllustrationPainter({
    required this.primary,
    required this.accent,
    required this.surface,
  });

  final Color primary;
  final Color accent;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.32, size.height * 0.5);
    final ringPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    final centerPaint = Paint()..color = surface;
    final shaftPaint = Paint()
      ..color = primary
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final accentPaint = Paint()..color = accent;

    canvas.drawCircle(center, 25, ringPaint);
    canvas.drawCircle(center, 12, centerPaint);
    final shaftStart = Offset(center.dx + 25, center.dy);
    final shaftEnd = Offset(size.width * 0.9, center.dy);
    canvas.drawLine(shaftStart, shaftEnd, shaftPaint);
    canvas.drawLine(
      Offset(size.width * 0.7, center.dy),
      Offset(size.width * 0.7, center.dy + 15),
      shaftPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.19),
      5,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(_KeyIllustrationPainter oldDelegate) {
    return primary != oldDelegate.primary ||
        accent != oldDelegate.accent ||
        surface != oldDelegate.surface;
  }
}
