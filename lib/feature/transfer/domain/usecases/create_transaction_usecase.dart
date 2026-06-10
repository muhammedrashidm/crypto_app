import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../entities/contact.dart';
import '../entities/transaction.dart';
import '../repositories/transfer_repository.dart';

@lazySingleton
class CreateTransactionUseCase {
  final TransferRepository _repository;

  CreateTransactionUseCase(this._repository);

  Future<Either<Failure, Transaction>> call({
    required Contact recipient,
    required String amount,
    required String fee,
    required String coinSymbol,
    required String network,
    String? memo,
  }) async {
    return _repository.createTransaction(
      recipient: recipient,
      amount: amount,
      fee: fee,
      coinSymbol: coinSymbol,
      network: network,
      memo: memo,
    );
  }
}
