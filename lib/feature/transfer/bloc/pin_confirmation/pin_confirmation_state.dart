import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

enum PinConfirmationStatus { initial, entering, verifying, success, failure, lockedOut }

class PinConfirmationState extends Equatable {
  final String pin;
  final PinConfirmationStatus status;
  final bool pinError;
  final String? errorMessage;
  final Transaction? transaction;
  final int failedAttempts;
  final int lockoutSecondsRemaining;
  final bool isBiometricsEnabled;

  const PinConfirmationState({
    this.pin = '',
    this.status = PinConfirmationStatus.initial,
    this.pinError = false,
    this.errorMessage,
    this.transaction,
    this.failedAttempts = 0,
    this.lockoutSecondsRemaining = 0,
    this.isBiometricsEnabled = false,
  });

  PinConfirmationState copyWith({
    String? pin,
    PinConfirmationStatus? status,
    bool? pinError,
    String? errorMessage,
    Transaction? transaction,
    int? failedAttempts,
    int? lockoutSecondsRemaining,
    bool? isBiometricsEnabled,
  }) {
    return PinConfirmationState(
      pin: pin ?? this.pin,
      status: status ?? this.status,
      pinError: pinError ?? this.pinError,
      errorMessage: errorMessage ?? this.errorMessage,
      transaction: transaction ?? this.transaction,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutSecondsRemaining: lockoutSecondsRemaining ?? this.lockoutSecondsRemaining,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        pin,
        status,
        pinError,
        errorMessage,
        transaction,
        failedAttempts,
        lockoutSecondsRemaining,
        isBiometricsEnabled,
      ];
}
