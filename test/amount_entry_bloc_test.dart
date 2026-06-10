import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:crypto_app/shared/error/failure.dart';
import 'package:crypto_app/feature/transfer/bloc/amount_entry_bloc.dart';
import 'package:crypto_app/feature/transfer/bloc/amount_entry_event.dart';
import 'package:crypto_app/feature/transfer/bloc/amount_entry_state.dart';
import 'package:crypto_app/feature/transfer/domain/repositories/transfer_repository.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/get_max_coin_available_usecase.dart';

import 'package:crypto_app/shared/data/repositories/currency_repository.dart';

class FakeTransferRepository implements TransferRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetMaxCoinAvailableUseCase extends GetMaxCoinAvailableUseCase {
  final String mockMaxAvailable;

  FakeGetMaxCoinAvailableUseCase({this.mockMaxAvailable = '100.00'})
      : super(FakeTransferRepository());

  @override
  Future<Either<Failure, String>> call({
    required String coinSymbol,
    required String network,
  }) async {
    return Right(mockMaxAvailable);
  }
}

class FakeCurrencyRepository implements CurrencyRepository {
  @override
  Future<String> getSelectedCurrency() async => 'USD';

  @override
  Future<void> setSelectedCurrency(String currency) async {}

  @override
  double getExchangeRate(String coinSymbol, String currency) {
    if (coinSymbol == 'USDC') return 1.0;
    if (coinSymbol == 'SOL') return 150.0;
    if (coinSymbol == 'ETH') return 3400.0;
    return 1.0;
  }

  @override
  String getCurrencySymbol(String currency) => '\$';
}

void main() {
  late AmountEntryBloc bloc;
  late FakeGetMaxCoinAvailableUseCase fakeUseCase;
  late FakeCurrencyRepository fakeCurrencyRepository;

  setUp(() {
    fakeUseCase = FakeGetMaxCoinAvailableUseCase(mockMaxAvailable: '100.00');
    fakeCurrencyRepository = FakeCurrencyRepository();
    bloc = AmountEntryBloc(fakeUseCase, fakeCurrencyRepository);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is correct', () {
    expect(bloc.state.amountInput, '');
    expect(bloc.state.maxCoinAvailable, '0.0');
    expect(bloc.state.status, AmountEntryStatus.initial);
    expect(bloc.state.coinSymbol, '');
  });

  test('FetchMaxAvailableEvent updates coinSymbol and maxCoinAvailable', () async {
    bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));

    await expectLater(
      bloc.stream,
      emitsInOrder([
        const AmountEntryState(
          status: AmountEntryStatus.loading,
          coinSymbol: 'USDC',
          amountInput: '',
          maxCoinAvailable: '0.0',
        ),
        const AmountEntryState(
          status: AmountEntryStatus.success,
          coinSymbol: 'USDC',
          amountInput: '',
          maxCoinAvailable: '100.00',
        ),
      ]),
    );
  });

  group('Decimal Precision Limits Enforced', () {
    test('USDC blocks input beyond 2 decimal places', () async {
      // 1. Fetch Max Available to setup USDC coinSymbol
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      // 2. Type '1', '.', '2', '3'
      bloc.add(const UpdateAmountInputEvent('1'));
      bloc.add(const UpdateAmountInputEvent('.'));
      bloc.add(const UpdateAmountInputEvent('2'));
      bloc.add(const UpdateAmountInputEvent('3'));

      // Wait until stream emits '1.23'
      await bloc.stream.firstWhere((state) => state.amountInput == '1.23');

      // 3. Try typing a third decimal '4' (should be blocked)
      bloc.add(const UpdateAmountInputEvent('4'));
      await Future.delayed(Duration.zero); // yield to event loop

      expect(bloc.state.amountInput, '1.23');
    });

    test('SOL blocks input beyond 6 decimal places', () async {
      // 1. Fetch Max Available for SOL
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'SOL', network: 'Solana'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      // 2. Type '1', '.', '1', '2', '3', '4', '5', '6'
      bloc.add(const UpdateAmountInputEvent('1'));
      bloc.add(const UpdateAmountInputEvent('.'));
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        bloc.add(UpdateAmountInputEvent(digit));
      }

      await bloc.stream.firstWhere((state) => state.amountInput == '1.123456');

      // 3. Try typing a 7th decimal '7' (should be blocked)
      bloc.add(const UpdateAmountInputEvent('7'));
      await Future.delayed(Duration.zero); // yield to event loop

      expect(bloc.state.amountInput, '1.123456');
    });

    test('ETH blocks input beyond 8 decimal places', () async {
      // 1. Fetch Max Available for ETH
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'ETH', network: 'Ethereum Network'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      // 2. Type '1', '.', '1', '2', '3', '4', '5', '6', '7', '8'
      bloc.add(const UpdateAmountInputEvent('1'));
      bloc.add(const UpdateAmountInputEvent('.'));
      for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8']) {
        bloc.add(UpdateAmountInputEvent(digit));
      }

      await bloc.stream.firstWhere((state) => state.amountInput == '1.12345678');

      // 3. Try typing a 9th decimal '9' (should be blocked)
      bloc.add(const UpdateAmountInputEvent('9'));
      await Future.delayed(Duration.zero); // yield to event loop

      expect(bloc.state.amountInput, '1.12345678');
    });

    test('Backspace reduces input digits correctly', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      bloc.add(const UpdateAmountInputEvent('1'));
      bloc.add(const UpdateAmountInputEvent('2'));
      await bloc.stream.firstWhere((state) => state.amountInput == '12');

      bloc.add(const BackspaceAmountInputEvent());
      await bloc.stream.firstWhere((state) => state.amountInput == '1');

      expect(bloc.state.amountInput, '1');
    });

    test('SetMaxAmountInputEvent formats available balance to coin precision', () async {
      final solUseCase = FakeGetMaxCoinAvailableUseCase(mockMaxAvailable: '3.25');
      final solBloc = AmountEntryBloc(solUseCase, FakeCurrencyRepository());

      solBloc.add(const FetchMaxAvailableEvent(coinSymbol: 'SOL', network: 'Solana'));
      await solBloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      solBloc.add(const SetMaxAmountInputEvent());
      await solBloc.stream.firstWhere((state) => state.amountInput == '3.250000');

      expect(solBloc.state.amountInput, '3.250000');

      solBloc.close();
    });
  });

  group('Validation Error Detection', () {
    test('exceeding balance shows correct error', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      bloc.add(const UpdateAmountInputEvent('1'));
      bloc.add(const UpdateAmountInputEvent('0'));
      bloc.add(const UpdateAmountInputEvent('0'));
      bloc.add(const UpdateAmountInputEvent('.'));
      bloc.add(const UpdateAmountInputEvent('0'));
      bloc.add(const UpdateAmountInputEvent('1')); // 100.01

      await bloc.stream.firstWhere((state) => state.amountInput == '100.01');
      expect(bloc.state.validationError, 'Amount exceeds available balance');
      expect(bloc.state.isAmountValid, isFalse);
    });

    test('fully formed zero shows correct error', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      bloc.add(const UpdateAmountInputEvent('0'));
      bloc.add(const UpdateAmountInputEvent('.'));
      bloc.add(const UpdateAmountInputEvent('0'));
      bloc.add(const UpdateAmountInputEvent('0')); // 0.00

      await bloc.stream.firstWhere((state) => state.amountInput == '0.00');
      expect(bloc.state.validationError, 'Amount must be greater than zero');
      expect(bloc.state.isAmountValid, isFalse);
    });

    test('valid input shows no error', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      bloc.add(const UpdateAmountInputEvent('1'));
      bloc.add(const UpdateAmountInputEvent('2'));
      bloc.add(const UpdateAmountInputEvent('.'));
      bloc.add(const UpdateAmountInputEvent('5'));

      await bloc.stream.firstWhere((state) => state.amountInput == '12.5');
      expect(bloc.state.validationError, isNull);
      expect(bloc.state.isAmountValid, isTrue);
    });
  });

  group('Negative Test Cases', () {
    test('Negative Case 1: Tapping decimal point twice is ignored', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      bloc.add(const UpdateAmountInputEvent('1'));
      bloc.add(const UpdateAmountInputEvent('.'));
      bloc.add(const UpdateAmountInputEvent('2'));
      bloc.add(const UpdateAmountInputEvent('.')); // Second dot, should be ignored

      await Future.delayed(Duration.zero);
      expect(bloc.state.amountInput, '1.2');
    });

    test('Negative Case 2: Tapping backspace on empty input is a no-op', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      expect(bloc.state.amountInput, '');
      bloc.add(const BackspaceAmountInputEvent());
      await Future.delayed(Duration.zero);

      expect(bloc.state.amountInput, '');
      expect(bloc.state.isAmountValid, isFalse);
    });

    test('Negative Case 3: Empty amount entry input is invalid', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      expect(bloc.state.amountInput, '');
      expect(bloc.state.isAmountValid, isFalse);
      expect(bloc.state.validationError, isNull); // Empty input shouldn't show errors until typed
    });

    test('Negative Case 4: Sole decimal point input defaults to 0. and is invalid', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      bloc.add(const UpdateAmountInputEvent('.'));
      await bloc.stream.firstWhere((state) => state.amountInput == '0.');

      expect(bloc.state.amount, 0.0);
      expect(bloc.state.isAmountValid, isFalse);
    });

    test('Negative Case 5: Values below the precision limit are blocked and trigger greater-than-zero error', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      // USDC allows only 2 decimals. Let's try typing 0.0001
      bloc.add(const UpdateAmountInputEvent('0'));
      bloc.add(const UpdateAmountInputEvent('.'));
      bloc.add(const UpdateAmountInputEvent('0'));
      bloc.add(const UpdateAmountInputEvent('0'));
      bloc.add(const UpdateAmountInputEvent('0')); // This 3rd decimal should be blocked!
      bloc.add(const UpdateAmountInputEvent('1')); // This 4th decimal should be blocked!

      await Future.delayed(Duration.zero);

      expect(bloc.state.amountInput, '0.00');
      expect(bloc.state.validationError, 'Amount must be greater than zero');
      expect(bloc.state.isAmountValid, isFalse);
    });

    test('Negative Case 6: Backspacing a single digit to empty becomes invalid', () async {
      bloc.add(const FetchMaxAvailableEvent(coinSymbol: 'USDC', network: 'Polygon'));
      await bloc.stream.firstWhere((state) => state.status == AmountEntryStatus.success);

      bloc.add(const UpdateAmountInputEvent('5'));
      await bloc.stream.firstWhere((state) => state.amountInput == '5');
      expect(bloc.state.isAmountValid, isTrue);

      bloc.add(const BackspaceAmountInputEvent());
      await bloc.stream.firstWhere((state) => state.amountInput == '');
      expect(bloc.state.isAmountValid, isFalse);
    });
  });
}
