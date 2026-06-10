import 'dart:async';
import 'package:fpdart/fpdart.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class BiometricFailure extends Failure {
  const BiometricFailure(super.message);
}

extension EitherAsyncExtension<L, R> on Either<L, R> {
  Future<Either<L, R2>> flatMapAsync<R2>(
    FutureOr<Either<L, R2>> Function(R right) f,
  ) async {
    return fold(
      (left) => Future.value(Left(left)),
      (right) async => f(right),
    );
  }
}

extension FutureEitherAsyncExtension<L, R> on Future<Either<L, R>> {
  Future<Either<L, R2>> flatMapAsync<R2>(
    FutureOr<Either<L, R2>> Function(R right) f,
  ) async {
    final either = await this;
    return either.flatMapAsync(f);
  }

  Future<Either<L, R2>> mapAsync<R2>(
    FutureOr<R2> Function(R right) f,
  ) async {
    final either = await this;
    return either.fold(
      (left) => Left(left),
      (right) async => Right(await f(right)),
    );
  }
}
