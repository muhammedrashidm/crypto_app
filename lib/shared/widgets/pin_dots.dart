import 'package:flutter/material.dart';
class PinDots extends StatelessWidget {
  final int length;
  final int maxLength;
  final bool hasError;

  const PinDots({
    super.key,
    required this.length,
    this.maxLength = 4,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final isFilled = index < length;
        return Container(
          width: 16.0,
          height: 16.0,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? colorScheme.error
                : (isFilled ? colorScheme.primary : Colors.transparent),
            border: Border.all(
              color: hasError
                  ? colorScheme.error
                  : (isFilled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.3)),
              width: 2.0,
            ),
          ),
        );
      }),
    );
  }
}
