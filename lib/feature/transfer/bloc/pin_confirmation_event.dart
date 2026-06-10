import 'package:equatable/equatable.dart';
import '../domain/entities/transaction.dart';

abstract class PinConfirmationEvent extends Equatable {
  const PinConfirmationEvent();

  @override
  List<Object?> get props => [];
}

class InitPinConfirmationEvent extends PinConfirmationEvent {
  final Transaction transaction;

  const InitPinConfirmationEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class EnterPinDigitEvent extends PinConfirmationEvent {
  final String digit;

  const EnterPinDigitEvent(this.digit);

  @override
  List<Object?> get props => [digit];
}

class DeletePinDigitEvent extends PinConfirmationEvent {}

class LockoutTimerTickedEvent extends PinConfirmationEvent {
  final int secondsRemaining;

  const LockoutTimerTickedEvent(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}

class AuthenticateWithBiometricsEvent extends PinConfirmationEvent {
  const AuthenticateWithBiometricsEvent();
}
