import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/error/failure.dart';
import '../repositories/biometric_repository.dart';

@lazySingleton
class GetBiometricsSettingsUseCase {
  final BiometricRepository _repository;

  GetBiometricsSettingsUseCase(this._repository);

  Future<Either<Failure, bool>> call() async {
    final enabledResult = await _repository.isBiometricsEnabled();
    return enabledResult.flatMapAsync((isEnabled) async {
      final dismissedResult = await _repository.isPromptDismissed();
      return dismissedResult.map((isDismissed) => !isEnabled && !isDismissed);
    });
  }
}
