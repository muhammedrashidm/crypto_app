import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_data_source.dart';
import '../models/contact_model.dart';
import '../models/transaction_model.dart';

@LazySingleton(as: TransferRepository)
class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource _remoteDataSource;

  TransferRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Contact>>> getRecentRecipients({String? query}) async {
    try {
      final recipientModels = await _remoteDataSource.getRecentRecipients(query: query);
      final recipients = recipientModels.map((m) => m.toEntity()).toList();
      return Right(recipients);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getMaxCoinAvailable({
    required String coinSymbol,
    required String network,
  }) async {
    try {
      final maxAvailable = await _remoteDataSource.getMaxCoinAvailable(
        coinSymbol: coinSymbol,
        network: network,
      );
      return Right(maxAvailable);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction({
    required Contact recipient,
    required String amount,
    required String fee,
    required String coinSymbol,
    required String network,
    String? memo,
  }) async {
    try {
      final transactionModel = await _remoteDataSource.createTransaction(
        recipient: recipient.toModel(),
        amount: amount,
        fee: fee,
        coinSymbol: coinSymbol,
        network: network,
        memo: memo,
      );
      return Right(transactionModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPin({required String pin}) async {
    try {
      final isValid = await _remoteDataSource.verifyPin(pin: pin);
      return Right(isValid);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeTransaction(Transaction transaction) async {
    try {
      await _remoteDataSource.completeTransaction(transaction.toModel());
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final transactionModels = await _remoteDataSource.getTransactions();
      final transactions = transactionModels.map((m) => m.toEntity()).toList();
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addContact(Contact contact) async {
    try {
      await _remoteDataSource.addContact(contact.toModel());
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
