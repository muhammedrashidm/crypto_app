import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/crypto_asset.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/crypto_asset_model.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<CryptoAsset>>> getAssets() async {
    try {
      final assetModels = await _remoteDataSource.getAssets();
      final assets = assetModels.map((m) => m.toEntity()).toList();
      return Right(assets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
