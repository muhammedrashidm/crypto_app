import 'package:equatable/equatable.dart';
import '../domain/entities/crypto_asset.dart';
import '../../transfer/domain/entities/transaction.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CryptoAsset> assets;
  final double totalBalance;
  final bool showBiometricsPrompt;
  final String? errorMessage;
  final bool biometricsEnabledSuccess;
  final String selectedCurrency;
  final String currencySymbol;
  final List<Transaction> transactions;

  const HomeLoaded({
    required this.assets,
    required this.totalBalance,
    required this.showBiometricsPrompt,
    this.errorMessage,
    this.biometricsEnabledSuccess = false,
    this.selectedCurrency = 'USD',
    this.currencySymbol = '\$',
    this.transactions = const [],
  });

  HomeLoaded copyWith({
    List<CryptoAsset>? assets,
    double? totalBalance,
    bool? showBiometricsPrompt,
    String? errorMessage,
    bool? biometricsEnabledSuccess,
    String? selectedCurrency,
    String? currencySymbol,
    List<Transaction>? transactions,
    bool resetError = false,
  }) {
    return HomeLoaded(
      assets: assets ?? this.assets,
      totalBalance: totalBalance ?? this.totalBalance,
      showBiometricsPrompt: showBiometricsPrompt ?? this.showBiometricsPrompt,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
      biometricsEnabledSuccess: biometricsEnabledSuccess ?? this.biometricsEnabledSuccess,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [
        assets,
        totalBalance,
        showBiometricsPrompt,
        errorMessage,
        biometricsEnabledSuccess,
        selectedCurrency,
        currencySymbol,
        transactions,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
