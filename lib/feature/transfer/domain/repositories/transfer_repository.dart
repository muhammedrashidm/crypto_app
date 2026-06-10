import 'package:fpdart/fpdart.dart';
import '../../../../shared/error/failure.dart';
import '../entities/contact.dart';
import '../entities/transaction.dart';

abstract class TransferRepository {
  Future<Either<Failure, List<Contact>>> getRecentRecipients({String? query});
  
  Future<Either<Failure, String>> getMaxCoinAvailable({
    required String coinSymbol,
    required String network,
  });

  Future<Either<Failure, Transaction>> createTransaction({
    required Contact recipient,
    required String amount,
    required String fee,
    required String coinSymbol,
    required String network,
    String? memo,
  });

  Future<Either<Failure, bool>> verifyPin({required String pin});

  Future<Either<Failure, Unit>> completeTransaction(Transaction transaction);

  Future<Either<Failure, List<Transaction>>> getTransactions();

  Future<Either<Failure, Unit>> addContact(Contact contact);
}
