import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_app/feature/transfer/domain/entities/transaction.dart';
import 'package:crypto_app/feature/home/bloc/home_bloc.dart';
import 'package:crypto_app/feature/home/bloc/home_event.dart';
import 'package:crypto_app/shared/theme/app_colors.dart';
import 'package:crypto_app/shared/theme/app_spacing.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';
import 'package:crypto_app/shared/widgets/bepay_button.dart';
import 'package:crypto_app/shared/widgets/bepay_secondary_button.dart';
import 'package:crypto_app/shared/widgets/transaction_row.dart';
import 'package:crypto_app/shared/navigation/app_pages.dart';

class TransactionResultPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionResultPage({super.key, required this.transaction});

  void _showDetailsBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        final totalDeductionLabel = transaction.status == TransactionStatus.failed
            ? 'No deduction (Failed)'
            : '${transaction.total} ${transaction.coinSymbol}';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Transaction Details',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TransactionRow(
                          label: 'Status',
                          value: transaction.status.displayName,
                        ),
                        TransactionRow(
                          label: 'Recipient',
                          value: transaction.recipientName == transaction.recipientAddress
                              ? transaction.recipientAddress
                              : '${transaction.recipientName} (${transaction.recipientAddress})',
                        ),
                        TransactionRow(
                          label: 'Network',
                          value: transaction.networkName,
                        ),
                        TransactionRow(
                          label: 'Amount',
                          value: '${transaction.amount} ${transaction.coinSymbol}',
                        ),
                        TransactionRow(
                          label: 'Network Fee',
                          value: '${transaction.fee} ${transaction.coinSymbol}',
                        ),
                        if (transaction.memo != null && transaction.memo!.isNotEmpty)
                          TransactionRow(
                            label: 'Memo / Note',
                            value: transaction.memo!,
                          ),
                        const Divider(height: 20.0),
                        TransactionRow(
                          label: 'Total Deduction',
                          value: totalDeductionLabel,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Expanded(
                  child: BepayButton(
                    text: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Status-dependent properties
    final Color statusColor;
    final IconData statusIcon;
    final String statusTitle;
    final String statusSubtitle;
    final String actionWord;

    switch (transaction.status) {
      case TransactionStatus.success:
        statusColor = AppColors.success;
        statusIcon = Icons.check;
        statusTitle = 'Transaction Successful';
        statusSubtitle = 'The funds are on their way';
        actionWord = 'sent to';
        break;
      case TransactionStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time;
        statusTitle = 'Transaction Pending';
        statusSubtitle = 'This transaction is being processed';
        actionWord = 'sending to';
        break;
      case TransactionStatus.failed:
        statusColor = AppColors.error;
        statusIcon = Icons.close;
        statusTitle = 'Transaction Failed';
        statusSubtitle = 'Something went wrong during submission';
        actionWord = 'failed sending to';
        break;
    }

    final recipientDisplay = transaction.recipientName == transaction.recipientAddress
        ? transaction.recipientAddress
        : transaction.recipientName;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: 16.0,
          ),
          child: Column(
            children: [
              const Spacer(),
              // Brand
              Text(
                'bepay',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),

              // Circular Status Icon
              Container(
                width: 96.0,
                height: 96.0,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 2.0,
                  ),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 48.0,
                ),
              ),
              const SizedBox(height: 32.0),

              // Title and Subtitle
              Text(
                statusTitle,
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                statusSubtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // Transaction Summary Description Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                child: Column(
                  children: [
                    Text(
                      '${transaction.amount} ${transaction.coinSymbol} $actionWord $recipientDisplay',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Network:',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          transaction.networkName,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction ID:',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Flexible(
                          child: Text(
                            transaction.transactionId,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Spacer(),

              // View Details action
              BepaySecondaryButton(
                text: 'View Details',
                onPressed: () => _showDetailsBottomSheet(context),
              ),
              const SizedBox(height: 12.0),

              // Back to Home action
              BepayButton(
                text: 'Back to Home',
                onPressed: () {
                  context.read<HomeBloc>().add(LoadHomeData());
                  context.go(AppPages.walletHome.path);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
