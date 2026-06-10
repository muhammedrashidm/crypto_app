import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../entities/contact.dart';
import '../repositories/transfer_repository.dart';

@lazySingleton
class AddContactUseCase {
  final TransferRepository _repository;

  AddContactUseCase(this._repository);

  Future<Either<Failure, Unit>> call(Contact contact) async {
    return _repository.addContact(contact);
  }
}
