import 'package:crypto_app/feature/home/domain/usecases/get_assets_usecase.dart';
import 'package:crypto_app/feature/home/domain/entities/crypto_asset.dart';
import 'package:crypto_app/feature/home/domain/repositories/home_repository.dart';
import 'package:crypto_app/shared/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class MockHomeRepository implements HomeRepository {
  final Either<Failure, List<CryptoAsset>> result;
  MockHomeRepository(this.result);

  @override
  Future<Either<Failure, List<CryptoAsset>>> getAssets() async {
    return result;
  }
}

void main() {
  group('GetAssetsUseCase Unit Tests', () {
    test('should return Right with list of assets on success', () async {
      const mockAssets = [
        CryptoAsset(
          id: 'eth_network_eth',
          symbol: 'ETH',
          name: 'Ethereum',
          amount: 0.42,
          fiatValue: 1428.00,
          network: 'Ethereum Network',
        ),
      ];

      final repository = MockHomeRepository(const Right(mockAssets));
      final useCase = GetAssetsUseCase(repository);

      final result = await useCase();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (assets) {
          expect(assets, mockAssets);
          expect(assets.first.symbol, 'ETH');
        },
      );
    });

    test('should return Left with ServerFailure on error', () async {
      final repository = MockHomeRepository(const Left(ServerFailure('Connection error')));
      final useCase = GetAssetsUseCase(repository);

      final result = await useCase();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Connection error');
        },
        (assets) => fail('Should not succeed'),
      );
    });
  });
}
