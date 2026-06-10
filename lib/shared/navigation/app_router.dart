import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_app/shared/navigation/app_pages.dart';
import 'package:crypto_app/feature/home/view/wallet_home_page.dart';
import 'package:crypto_app/feature/transfer/view/recipient_entry_page.dart';
import 'package:crypto_app/feature/transfer/view/amount_entry_page.dart';
import 'package:crypto_app/feature/transfer/view/review_transaction_page.dart';
import 'package:crypto_app/feature/transfer/view/pin_confirmation_page.dart';
import 'package:crypto_app/feature/transfer/view/transaction_result_page.dart';
import 'package:crypto_app/feature/transfer/view/recent_transactions_page.dart';
import 'package:crypto_app/feature/transfer/view/add_contact_page.dart';
import 'package:crypto_app/feature/transfer/view/qr_scanner_page.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';

import 'package:crypto_app/feature/transfer/domain/entities/create_transaction.dart';
import 'package:crypto_app/feature/transfer/domain/entities/transaction.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppPages.walletHome.path,
  routes: [
    // ShellRoute for Bottom Navigation (displays navigation bar only for home features)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainNavigationLayout(child: child);
      },
      routes: [
        GoRoute(
          path: AppPages.walletHome.path,
          name: AppPages.walletHome.name,
          builder: (context, state) => const WalletHomePage(),
        ),
      ],
    ),
    // Recent Transactions Page Route
    GoRoute(
      path: AppPages.recentTransactions.path,
      name: AppPages.recentTransactions.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final txs = state.extra as List<Transaction>? ?? const [];
        return RecentTransactionsPage(transactions: txs);
      },
    ),
    // Transfer Flow routes (Bottom navigation is hidden for these screens)
    GoRoute(
      path: AppPages.recipientEntry.path,
      name: AppPages.recipientEntry.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final createTx = state.extra as CreateTransaction;
        return RecipientEntryPage(createTx: createTx);
      },
    ),
    GoRoute(
      path: AppPages.amountEntry.path,
      name: AppPages.amountEntry.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final createTx = state.extra as CreateTransaction;
        return AmountEntryPage(createTx: createTx);
      },
    ),
    GoRoute(
      path: AppPages.reviewTransaction.path,
      name: AppPages.reviewTransaction.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final createTx = state.extra as CreateTransaction;
        return ReviewTransactionPage(createTx: createTx);
      },
    ),
    GoRoute(
      path: AppPages.pinConfirmation.path,
      name: AppPages.pinConfirmation.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final transaction = state.extra as Transaction;
        return PinConfirmationPage(transaction: transaction);
      },
    ),
    GoRoute(
      path: AppPages.transactionResult.path,
      name: AppPages.transactionResult.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final transaction = state.extra as Transaction;
        return TransactionResultPage(transaction: transaction);
      },
    ),
    GoRoute(
      path: AppPages.addContact.path,
      name: AppPages.addContact.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return const AddContactPage();
      },
    ),
    GoRoute(
      path: AppPages.qrScanner.path,
      name: AppPages.qrScanner.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return const QrScannerPage();
      },
    ),
  ],
);

// Main Navigation Layout scaffolding the bottom navigation bar
class MainNavigationLayout extends StatelessWidget {
  final Widget child;

  const MainNavigationLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        height: 84.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(
                color: Theme.of(context).dividerTheme.color!, width: 1.0),
          ),
        ),
        padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.account_balance_wallet,
              label: 'Wallet',
              isActive: true,
              onTap: () {},
            ),
            _buildNavItem(
              context: context,
              icon: Icons.receipt_long,
              label: 'Activity',
              isActive: false,
              onTap: () => _showComingSoon(context, 'Activity'),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.swap_horiz,
              label: 'Swap',
              isActive: false,
              onTap: () => _showComingSoon(context, 'Swap'),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings,
              label: 'Settings',
              isActive: false,
              onTap: () => _showComingSoon(context, 'Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.0),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontSize: 10.0,
                ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}
