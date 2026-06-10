import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_app/shared/di/injection.dart';
import 'package:crypto_app/feature/transfer/domain/entities/create_transaction.dart';
import '../bloc/review_transaction_bloc.dart';
import '../bloc/review_transaction_event.dart';
import '../bloc/review_transaction_state.dart';
import 'package:crypto_app/shared/theme/app_colors.dart';
import 'package:crypto_app/shared/theme/app_spacing.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';
import 'package:crypto_app/shared/widgets/bepay_button.dart';
import 'package:crypto_app/shared/widgets/glassmorphic_container.dart';
import 'package:crypto_app/shared/widgets/transaction_row.dart';
import 'package:crypto_app/shared/navigation/app_pages.dart';
import 'package:crypto_app/shared/utils/coin_formatter.dart';

class ReviewTransactionPage extends StatefulWidget {
  final CreateTransaction createTx;

  const ReviewTransactionPage({super.key, required this.createTx});

  @override
  State<ReviewTransactionPage> createState() => _ReviewTransactionPageState();
}

class _ReviewTransactionPageState extends State<ReviewTransactionPage> {
  late final ReviewTransactionBloc _bloc;
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
    _bloc = getIt<ReviewTransactionBloc>()
      ..add(InitReviewTransactionEvent(coinSymbol: widget.createTx.coinSymbol));
  }

  @override
  void dispose() {
    _memoController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final amountStr = widget.createTx.amount ?? '0';
    final amountVal = double.tryParse(amountStr) ?? 0.0;
    
    // Dynamic estimated fee based on coin symbol
    final feeStr = CoinFormatter.getEstimatedFee(widget.createTx.coinSymbol);
    final feeVal = double.tryParse(feeStr) ?? 0.0;
    final totalVal = amountVal + feeVal;

    final recipient = widget.createTx.recipient;
    final recipientName = recipient?.name ?? 'Unknown';
    final recipientAddress = recipient?.bepayId.isNotEmpty == true
        ? recipient!.bepayId
        : recipient?.address ?? '';
    final recipientDisplay = recipientName == recipientAddress
        ? recipientAddress
        : '$recipientName ($recipientAddress)';

    final networkName = widget.createTx.network;
    final isExternal = recipient?.isExternalAddress ?? false;

    return BlocProvider<ReviewTransactionBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              context.pop();
            },
          ),
          title: Text(
            'Review',
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: BlocConsumer<ReviewTransactionBloc, ReviewTransactionState>(
            listener: (context, state) {
              if (state.status == ReviewTransactionStatus.success && state.createdTransaction != null) {
                context.push(AppPages.pinConfirmation.path, extra: state.createdTransaction);
              }
              if (state.status == ReviewTransactionStatus.failure && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: colorScheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isConfirming = state.status == ReviewTransactionStatus.loading;
              final approxFiatValue = amountVal * state.exchangeRate;

              return Stack(
                children: [
                  SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Glassmorphic Summary Header
                          GlassmorphicContainer(
                            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Sending',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      amountStr,
                                      style: textTheme.displayLarge?.copyWith(fontSize: 32.0),
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      widget.createTx.coinSymbol,
                                      style: textTheme.headlineMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6.0),
                                Text(
                                  '≈ ${state.currencySymbol}${approxFiatValue.toStringAsFixed(2)}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // Conditional Warning Card (Only for external addresses)
                          if (isExternal) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: colorScheme.error.withValues(alpha: 0.2),
                                  width: 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: colorScheme.error,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Text(
                                      'Warning: This is an external wallet address. Make sure the recipient address and network are correct. Non-custodial transfers cannot be reversed.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24.0),
                          ],

                          // Summary Sheet details using TransactionRow widget
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                            ),
                            child: Column(
                              children: [
                                TransactionRow(label: 'Recipient', value: recipientDisplay),
                                TransactionRow(label: 'Network', value: networkName),
                                TransactionRow(label: 'Fee', value: '${CoinFormatter.formatAmountString(feeStr, widget.createTx.coinSymbol)} ${widget.createTx.coinSymbol}'),
                                const Divider(height: 20.0),
                                TransactionRow(
                                  label: 'Total',
                                  value: '${CoinFormatter.formatAmount(totalVal, widget.createTx.coinSymbol)} ${widget.createTx.coinSymbol}',
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // Optional Note / Memo Field
                          TextField(
                            controller: _memoController,
                            maxLines: 1,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Memo / Note (Optional)',
                              hintText: 'Add a note for your records',
                              labelStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: const BorderSide(color: AppColors.borderSubtle),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                              ),
                            ),
                            style: textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 32.0),

                          // Confirm button
                          BepayButton(
                            text: 'Confirm',
                            onPressed: isConfirming
                                ? null
                                : () {
                                    _bloc.add(ConfirmReviewEvent(
                                      createTx: widget.createTx.copyWith(
                                        memo: _memoController.text.trim(),
                                      ),
                                    ));
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isConfirming)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
