import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transfer_repository.dart';

@lazySingleton
class CompleteTransactionUseCase {
  final TransferRepository _repository;

  CompleteTransactionUseCase(this._repository);

  Future<Either<Failure, Unit>> call(Transaction transaction) async {
    return _repository.completeTransaction(transaction);
  }
}
