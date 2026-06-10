import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../entities/crypto_asset.dart';
import '../repositories/home_repository.dart';

@lazySingleton
class GetAssetsUseCase {
  final HomeRepository _repository;

  GetAssetsUseCase(this._repository);

  Future<Either<Failure, List<CryptoAsset>>> call() async {
    return _repository.getAssets();
  }
}
