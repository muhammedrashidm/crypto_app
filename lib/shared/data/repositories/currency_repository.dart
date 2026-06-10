abstract class CurrencyRepository {
  Future<String> getSelectedCurrency();
  Future<void> setSelectedCurrency(String currency);
  double getExchangeRate(String coinSymbol, String currency);
  String getCurrencySymbol(String currency);
}
