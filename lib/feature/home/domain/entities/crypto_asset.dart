import 'package:equatable/equatable.dart';

class CryptoAsset extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final double amount;
  final double fiatValue;
  final String network;

  const CryptoAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.amount,
    required this.fiatValue,
    required this.network,
  });

  @override
  List<Object?> get props => [id, symbol, name, amount, fiatValue, network];
}
