import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

enum ReviewTransactionStatus { initial, loading, success, failure }

class ReviewTransactionState extends Equatable {
  final ReviewTransactionStatus status;
  final Transaction? createdTransaction;
  final String? errorMessage;
  final String selectedCurrency;
  final String currencySymbol;
  final double exchangeRate;

  const ReviewTransactionState({
    this.status = ReviewTransactionStatus.initial,
    this.createdTransaction,
    this.errorMessage,
    this.selectedCurrency = 'USD',
    this.currencySymbol = '\$',
    this.exchangeRate = 1.0,
  });

  ReviewTransactionState copyWith({
    ReviewTransactionStatus? status,
    Transaction? createdTransaction,
    String? errorMessage,
    String? selectedCurrency,
    String? currencySymbol,
    double? exchangeRate,
  }) {
    return ReviewTransactionState(
      status: status ?? this.status,
      createdTransaction: createdTransaction ?? this.createdTransaction,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        createdTransaction,
        errorMessage,
        selectedCurrency,
        currencySymbol,
        exchangeRate,
      ];
}
