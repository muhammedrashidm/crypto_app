import 'package:equatable/equatable.dart';
import 'package:crypto_app/shared/utils/coin_formatter.dart';

enum AmountEntryStatus { initial, loading, success, failure }

class AmountEntryState extends Equatable {
  final String maxCoinAvailable;
  final String amountInput;
  final AmountEntryStatus status;
  final String? errorMessage;
  final String coinSymbol;
  final String selectedCurrency;
  final String currencySymbol;
  final double exchangeRate;

  const AmountEntryState({
    this.maxCoinAvailable = '0.0',
    this.amountInput = '',
    this.status = AmountEntryStatus.initial,
    this.errorMessage,
    this.coinSymbol = '',
    this.selectedCurrency = 'USD',
    this.currencySymbol = '\$',
    this.exchangeRate = 1.0,
  });

  double get amount => double.tryParse(amountInput) ?? 0.0;
  double get maxAmount => double.tryParse(maxCoinAvailable) ?? 0.0;
  bool get isAmountValid => amount > 0.0 && amount <= maxAmount;
  double get approxFiatValue => amount * exchangeRate;

  String? get validationError {
    final clean = amountInput.trim();
    if (clean.isEmpty) return null;

    final amt = amount;
    
    if (amt > maxAmount) {
      return 'Amount exceeds available balance';
    }
    
    if (amt <= 0.0) {
      final parts = clean.split('.');
      if (parts.length > 1) {
        final decimals = parts[1];
        final maxDecimals = CoinFormatter.getDecimalPlaces(coinSymbol);
        if (decimals.length >= maxDecimals) {
          return 'Amount must be greater than zero';
        }
      } else if (clean == '0') {
        return null;
      }
    }
    
    return null;
  }

  AmountEntryState copyWith({
    String? maxCoinAvailable,
    String? amountInput,
    AmountEntryStatus? status,
    String? errorMessage,
    String? coinSymbol,
    String? selectedCurrency,
    String? currencySymbol,
    double? exchangeRate,
  }) {
    return AmountEntryState(
      maxCoinAvailable: maxCoinAvailable ?? this.maxCoinAvailable,
      amountInput: amountInput ?? this.amountInput,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      coinSymbol: coinSymbol ?? this.coinSymbol,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }

  @override
  List<Object?> get props => [
        maxCoinAvailable,
        amountInput,
        status,
        errorMessage,
        coinSymbol,
        selectedCurrency,
        currencySymbol,
        exchangeRate,
      ];
}
