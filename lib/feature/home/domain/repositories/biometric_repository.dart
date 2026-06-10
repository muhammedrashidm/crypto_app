import 'package:fpdart/fpdart.dart';
import '../../../../shared/error/failure.dart';

abstract class BiometricRepository {
  Future<Either<Failure, bool>> isBiometricsEnabled();
  Future<Either<Failure, Unit>> setBiometricsEnabled(bool enabled);
  Future<Either<Failure, bool>> isPromptDismissed();
  Future<Either<Failure, Unit>> setPromptDismissed(bool dismissed);
  Future<Either<Failure, bool>> authenticate({String? reason});
}
