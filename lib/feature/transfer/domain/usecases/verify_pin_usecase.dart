import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../repositories/transfer_repository.dart';

@lazySingleton
class VerifyPinUseCase {
  final TransferRepository _repository;

  VerifyPinUseCase(this._repository);

  Future<Either<Failure, bool>> call({required String pin}) async {
    return _repository.verifyPin(pin: pin);
  }
}
