import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto_app/shared/utils/coin_formatter.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import 'package:crypto_app/shared/data/repositories/currency_repository.dart';
import 'review_transaction_event.dart';
import 'review_transaction_state.dart';

@injectable
class ReviewTransactionBloc extends Bloc<ReviewTransactionEvent, ReviewTransactionState> {
  final CreateTransactionUseCase _createTransactionUseCase;
  final CurrencyRepository _currencyRepository;

  ReviewTransactionBloc(
    this._createTransactionUseCase,
    this._currencyRepository,
  ) : super(const ReviewTransactionState()) {
    on<ConfirmReviewEvent>(_onConfirmReview);
    on<InitReviewTransactionEvent>(_onInitReviewTransaction);
  }

  Future<void> _onInitReviewTransaction(
    InitReviewTransactionEvent event,
    Emitter<ReviewTransactionState> emit,
  ) async {
    final currency = await _currencyRepository.getSelectedCurrency();
    final symbol = _currencyRepository.getCurrencySymbol(currency);
    final rate = _currencyRepository.getExchangeRate(event.coinSymbol, currency);
    emit(state.copyWith(
      selectedCurrency: currency,
      currencySymbol: symbol,
      exchangeRate: rate,
    ));
  }

  Future<void> _onConfirmReview(
    ConfirmReviewEvent event,
    Emitter<ReviewTransactionState> emit,
  ) async {
    final recipient = event.createTx.recipient;
    final amount = event.createTx.amount;
    if (recipient == null || amount == null) {
      emit(state.copyWith(
        status: ReviewTransactionStatus.failure,
        errorMessage: 'Invalid recipient or amount',
      ));
      return;
    }

    emit(state.copyWith(status: ReviewTransactionStatus.loading));

    final fee = CoinFormatter.getEstimatedFee(event.createTx.coinSymbol);

    final result = await _createTransactionUseCase(
      recipient: recipient,
      amount: amount,
      fee: fee,
      coinSymbol: event.createTx.coinSymbol,
      network: event.createTx.network,
      memo: event.createTx.memo,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ReviewTransactionStatus.failure,
        errorMessage: failure.message,
      )),
      (transaction) => emit(state.copyWith(
        createdTransaction: transaction,
        status: ReviewTransactionStatus.success,
      )),
    );
  }
}
