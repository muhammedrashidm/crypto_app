import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../utils/coin_formatter.dart';

class TokenCard extends StatelessWidget {
  final String symbol;
  final String name;
  final String amount;
  final String value;
  final String network;
  final VoidCallback? onTap;
  final VoidCallback? onSendTap;

  const TokenCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.amount,
    required this.value,
    required this.network,
    this.onTap,
    this.onSendTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Asset Icon Container
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    symbol,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                // Name and Network
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        network,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Balances
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CoinFormatter.formatAmountString(amount, symbol),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      value,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                if (onSendTap != null) ...[
                  const SizedBox(width: 12.0),
                  SizedBox(
                    width: 36.0,
                    height: 36.0,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, size: 16.0),
                      onPressed: onSendTap,
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
