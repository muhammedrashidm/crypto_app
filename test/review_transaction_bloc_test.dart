import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:crypto_app/shared/error/failure.dart';
import 'package:crypto_app/shared/data/repositories/currency_repository.dart';
import 'package:crypto_app/feature/transfer/domain/entities/contact.dart';
import 'package:crypto_app/feature/transfer/domain/entities/transaction.dart';
import 'package:crypto_app/feature/transfer/domain/entities/create_transaction.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/create_transaction_usecase.dart';
import 'package:crypto_app/feature/transfer/bloc/review_transaction/review_transaction_bloc.dart';
import 'package:crypto_app/feature/transfer/bloc/review_transaction/review_transaction_event.dart';
import 'package:crypto_app/feature/transfer/bloc/review_transaction/review_transaction_state.dart';

class FakeCurrencyRepository implements CurrencyRepository {
  @override
  Future<String> getSelectedCurrency() async => 'USD';

  @override
  Future<void> setSelectedCurrency(String currency) async {}

  @override
  double getExchangeRate(String coinSymbol, String currency) {
    if (coinSymbol == 'USDC') return 1.0;
    if (coinSymbol == 'SOL') return 150.0;
    return 1.0;
  }

  @override
  String getCurrencySymbol(String currency) => '\$';
}

class FakeCreateTransactionUseCase implements CreateTransactionUseCase {
  final Either<Failure, Transaction> result;
  Contact? lastRecipient;
  String? lastAmount;
  String? lastFee;
  String? lastCoinSymbol;
  String? lastNetwork;
  String? lastMemo;

  FakeCreateTransactionUseCase(this.result);

  @override
  Future<Either<Failure, Transaction>> call({
    required Contact recipient,
    required String amount,
    required String fee,
    required String coinSymbol,
    required String network,
    String? memo,
  }) async {
    lastRecipient = recipient;
    lastAmount = amount;
    lastFee = fee;
    lastCoinSymbol = coinSymbol;
    lastNetwork = network;
    lastMemo = memo;
    return result;
  }
}

void main() {
  late ReviewTransactionBloc bloc;
  late FakeCreateTransactionUseCase fakeUseCase;
  late FakeCurrencyRepository fakeCurrencyRepository;

  final testContact = const Contact(
    name: 'Nikhil',
    bepayId: 'nikhil@bepay',
    address: 'nikhil@bepay',
    contactType: 'Bepay User',
  );

  setUp(() {
    fakeCurrencyRepository = FakeCurrencyRepository();
  });

  group('ReviewTransactionBloc Tests', () {
    test('InitReviewTransactionEvent updates exchange rates correctly', () async {
      fakeUseCase = FakeCreateTransactionUseCase(
        Left(ServerFailure('not used')),
      );
      bloc = ReviewTransactionBloc(fakeUseCase, fakeCurrencyRepository);

      bloc.add(const InitReviewTransactionEvent(coinSymbol: 'SOL'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ReviewTransactionState(
            selectedCurrency: 'USD',
            currencySymbol: '\$',
            exchangeRate: 150.0,
          ),
        ]),
      );
      await bloc.close();
    });

    test('ConfirmReviewEvent failure emits failure state', () async {
      fakeUseCase = FakeCreateTransactionUseCase(
        Left(ServerFailure('Insufficient funds')),
      );
      bloc = ReviewTransactionBloc(fakeUseCase, fakeCurrencyRepository);

      final createTx = CreateTransaction(
        coinSymbol: 'USDC',
        network: 'Polygon',
        recipient: testContact,
        amount: '50.00',
        memo: 'Test Memo',
      );

      bloc.add(ConfirmReviewEvent(createTx: createTx));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ReviewTransactionState(status: ReviewTransactionStatus.loading),
          const ReviewTransactionState(
            status: ReviewTransactionStatus.failure,
            errorMessage: 'Insufficient funds',
          ),
        ]),
      );

      expect(fakeUseCase.lastRecipient, testContact);
      expect(fakeUseCase.lastAmount, '50.00');
      expect(fakeUseCase.lastFee, '0.02'); // USDC estimated fee is 0.02
      expect(fakeUseCase.lastMemo, 'Test Memo');

      await bloc.close();
    });

    test('ConfirmReviewEvent success emits success state', () async {
      final mockTx = Transaction(
        recipientName: testContact.name,
        recipientAddress: testContact.address,
        networkName: 'Polygon',
        amount: '10.0',
        fee: '0.02',
        total: '10.02',
        transactionId: 'tx_123',
        timestamp: DateTime(2026),
        coinSymbol: 'USDC',
        memo: 'Gift',
        status: TransactionStatus.success,
      );

      fakeUseCase = FakeCreateTransactionUseCase(Right(mockTx));
      bloc = ReviewTransactionBloc(fakeUseCase, fakeCurrencyRepository);

      final createTx = CreateTransaction(
        coinSymbol: 'USDC',
        network: 'Polygon',
        recipient: testContact,
        amount: '10.0',
        memo: 'Gift',
      );

      bloc.add(ConfirmReviewEvent(createTx: createTx));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ReviewTransactionState(status: ReviewTransactionStatus.loading),
          ReviewTransactionState(
            status: ReviewTransactionStatus.success,
            createdTransaction: mockTx,
          ),
        ]),
      );

      expect(fakeUseCase.lastMemo, 'Gift');
      expect(fakeUseCase.lastFee, '0.02');

      await bloc.close();
    });
  });
}
