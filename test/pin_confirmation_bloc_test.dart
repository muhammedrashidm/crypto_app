import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/shared/services/shared_pref_service.dart';
import 'package:crypto_app/shared/error/failure.dart';
import 'package:crypto_app/feature/home/domain/repositories/biometric_repository.dart';
import 'package:crypto_app/feature/transfer/bloc/pin_confirmation/pin_confirmation_bloc.dart';
import 'package:crypto_app/feature/transfer/bloc/pin_confirmation/pin_confirmation_event.dart';
import 'package:crypto_app/feature/transfer/bloc/pin_confirmation/pin_confirmation_state.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/verify_pin_usecase.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/complete_transaction_usecase.dart';
import 'package:crypto_app/feature/transfer/domain/repositories/transfer_repository.dart';
import 'package:crypto_app/feature/transfer/domain/entities/transaction.dart';

class FakeTransferRepository implements TransferRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeVerifyPinUseCase extends VerifyPinUseCase {
  final bool shouldVerifySucceed;
  final bool isPinValid;

  FakeVerifyPinUseCase({this.shouldVerifySucceed = true, this.isPinValid = true})
      : super(FakeTransferRepository());

  @override
  Future<Either<Failure, bool>> call({required String pin}) async {
    if (!shouldVerifySucceed) {
      return const Left(ServerFailure('PIN Verification Error'));
    }
    return Right(pin == '1234' || (isPinValid && pin.isNotEmpty));
  }
}

class FakeCompleteTransactionUseCase extends CompleteTransactionUseCase {
  final bool shouldSucceed;

  FakeCompleteTransactionUseCase({this.shouldSucceed = true})
      : super(FakeTransferRepository());

  @override
  Future<Either<Failure, Unit>> call(Transaction transaction) async {
    if (!shouldSucceed) {
      return const Left(ServerFailure('Transaction Completion Error'));
    }
    return const Right(unit);
  }
}

class FakeBiometricRepository implements BiometricRepository {
  bool isEnabled = false;
  bool isDismissedVal = false;
  bool shouldAuthSucceed = true;
  int authCount = 0;

  FakeBiometricRepository({
    this.isEnabled = false,
    this.isDismissedVal = false,
    this.shouldAuthSucceed = true,
  });

  @override
  Future<Either<Failure, bool>> isBiometricsEnabled() async => Right(isEnabled);

  @override
  Future<Either<Failure, Unit>> setBiometricsEnabled(bool enabled) async {
    isEnabled = enabled;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, bool>> isPromptDismissed() async => Right(isDismissedVal);

  @override
  Future<Either<Failure, Unit>> setPromptDismissed(bool dismissed) async {
    isDismissedVal = dismissed;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, bool>> authenticate({String? reason}) async {
    authCount++;
    return Right(shouldAuthSucceed);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SharedPrefService sharedPrefService;
  late FakeBiometricRepository fakeBiometricRepository;

  final mockTransaction = Transaction(
    recipientName: 'Nikhil',
    recipientAddress: '0x123',
    networkName: 'Polygon',
    amount: '10.0',
    fee: '0.1',
    total: '10.1',
    transactionId: 'tx_123',
    timestamp: DateTime.now(),
    coinSymbol: 'USDC',
    status: TransactionStatus.success,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    sharedPrefService = SharedPrefService(prefs);
    fakeBiometricRepository = FakeBiometricRepository();
  });

  group('PinConfirmationBloc Unit Tests', () {
    test('initial state should load failed attempts from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'pin_failed_attempts': 2,
      });
      prefs = await SharedPreferences.getInstance();
      sharedPrefService = SharedPrefService(prefs);

      final bloc = PinConfirmationBloc(
        FakeVerifyPinUseCase(),
        FakeCompleteTransactionUseCase(),
        sharedPrefService,
        fakeBiometricRepository,
      );

      bloc.add(InitPinConfirmationEvent(mockTransaction));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PinConfirmationState>()
              .having((s) => s.transaction, 'transaction', mockTransaction),
          isA<PinConfirmationState>()
              .having((s) => s.failedAttempts, 'failedAttempts', 2)
              .having((s) => s.status, 'status', PinConfirmationStatus.initial),
        ]),
      );
      await bloc.close();
    });

    test('initial state should start lockout timer if active lockout exists in SharedPreferences', () async {
      final lockoutTime = DateTime.now().millisecondsSinceEpoch + 15000;
      SharedPreferences.setMockInitialValues({
        'pin_failed_attempts': 3,
        'pin_lockout_until': lockoutTime,
      });
      prefs = await SharedPreferences.getInstance();
      sharedPrefService = SharedPrefService(prefs);

      final bloc = PinConfirmationBloc(
        FakeVerifyPinUseCase(),
        FakeCompleteTransactionUseCase(),
        sharedPrefService,
        fakeBiometricRepository,
      );

      bloc.add(InitPinConfirmationEvent(mockTransaction));

      final state = await bloc.stream.firstWhere((s) => s.status == PinConfirmationStatus.lockedOut);
      expect(state.status, PinConfirmationStatus.lockedOut);
      expect(state.lockoutSecondsRemaining, greaterThan(0));
      expect(state.lockoutSecondsRemaining, lessThanOrEqualTo(15));
      await bloc.close();
    });

    test('entering wrong PIN should increment failed attempts and trigger lockout on 3rd fail', () async {
      final bloc = PinConfirmationBloc(
        FakeVerifyPinUseCase(isPinValid: false),
        FakeCompleteTransactionUseCase(),
        sharedPrefService,
        fakeBiometricRepository,
      );

      bloc.add(InitPinConfirmationEvent(mockTransaction));

      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));

      var state = await bloc.stream.firstWhere((s) => s.status == PinConfirmationStatus.failure);
      expect(state.failedAttempts, 1);
      expect(sharedPrefService.getInt('pin_failed_attempts'), 1);

      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));

      state = await bloc.stream.firstWhere((s) => s.failedAttempts == 2);
      expect(state.status, PinConfirmationStatus.failure);
      expect(sharedPrefService.getInt('pin_failed_attempts'), 2);

      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));
      bloc.add(const EnterPinDigitEvent('9'));

      state = await bloc.stream.firstWhere((s) => s.status == PinConfirmationStatus.lockedOut);
      expect(state.failedAttempts, 3);
      expect(state.lockoutSecondsRemaining, 30);
      expect(sharedPrefService.getInt('pin_failed_attempts'), 3);
      expect(sharedPrefService.getInt('pin_lockout_until'), isNotNull);

      await bloc.close();
    });

    test('successful PIN entry clears failed attempts', () async {
      SharedPreferences.setMockInitialValues({
        'pin_failed_attempts': 2,
      });
      prefs = await SharedPreferences.getInstance();
      sharedPrefService = SharedPrefService(prefs);

      final bloc = PinConfirmationBloc(
        FakeVerifyPinUseCase(isPinValid: true),
        FakeCompleteTransactionUseCase(),
        sharedPrefService,
        fakeBiometricRepository,
      );

      bloc.add(InitPinConfirmationEvent(mockTransaction));
      await bloc.stream.firstWhere((s) => s.failedAttempts == 2);

      bloc.add(const EnterPinDigitEvent('1'));
      bloc.add(const EnterPinDigitEvent('2'));
      bloc.add(const EnterPinDigitEvent('3'));
      bloc.add(const EnterPinDigitEvent('4'));

      final state = await bloc.stream.firstWhere((s) => s.status == PinConfirmationStatus.success);
      expect(state.status, PinConfirmationStatus.success);
      expect(state.failedAttempts, 0);

      expect(sharedPrefService.getInt('pin_failed_attempts'), isNull);
      expect(sharedPrefService.getInt('pin_lockout_until'), isNull);

      await bloc.close();
    });

    test('when biometrics is enabled, it should automatically trigger biometric authentication on init and succeed', () async {
      fakeBiometricRepository = FakeBiometricRepository(isEnabled: true, shouldAuthSucceed: true);

      final bloc = PinConfirmationBloc(
        FakeVerifyPinUseCase(),
        FakeCompleteTransactionUseCase(),
        sharedPrefService,
        fakeBiometricRepository,
      );

      bloc.add(InitPinConfirmationEvent(mockTransaction));

      // Init finishes, triggers biometric auth event, succeeds, transitions status to success
      final state = await bloc.stream.firstWhere((s) => s.status == PinConfirmationStatus.success);
      expect(state.status, PinConfirmationStatus.success);
      expect(fakeBiometricRepository.authCount, 1);

      await bloc.close();
    });

    test('when biometric authentication fails or is cancelled, it should NOT increment PIN failed attempts', () async {
      fakeBiometricRepository = FakeBiometricRepository(isEnabled: true, shouldAuthSucceed: false);

      final bloc = PinConfirmationBloc(
        FakeVerifyPinUseCase(),
        FakeCompleteTransactionUseCase(),
        sharedPrefService,
        fakeBiometricRepository,
      );

      bloc.add(InitPinConfirmationEvent(mockTransaction));

      // Wait for state to reflect biometrics enabled check
      final state = await bloc.stream.firstWhere((s) => s.isBiometricsEnabled);
      expect(state.isBiometricsEnabled, true);

      // Give event loop time to run the async authenticate call
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify auth was called but failed attempts remained 0 because it was a biometric failure
      expect(bloc.state.failedAttempts, 0);
      expect(sharedPrefService.getInt('pin_failed_attempts'), isNull);
      expect(fakeBiometricRepository.authCount, 1);

      await bloc.close();
    });

    test('when locked out, biometric authentication should not be triggered', () async {
      final lockoutTime = DateTime.now().millisecondsSinceEpoch + 15000;
      SharedPreferences.setMockInitialValues({
        'pin_failed_attempts': 3,
        'pin_lockout_until': lockoutTime,
      });
      prefs = await SharedPreferences.getInstance();
      sharedPrefService = SharedPrefService(prefs);
      
      fakeBiometricRepository = FakeBiometricRepository(isEnabled: true, shouldAuthSucceed: true);

      final bloc = PinConfirmationBloc(
        FakeVerifyPinUseCase(),
        FakeCompleteTransactionUseCase(),
        sharedPrefService,
        fakeBiometricRepository,
      );

      bloc.add(InitPinConfirmationEvent(mockTransaction));

      final state = await bloc.stream.firstWhere((s) => s.status == PinConfirmationStatus.lockedOut);
      expect(state.status, PinConfirmationStatus.lockedOut);

      // Verify that biometric auth is never called since we are locked out
      await Future.delayed(const Duration(milliseconds: 100));
      expect(fakeBiometricRepository.authCount, 0);

      await bloc.close();
    });
  });
}
