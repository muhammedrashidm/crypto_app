import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../entities/contact.dart';
import '../repositories/transfer_repository.dart';

@lazySingleton
class GetRecentRecipientsUseCase {
  final TransferRepository _repository;

  GetRecentRecipientsUseCase(this._repository);

  Future<Either<Failure, List<Contact>>> call({String? query}) async {
    return _repository.getRecentRecipients(query: query);
  }
}
