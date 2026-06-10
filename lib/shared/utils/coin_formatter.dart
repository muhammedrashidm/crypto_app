class CoinFormatter {
  /// Returns the standard decimal places for a given coin symbol.
  static int getDecimalPlaces(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'USDC':
      case 'USDT':
        return 2;
      case 'SOL':
        return 6;
      case 'ETH':
        return 8;
      default:
        return 4;
    }
  }

  /// Formats a double amount into a string with coin-specific decimal precision.
  static String formatAmount(double amount, String symbol) {
    final decimals = getDecimalPlaces(symbol);
    return amount.toStringAsFixed(decimals);
  }

  /// Parses a string and formats it into a string with coin-specific decimal precision.
  static String formatAmountString(String amountStr, String symbol) {
    final doubleVal = double.tryParse(amountStr) ?? 0.0;
    return formatAmount(doubleVal, symbol);
  }

  /// Returns the estimated network fee for a given coin symbol.
  static String getEstimatedFee(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'USDC':
      case 'USDT':
        return '0.02';
      case 'SOL':
        return '0.000005';
      case 'ETH':
        return '0.0003';
      default:
        return '0.001';
    }
  }
}
