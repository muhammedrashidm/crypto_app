import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../domain/usecases/get_assets_usecase.dart';
import '../domain/usecases/get_biometrics_settings_usecase.dart';
import '../domain/usecases/update_biometrics_prompt_dismissed_usecase.dart';
import '../domain/usecases/enable_biometrics_usecase.dart';
import 'package:crypto_app/shared/data/repositories/currency_repository.dart';
import '../domain/entities/crypto_asset.dart';
import '../../transfer/domain/usecases/get_recent_transactions_usecase.dart';
import '../../transfer/domain/entities/transaction.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAssetsUseCase _getAssetsUseCase;
  final GetBiometricsSettingsUseCase _getBiometricsSettingsUseCase;
  final UpdateBiometricsPromptDismissedUseCase _updateBiometricsPromptDismissedUseCase;
  final EnableBiometricsUseCase _enableBiometricsUseCase;
  final CurrencyRepository _currencyRepository;
  final GetRecentTransactionsUseCase _getRecentTransactionsUseCase;

  HomeBloc(
    this._getAssetsUseCase,
    this._getBiometricsSettingsUseCase,
    this._updateBiometricsPromptDismissedUseCase,
    this._enableBiometricsUseCase,
    this._currencyRepository,
    this._getRecentTransactionsUseCase,
  ) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<DismissBiometricsPrompt>(_onDismissBiometricsPrompt);
    on<EnableBiometrics>(_onEnableBiometrics);
    on<ChangeCurrency>(_onChangeCurrency);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final assetsResult = await _getAssetsUseCase();
    final settingsResult = await _getBiometricsSettingsUseCase();
    final currency = await _currencyRepository.getSelectedCurrency();
    final symbol = _currencyRepository.getCurrencySymbol(currency);
    final transactionsResult = await _getRecentTransactionsUseCase();

    assetsResult.fold(
      (failure) => emit(HomeError(failure.message)),
      (assets) {
        final updatedAssets = assets.map((asset) {
          final rate = _currencyRepository.getExchangeRate(asset.symbol, currency);
          return CryptoAsset(
            id: asset.id,
            symbol: asset.symbol,
            name: asset.name,
            amount: asset.amount,
            fiatValue: asset.amount * rate,
            network: asset.network,
          );
        }).toList();

        final total = updatedAssets.fold<double>(0.0, (sum, asset) => sum + asset.fiatValue);
        settingsResult.fold(
          (failure) => emit(HomeError(failure.message)),
          (showPrompt) {
            final txList = transactionsResult.fold(
              (failure) => <Transaction>[],
              (list) => list,
            );
            emit(HomeLoaded(
              assets: updatedAssets,
              totalBalance: total,
              showBiometricsPrompt: showPrompt,
              selectedCurrency: currency,
              currencySymbol: symbol,
              transactions: txList,
            ));
          },
        );
      },
    );
  }

  Future<void> _onChangeCurrency(ChangeCurrency event, Emitter<HomeState> emit) async {
    await _currencyRepository.setSelectedCurrency(event.currency);
    add(LoadHomeData());
  }

  Future<void> _onDismissBiometricsPrompt(DismissBiometricsPrompt event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final result = await _updateBiometricsPromptDismissedUseCase(true);
      result.fold(
        (failure) => emit(HomeError(failure.message)),
        (_) => emit(currentState.copyWith(
          showBiometricsPrompt: false,
          biometricsEnabledSuccess: false,
          resetError: true,
        )),
      );
    }
  }

  Future<void> _onEnableBiometrics(EnableBiometrics event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        biometricsEnabledSuccess: false,
        resetError: true,
      )); // Reset state flags on new attempt
      final result = await _enableBiometricsUseCase();
      result.fold(
        (failure) => emit(currentState.copyWith(
          errorMessage: failure.message,
          biometricsEnabledSuccess: false,
        )),
        (success) {
          if (success) {
            emit(currentState.copyWith(
              showBiometricsPrompt: false,
              biometricsEnabledSuccess: true,
              resetError: true,
            ));
          } else {
            emit(currentState.copyWith(
              errorMessage: 'Biometric authentication failed.',
              biometricsEnabledSuccess: false,
            ));
          }
        },
      );
    }
  }
}
