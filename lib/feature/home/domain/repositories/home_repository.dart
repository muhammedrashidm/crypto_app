import 'package:fpdart/fpdart.dart';
import '../../../../shared/error/failure.dart';
import '../entities/crypto_asset.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<CryptoAsset>>> getAssets();
}
