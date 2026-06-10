import 'package:injectable/injectable.dart';
import '../../services/shared_pref_service.dart';
import 'currency_repository.dart';

@LazySingleton(as: CurrencyRepository)
class CurrencyRepositoryImpl implements CurrencyRepository {
  final SharedPrefService _sharedPrefService;
  static const String _currencyKey = 'selected_currency';

  CurrencyRepositoryImpl(this._sharedPrefService);

  @override
  Future<String> getSelectedCurrency() async {
    return _sharedPrefService.getString(_currencyKey) ?? 'USD';
  }

  @override
  Future<void> setSelectedCurrency(String currency) async {
    await _sharedPrefService.setString(_currencyKey, currency);
  }

  @override
  double getExchangeRate(String coinSymbol, String currency) {
    final baseUsdPrice = _getBaseUsdPrice(coinSymbol);
    final fiatRate = _getFiatRate(currency);
    return baseUsdPrice * fiatRate;
  }

  @override
  String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'USD':
      default:
        return '\$';
    }
  }

  double _getBaseUsdPrice(String coinSymbol) {
    switch (coinSymbol.toUpperCase()) {
      case 'ETH':
        return 3400.0;
      case 'SOL':
        return 150.0;
      case 'USDC':
      case 'USDT':
      default:
        return 1.0;
    }
  }

  double _getFiatRate(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return 83.5;
      case 'GBP':
        return 0.78;
      case 'EUR':
        return 0.92;
      case 'USD':
      default:
        return 1.0;
    }
  }
}
