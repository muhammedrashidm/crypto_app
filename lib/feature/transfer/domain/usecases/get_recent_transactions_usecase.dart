import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transfer_repository.dart';

@lazySingleton
class GetRecentTransactionsUseCase {
  final TransferRepository _repository;

  GetRecentTransactionsUseCase(this._repository);

  Future<Either<Failure, List<Transaction>>> call() async {
    final result = await _repository.getTransactions();
    return result.map((list) {
      final sorted = List<Transaction>.from(list);
      sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted;
    });
  }
}
