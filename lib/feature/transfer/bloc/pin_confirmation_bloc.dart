import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto_app/shared/services/shared_pref_service.dart';
import 'package:crypto_app/feature/home/domain/repositories/biometric_repository.dart';
import '../domain/usecases/verify_pin_usecase.dart';
import '../domain/usecases/complete_transaction_usecase.dart';
import 'pin_confirmation_event.dart';
import 'pin_confirmation_state.dart';

@injectable
class PinConfirmationBloc extends Bloc<PinConfirmationEvent, PinConfirmationState> {
  final VerifyPinUseCase _verifyPinUseCase;
  final CompleteTransactionUseCase _completeTransactionUseCase;
  final SharedPrefService _sharedPrefService;
  final BiometricRepository _biometricRepository;
  Timer? _lockoutTimer;

  PinConfirmationBloc(
    this._verifyPinUseCase,
    this._completeTransactionUseCase,
    this._sharedPrefService,
    this._biometricRepository,
  ) : super(const PinConfirmationState()) {
    on<InitPinConfirmationEvent>(_onInit);
    on<EnterPinDigitEvent>(_onEnterPinDigit);
    on<DeletePinDigitEvent>(_onDeletePinDigit);
    on<LockoutTimerTickedEvent>(_onLockoutTimerTicked);
    on<AuthenticateWithBiometricsEvent>(_onAuthenticateWithBiometrics);
  }

  Future<void> _onInit(
    InitPinConfirmationEvent event,
    Emitter<PinConfirmationState> emit,
  ) async {
    emit(state.copyWith(transaction: event.transaction));

    final lockoutUntil = _sharedPrefService.getInt('pin_lockout_until');
    final failedAttempts = _sharedPrefService.getInt('pin_failed_attempts') ?? 0;

    final isBiometricsResult = await _biometricRepository.isBiometricsEnabled();
    final isBiometricsEnabled = isBiometricsResult.fold((_) => false, (enabled) => enabled);

    emit(state.copyWith(
      failedAttempts: failedAttempts,
      isBiometricsEnabled: isBiometricsEnabled,
    ));

    if (lockoutUntil != null) {
      final remainingMs = lockoutUntil - DateTime.now().millisecondsSinceEpoch;
      if (remainingMs > 0) {
        final remainingSeconds = (remainingMs / 1000).ceil();
        emit(state.copyWith(
          status: PinConfirmationStatus.lockedOut,
          lockoutSecondsRemaining: remainingSeconds,
        ));
        _startLockoutTimer();
        return;
      } else {
        _sharedPrefService.remove('pin_lockout_until');
        _sharedPrefService.remove('pin_failed_attempts');
      }
    }

    if (isBiometricsEnabled) {
      add(const AuthenticateWithBiometricsEvent());
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final lockoutUntil = _sharedPrefService.getInt('pin_lockout_until') ?? 0;
      final remainingMs = lockoutUntil - DateTime.now().millisecondsSinceEpoch;
      final remainingSeconds = (remainingMs / 1000).ceil();
      add(LockoutTimerTickedEvent(remainingSeconds));
    });
  }

  void _onLockoutTimerTicked(
    LockoutTimerTickedEvent event,
    Emitter<PinConfirmationState> emit,
  ) {
    if (event.secondsRemaining <= 0) {
      _lockoutTimer?.cancel();
      _sharedPrefService.remove('pin_lockout_until');
      _sharedPrefService.remove('pin_failed_attempts');
      emit(state.copyWith(
        status: PinConfirmationStatus.initial,
        lockoutSecondsRemaining: 0,
        failedAttempts: 0,
      ));
    } else {
      emit(state.copyWith(
        status: PinConfirmationStatus.lockedOut,
        lockoutSecondsRemaining: event.secondsRemaining,
      ));
    }
  }

  Future<void> _onAuthenticateWithBiometrics(
    AuthenticateWithBiometricsEvent event,
    Emitter<PinConfirmationState> emit,
  ) async {
    if (state.status == PinConfirmationStatus.lockedOut ||
        state.status == PinConfirmationStatus.success ||
        state.status == PinConfirmationStatus.verifying) {
      return;
    }

    final result = await _biometricRepository.authenticate(
      reason: 'Please authenticate to confirm the transaction',
    );

    await result.fold(
      (failure) async {
        // Biometrics failure / cancellation does not increment failed attempts
      },
      (success) async {
        if (success) {
          emit(state.copyWith(status: PinConfirmationStatus.verifying));
          await _sharedPrefService.remove('pin_lockout_until');
          await _sharedPrefService.remove('pin_failed_attempts');

          if (state.transaction != null) {
            final completionResult = await _completeTransactionUseCase(state.transaction!);
            completionResult.fold(
              (failure) {
                emit(state.copyWith(
                  pin: '',
                  status: PinConfirmationStatus.failure,
                  pinError: true,
                  errorMessage: failure.message,
                ));
                emit(state.copyWith(pinError: false));
              },
              (_) {
                emit(state.copyWith(
                  status: PinConfirmationStatus.success,
                  failedAttempts: 0,
                ));
              },
            );
          } else {
            emit(state.copyWith(
              status: PinConfirmationStatus.success,
              failedAttempts: 0,
            ));
          }
        }
      },
    );
  }

  Future<void> _onEnterPinDigit(
    EnterPinDigitEvent event,
    Emitter<PinConfirmationState> emit,
  ) async {
    if (state.status == PinConfirmationStatus.verifying ||
        state.status == PinConfirmationStatus.success ||
        state.status == PinConfirmationStatus.lockedOut) {
      return;
    }

    final currentPin = state.pin + event.digit;

    if (currentPin.length < 4) {
      emit(state.copyWith(
        pin: currentPin,
        status: PinConfirmationStatus.entering,
        pinError: false,
      ));
      return;
    }

    emit(state.copyWith(
      pin: currentPin,
      status: PinConfirmationStatus.verifying,
      pinError: false,
    ));

    final result = await _verifyPinUseCase(pin: currentPin);

    await result.fold(
      (failure) async {
        final currentFailed = (state.failedAttempts) + 1;
        await _sharedPrefService.setInt('pin_failed_attempts', currentFailed);

        if (currentFailed >= 3) {
          const lockoutDuration = 30;
          final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (lockoutDuration * 1000);
          await _sharedPrefService.setInt('pin_lockout_until', lockoutUntil);

          emit(state.copyWith(
            pin: '',
            status: PinConfirmationStatus.lockedOut,
            pinError: true,
            errorMessage: failure.message,
            failedAttempts: currentFailed,
            lockoutSecondsRemaining: lockoutDuration,
          ));
          emit(state.copyWith(pinError: false));
          _startLockoutTimer();
        } else {
          emit(state.copyWith(
            pin: '',
            status: PinConfirmationStatus.failure,
            pinError: true,
            errorMessage: failure.message,
            failedAttempts: currentFailed,
          ));
          emit(state.copyWith(pinError: false));
        }
      },
      (isValid) async {
        if (isValid) {
          await _sharedPrefService.remove('pin_lockout_until');
          await _sharedPrefService.remove('pin_failed_attempts');

          if (state.transaction != null) {
            final completionResult = await _completeTransactionUseCase(state.transaction!);
            completionResult.fold(
              (failure) {
                emit(state.copyWith(
                  pin: '',
                  status: PinConfirmationStatus.failure,
                  pinError: true,
                  errorMessage: failure.message,
                ));
                emit(state.copyWith(pinError: false));
              },
              (_) {
                emit(state.copyWith(
                  status: PinConfirmationStatus.success,
                  failedAttempts: 0,
                ));
              },
            );
          } else {
            emit(state.copyWith(
              status: PinConfirmationStatus.success,
              failedAttempts: 0,
            ));
          }
        } else {
          final currentFailed = (state.failedAttempts) + 1;
          await _sharedPrefService.setInt('pin_failed_attempts', currentFailed);

          if (currentFailed >= 3) {
            const lockoutDuration = 30;
            final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (lockoutDuration * 1000);
            await _sharedPrefService.setInt('pin_lockout_until', lockoutUntil);

            emit(state.copyWith(
              pin: '',
              status: PinConfirmationStatus.lockedOut,
              pinError: true,
              failedAttempts: currentFailed,
              lockoutSecondsRemaining: lockoutDuration,
            ));
            emit(state.copyWith(pinError: false));
            _startLockoutTimer();
          } else {
            emit(state.copyWith(
              pin: '',
              status: PinConfirmationStatus.failure,
              pinError: true,
              failedAttempts: currentFailed,
            ));
            emit(state.copyWith(pinError: false));
          }
        }
      },
    );
  }

  void _onDeletePinDigit(
    DeletePinDigitEvent event,
    Emitter<PinConfirmationState> emit,
  ) {
    if (state.status == PinConfirmationStatus.verifying ||
        state.status == PinConfirmationStatus.success ||
        state.status == PinConfirmationStatus.lockedOut) {
      return;
    }
    if (state.pin.isEmpty) return;
    emit(state.copyWith(
      pin: state.pin.substring(0, state.pin.length - 1),
      pinError: false,
    ));
  }

  @override
  Future<void> close() {
    _lockoutTimer?.cancel();
    return super.close();
  }
}
