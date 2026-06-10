import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../repositories/biometric_repository.dart';

@lazySingleton
class UpdateBiometricsPromptDismissedUseCase {
  final BiometricRepository _repository;

  UpdateBiometricsPromptDismissedUseCase(this._repository);

  Future<Either<Failure, Unit>> call(bool dismissed) async {
    return _repository.setPromptDismissed(dismissed);
  }
}
