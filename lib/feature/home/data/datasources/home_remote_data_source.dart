import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../shared/services/shared_pref_service.dart';
import '../models/crypto_asset_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CryptoAssetModel>> getAssets();
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SharedPrefService _sharedPrefService;

  HomeRemoteDataSourceImpl(this._sharedPrefService);

  @override
  Future<List<CryptoAssetModel>> getAssets() async {
    // Simulate remote network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final assetsJson = _sharedPrefService.getString('crypto_assets');
    if (assetsJson == null) {
      const seedList = [
        CryptoAssetModel(
          id: 'eth_network_eth',
          symbol: 'ETH',
          name: 'Ethereum',
          amount: 0.42,
          fiatValue: 1428.00,
          network: 'Ethereum Network',
        ),
        CryptoAssetModel(
          id: 'polygon_usdc',
          symbol: 'USDC',
          name: 'USD Coin',
          amount: 250.50,
          fiatValue: 250.50,
          network: 'Polygon',
        ),
        CryptoAssetModel(
          id: 'solana_sol',
          symbol: 'SOL',
          name: 'Solana',
          amount: 3.25,
          fiatValue: 487.50,
          network: 'Solana',
        ),
        CryptoAssetModel(
          id: 'tron_usdt',
          symbol: 'USDT',
          name: 'Tether',
          amount: 120.00,
          fiatValue: 120.00,
          network: 'Tron',
        ),
      ];

      final jsonString = jsonEncode(seedList.map((e) => e.toJson()).toList());
      await _sharedPrefService.setString('crypto_assets', jsonString);
      return seedList;
    } else {
      final List<dynamic> decoded = jsonDecode(assetsJson);
      return decoded.map((e) => CryptoAssetModel.fromJson(e as Map<String, dynamic>)).toList();
    }
  }
}
