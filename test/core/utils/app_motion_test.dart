import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/utils/app_motion.dart';

void main() {
  testWidgets('uses no animation duration when reduce motion is enabled', (
    WidgetTester tester,
  ) async {
    Duration? actualDuration;
    const preferredDuration = Duration(milliseconds: 280);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              actualDuration = AppMotion.duration(context, preferredDuration);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(actualDuration, Duration.zero);
  });

  testWidgets('keeps the requested duration when reduce motion is disabled', (
    WidgetTester tester,
  ) async {
    Duration? actualDuration;
    const preferredDuration = Duration(milliseconds: 280);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: false),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              actualDuration = AppMotion.duration(context, preferredDuration);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(actualDuration, preferredDuration);
  });
}
