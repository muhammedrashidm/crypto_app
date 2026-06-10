import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto_app/shared/utils/coin_formatter.dart';
import '../domain/usecases/get_max_coin_available_usecase.dart';
import 'package:crypto_app/shared/data/repositories/currency_repository.dart';
import 'amount_entry_event.dart';
import 'amount_entry_state.dart';

@injectable
class AmountEntryBloc extends Bloc<AmountEntryEvent, AmountEntryState> {
  final GetMaxCoinAvailableUseCase _getMaxCoinAvailableUseCase;
  final CurrencyRepository _currencyRepository;

  AmountEntryBloc(
    this._getMaxCoinAvailableUseCase,
    this._currencyRepository,
  ) : super(const AmountEntryState()) {
    on<FetchMaxAvailableEvent>(_onFetchMaxAvailable);
    on<UpdateAmountInputEvent>(_onUpdateAmountInput);
    on<BackspaceAmountInputEvent>(_onBackspaceAmountInput);
    on<SetMaxAmountInputEvent>(_onSetMaxAmountInput);
  }

  Future<void> _onFetchMaxAvailable(
    FetchMaxAvailableEvent event,
    Emitter<AmountEntryState> emit,
  ) async {
    emit(state.copyWith(
      status: AmountEntryStatus.loading,
      coinSymbol: event.coinSymbol,
    ));
    final result = await _getMaxCoinAvailableUseCase(
      coinSymbol: event.coinSymbol,
      network: event.network,
    );
    final currency = await _currencyRepository.getSelectedCurrency();
    final symbol = _currencyRepository.getCurrencySymbol(currency);
    final rate = _currencyRepository.getExchangeRate(event.coinSymbol, currency);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AmountEntryStatus.failure,
        errorMessage: failure.message,
        selectedCurrency: currency,
        currencySymbol: symbol,
        exchangeRate: rate,
      )),
      (maxAvailable) => emit(state.copyWith(
        maxCoinAvailable: maxAvailable,
        status: AmountEntryStatus.success,
        selectedCurrency: currency,
        currencySymbol: symbol,
        exchangeRate: rate,
      )),
    );
  }

  void _onUpdateAmountInput(
    UpdateAmountInputEvent event,
    Emitter<AmountEntryState> emit,
  ) {
    String current = state.amountInput;
    if (event.digit == '.') {
      if (current.contains('.')) return;
      if (current.isEmpty) {
        emit(state.copyWith(amountInput: '0.'));
        return;
      }
    }

    final nextAmountStr = current == '0' && event.digit != '.' ? event.digit : (current + event.digit);
    if (nextAmountStr.contains('.')) {
      final parts = nextAmountStr.split('.');
      if (parts.length > 1) {
        final decimals = parts[1];
        final maxDecimals = CoinFormatter.getDecimalPlaces(state.coinSymbol);
        if (decimals.length > maxDecimals) {
          // Block entry!
          return;
        }
      }
    }

    if (current == '0' && event.digit != '.') {
      emit(state.copyWith(amountInput: event.digit));
      return;
    }
    emit(state.copyWith(amountInput: current + event.digit));
  }

  void _onBackspaceAmountInput(
    BackspaceAmountInputEvent event,
    Emitter<AmountEntryState> emit,
  ) {
    String current = state.amountInput;
    if (current.isEmpty) return;
    emit(state.copyWith(amountInput: current.substring(0, current.length - 1)));
  }

  void _onSetMaxAmountInput(
    SetMaxAmountInputEvent event,
    Emitter<AmountEntryState> emit,
  ) {
    // Format the max available amount to match precision requirements when set
    final formattedMax = CoinFormatter.formatAmountString(state.maxCoinAvailable, state.coinSymbol);
    emit(state.copyWith(amountInput: formattedMax));
  }
}
