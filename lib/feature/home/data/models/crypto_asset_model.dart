import '../../domain/entities/crypto_asset.dart';

class CryptoAssetModel {
  final String id;
  final String symbol;
  final String name;
  final double amount;
  final double fiatValue;
  final String network;

  const CryptoAssetModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.amount,
    required this.fiatValue,
    required this.network,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'name': name,
        'amount': amount,
        'fiatValue': fiatValue,
        'network': network,
      };

  factory CryptoAssetModel.fromJson(Map<String, dynamic> json) => CryptoAssetModel(
        id: json['id'] as String,
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        fiatValue: (json['fiatValue'] as num).toDouble(),
        network: json['network'] as String,
      );
}

extension CryptoAssetModelMapper on CryptoAssetModel {
  CryptoAsset toEntity() => CryptoAsset(
        id: id,
        symbol: symbol,
        name: name,
        amount: amount,
        fiatValue: fiatValue,
        network: network,
      );
}

extension CryptoAssetMapper on CryptoAsset {
  CryptoAssetModel toModel() => CryptoAssetModel(
        id: id,
        symbol: symbol,
        name: name,
        amount: amount,
        fiatValue: fiatValue,
        network: network,
      );
}
