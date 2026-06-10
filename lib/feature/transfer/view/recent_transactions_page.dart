import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/transaction.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';

class RecentTransactionsPage extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentTransactionsPage({
    super.key,
    required this.transactions,
  });

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day;
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final sortedTxs = List<Transaction>.from(transactions);
    sortedTxs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Transaction History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: sortedTxs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppColors.onBackground,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transaction history',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your completed transfers will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onBackground.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: 16.0,
              ),
              itemCount: sortedTxs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = sortedTxs[index];
                final Color iconBg;
                final Color iconColor;
                final IconData iconData;
                switch (tx.status) {
                  case TransactionStatus.success:
                    iconBg = AppColors.success.withValues(alpha: 0.1);
                    iconColor = AppColors.success;
                    iconData = Icons.call_made;
                    break;
                  case TransactionStatus.pending:
                    iconBg = AppColors.warning.withValues(alpha: 0.1);
                    iconColor = AppColors.warning;
                    iconData = Icons.access_time;
                    break;
                  case TransactionStatus.failed:
                    iconBg = AppColors.error.withValues(alpha: 0.1);
                    iconColor = AppColors.error;
                    iconData = Icons.close;
                    break;
                }

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.gutterMd),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.recipientName,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.onBackground,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${tx.networkName} • ${tx.status.displayName}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: tx.status == TransactionStatus.failed
                                        ? AppColors.error
                                        : tx.status == TransactionStatus.pending
                                            ? AppColors.warning
                                            : AppColors.onBackground.withValues(alpha: 0.5),
                                    fontWeight: tx.status != TransactionStatus.success ? FontWeight.bold : FontWeight.normal,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '-${tx.amount} ${tx.coinSymbol}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onBackground,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(tx.timestamp),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.onBackground.withValues(alpha: 0.5),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
