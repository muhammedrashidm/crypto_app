import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_app/shared/di/injection.dart';
import 'package:crypto_app/feature/transfer/domain/entities/create_transaction.dart';
import '../bloc/amount_entry_bloc.dart';
import '../bloc/amount_entry_event.dart';
import '../bloc/amount_entry_state.dart';
import 'package:crypto_app/shared/theme/app_colors.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';
import 'package:crypto_app/shared/theme/app_spacing.dart';
import 'package:crypto_app/shared/widgets/bepay_button.dart';
import 'package:crypto_app/shared/widgets/bepay_secondary_button.dart';
import 'package:crypto_app/shared/widgets/bepay_keypad.dart';
import 'package:crypto_app/shared/navigation/app_pages.dart';
import 'package:crypto_app/shared/utils/coin_formatter.dart';

class AmountEntryPage extends StatefulWidget {
  final CreateTransaction createTx;

  const AmountEntryPage({super.key, required this.createTx});

  @override
  State<AmountEntryPage> createState() => _AmountEntryPageState();
}

class _AmountEntryPageState extends State<AmountEntryPage> {
  late final AmountEntryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<AmountEntryBloc>()
      ..add(FetchMaxAvailableEvent(
        coinSymbol: widget.createTx.coinSymbol,
        network: widget.createTx.network,
      ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider<AmountEntryBloc>.value(
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
            'Send ${widget.createTx.coinSymbol}',
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: BlocBuilder<AmountEntryBloc, AmountEntryState>(
            builder: (context, state) {
              if (state.status == AmountEntryStatus.loading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                );
              }

              final displayAmountInput = state.amountInput.isEmpty ? '0' : state.amountInput;
              final approxFiatValue = state.approxFiatValue;
              final isAmountValid = state.isAmountValid;

              return CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: 16.0,
                      ),
                      child: Column(
                        children: [
                          // Subtitle / Network
                          Text(
                            'on ${widget.createTx.network}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const Spacer(),

                          // Large Amount Display
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    displayAmountInput,
                                    style: textTheme.displayLarge,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    widget.createTx.coinSymbol,
                                    style: textTheme.headlineLarge?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                '≈ ${state.currencySymbol}${approxFiatValue.toStringAsFixed(2)}',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              if (state.validationError != null) ...[
                                const SizedBox(height: 8.0),
                                Text(
                                  state.validationError!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const Spacer(),

                          // Available Balance indicator
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                _bloc.add(const SetMaxAmountInputEvent());
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                                ),
                                child: Text(
                                  'Available: ${CoinFormatter.formatAmountString(state.maxCoinAvailable, widget.createTx.coinSymbol)} ${widget.createTx.coinSymbol}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // Reusable keypad
                          BepayKeypad(
                            onDigitTap: (digit) {
                              _bloc.add(UpdateAmountInputEvent(digit));
                            },
                            onBackspaceTap: () {
                              _bloc.add(const BackspaceAmountInputEvent());
                            },
                          ),
                          const SizedBox(height: 24.0),

                          // Max button
                          BepaySecondaryButton(
                            text: 'Max',
                            onPressed: () {
                              _bloc.add(const SetMaxAmountInputEvent());
                            },
                          ),
                          const SizedBox(height: 12.0),

                          // Continue button
                          BepayButton(
                            text: 'Continue',
                            onPressed: isAmountValid
                                ? () {
                                    final updatedTx = widget.createTx.copyWith(
                                      amount: state.amountInput,
                                    );
                                    context.push(AppPages.reviewTransaction.path, extra: updatedTx);
                                  }
                                : null,
                          ),
                        ],
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
