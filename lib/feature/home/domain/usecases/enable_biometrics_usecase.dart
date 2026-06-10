import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../repositories/biometric_repository.dart';

@lazySingleton
class EnableBiometricsUseCase {
  final BiometricRepository _repository;

  EnableBiometricsUseCase(this._repository);

  Future<Either<Failure, bool>> call() async {
    final authResult = await _repository.authenticate();
    return authResult.flatMapAsync((success) async {
      if (success) {
        final setEnabledResult = await _repository.setBiometricsEnabled(true);
        return setEnabledResult.map((_) => true);
      }
      return const Right(false);
    });
  }
}
