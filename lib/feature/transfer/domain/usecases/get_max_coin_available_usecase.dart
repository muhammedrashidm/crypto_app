import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../repositories/transfer_repository.dart';

@lazySingleton
class GetMaxCoinAvailableUseCase {
  final TransferRepository _repository;

  GetMaxCoinAvailableUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String coinSymbol,
    required String network,
  }) async {
    return _repository.getMaxCoinAvailable(
      coinSymbol: coinSymbol,
      network: network,
    );
  }
}
