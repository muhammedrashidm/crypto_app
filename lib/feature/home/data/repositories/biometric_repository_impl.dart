import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto_app/shared/services/shared_pref_service.dart';
import 'package:crypto_app/shared/error/failure.dart';
import 'package:crypto_app/feature/home/domain/repositories/biometric_repository.dart';

@LazySingleton(as: BiometricRepository)
class BiometricRepositoryImpl implements BiometricRepository {
  final SharedPrefService _sharedPrefService;
  final LocalAuthentication _localAuth;

  static const String _keyBiometricsEnabled = 'biometrics_enabled';
  static const String _keyPromptDismissed = 'biometrics_prompt_dismissed';

  BiometricRepositoryImpl(this._sharedPrefService)
      : _localAuth = LocalAuthentication();

  @override
  Future<Either<Failure, bool>> isBiometricsEnabled() async {
    try {
      final value = _sharedPrefService.getBool(_keyBiometricsEnabled);
      return Right(value);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setBiometricsEnabled(bool enabled) async {
    try {
      await _sharedPrefService.setBool(_keyBiometricsEnabled, enabled);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isPromptDismissed() async {
    try {
      final value = _sharedPrefService.getBool(_keyPromptDismissed);
      return Right(value);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setPromptDismissed(bool dismissed) async {
    try {
      await _sharedPrefService.setBool(_keyPromptDismissed, dismissed);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticate({String? reason}) async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        return const Right(false);
      }

      final success = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to enable biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return Right(success);
    } catch (e) {
      return Left(BiometricFailure(e.toString()));
    }
  }
}
