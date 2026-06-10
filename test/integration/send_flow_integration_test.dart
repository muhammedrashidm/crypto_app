import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_app/shared/di/injection.dart';
import 'package:crypto_app/shared/error/failure.dart';
import 'package:crypto_app/shared/services/shared_pref_service.dart';
import 'package:crypto_app/shared/navigation/app_pages.dart';
import 'package:crypto_app/shared/widgets/bepay_button.dart';
import 'package:crypto_app/shared/widgets/bepay_keypad.dart';

import 'package:crypto_app/feature/transfer/view/recipient_entry_page.dart';
import 'package:crypto_app/feature/transfer/view/amount_entry_page.dart';
import 'package:crypto_app/feature/transfer/view/pin_confirmation_page.dart';

import 'package:crypto_app/feature/transfer/domain/entities/contact.dart';
import 'package:crypto_app/feature/transfer/domain/entities/create_transaction.dart';
import 'package:crypto_app/feature/transfer/domain/entities/transaction.dart';
import 'package:crypto_app/feature/transfer/domain/repositories/transfer_repository.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/get_recent_recipients_usecase.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/get_max_coin_available_usecase.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/verify_pin_usecase.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/complete_transaction_usecase.dart';
import 'package:crypto_app/feature/home/domain/repositories/biometric_repository.dart';
import 'package:crypto_app/shared/data/repositories/currency_repository.dart';

import 'package:crypto_app/feature/transfer/bloc/recipient_entry_bloc.dart';
import 'package:crypto_app/feature/transfer/bloc/amount_entry_bloc.dart';
import 'package:crypto_app/feature/transfer/bloc/pin_confirmation_bloc.dart';

// --- FAKE IMPLEMENTATIONS ---

class FakeTransferRepository implements TransferRepository {
  List<Contact> mockRecipients = [
    Contact(
      name: 'Nikhil',
      address: 'nikhil@bepay',
      bepayId: 'nikhil@bepay',
      contactType: 'Verified bepayID',
    )
  ];

  String maxCoinAvailableValue = '100.00';
  bool pinVerificationResult = true;

  @override
  Future<Either<Failure, List<Contact>>> getRecentRecipients({String? query}) async {
    if (query == null || query.isEmpty) {
      return Right(mockRecipients);
    }
    final filtered = mockRecipients
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Right(filtered);
  }

  @override
  Future<Either<Failure, String>> getMaxCoinAvailable({
    required String coinSymbol,
    required String network,
  }) async {
    return Right(maxCoinAvailableValue);
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction({
    required Contact recipient,
    required String amount,
    required String fee,
    required String coinSymbol,
    required String network,
    String? memo,
  }) async {
    final amtDouble = double.tryParse(amount) ?? 0.0;
    final feeDouble = double.tryParse(fee) ?? 0.0;
    final totalVal = amtDouble + feeDouble;
    return Right(Transaction(
      transactionId: 'tx_123456789',
      recipientName: recipient.name,
      recipientAddress: recipient.address,
      networkName: network,
      amount: amount,
      fee: fee,
      total: totalVal.toStringAsFixed(2),
      coinSymbol: coinSymbol,
      status: TransactionStatus.success,
      timestamp: DateTime.now(),
      memo: memo,
    ));
  }

  @override
  Future<Either<Failure, bool>> verifyPin({required String pin}) async {
    if (pin == '1234') {
      return const Right(true);
    }
    return const Right(false);
  }

  @override
  Future<Either<Failure, Unit>> completeTransaction(Transaction transaction) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Unit>> addContact(Contact contact) async {
    return const Right(unit);
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
  String getCurrencySymbol(String currency) => r'$';
}

class FakeBiometricRepository implements BiometricRepository {
  @override
  Future<Either<Failure, bool>> isBiometricsEnabled() async => const Right(false);

  @override
  Future<Either<Failure, Unit>> setBiometricsEnabled(bool enabled) async => const Right(unit);

  @override
  Future<Either<Failure, bool>> isPromptDismissed() async => const Right(true);

  @override
  Future<Either<Failure, Unit>> setPromptDismissed(bool dismissed) async => const Right(unit);

  @override
  Future<Either<Failure, bool>> authenticate({String? reason}) async => const Right(false);
}

void main() {
  late FakeTransferRepository fakeRepository;
  late FakeCurrencyRepository fakeCurrencyRepository;
  late FakeBiometricRepository fakeBiometricRepository;

  setUp(() async {
    await getIt.reset();
    fakeRepository = FakeTransferRepository();
    fakeCurrencyRepository = FakeCurrencyRepository();
    fakeBiometricRepository = FakeBiometricRepository();
  });

  Future<void> tapKeypadDigit(WidgetTester tester, String digit) async {
    await tester.tap(find.descendant(
      of: find.byType(BepayKeypad),
      matching: find.text(digit),
    ));
    await tester.pump();
  }

  group('Send Flow Integration - Step 1: Recipient Entry', () {
    testWidgets('Negative Case 1: Searching invalid address format displays no results', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final getRecentRecipientsUseCase = GetRecentRecipientsUseCase(fakeRepository);
      getIt.registerFactory<RecipientEntryBloc>(
        () => RecipientEntryBloc(getRecentRecipientsUseCase),
      );

      final createTx = CreateTransaction(coinSymbol: 'USDC', network: 'Solana');
      final router = GoRouter(
        initialLocation: AppPages.recipientEntry.path,
        routes: [
          GoRoute(
            path: AppPages.recipientEntry.path,
            builder: (context, state) => RecipientEntryPage(createTx: createTx),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Verify page title renders
      expect(find.text('Send To'), findsOneWidget);

      // Enter invalid query into search field
      await tester.enterText(find.byType(TextField), 'invalid_address');
      
      // Wait for debounce timer (300ms) to trigger and block state to update
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify empty search results state is displayed
      expect(find.text('No matching contacts found.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Negative Case 2: Searching non-existent bepayID displays empty state', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final getRecentRecipientsUseCase = GetRecentRecipientsUseCase(fakeRepository);
      getIt.registerFactory<RecipientEntryBloc>(
        () => RecipientEntryBloc(getRecentRecipientsUseCase),
      );

      final createTx = CreateTransaction(coinSymbol: 'USDC', network: 'Solana');
      final router = GoRouter(
        initialLocation: AppPages.recipientEntry.path,
        routes: [
          GoRoute(
            path: AppPages.recipientEntry.path,
            builder: (context, state) => RecipientEntryPage(createTx: createTx),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Enter non-existent ID
      await tester.enterText(find.byType(TextField), 'unknown@bepay');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify no results match message
      expect(find.text('No matching contacts found.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Positive Case: Selecting search result navigates to amount entry page', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final getRecentRecipientsUseCase = GetRecentRecipientsUseCase(fakeRepository);
      getIt.registerFactory<RecipientEntryBloc>(
        () => RecipientEntryBloc(getRecentRecipientsUseCase),
      );

      final createTx = CreateTransaction(coinSymbol: 'USDC', network: 'Solana');
      final router = GoRouter(
        initialLocation: AppPages.recipientEntry.path,
        routes: [
          GoRoute(
            path: AppPages.recipientEntry.path,
            builder: (context, state) => RecipientEntryPage(createTx: createTx),
          ),
          GoRoute(
            path: AppPages.amountEntry.path,
            builder: (context, state) {
              final tx = state.extra as CreateTransaction;
              return Scaffold(
                body: Text('Navigated to Amount Entry: ${tx.recipient?.name}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Enter valid contact name
      await tester.enterText(find.byType(TextField), 'Nikhil');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify contact shows up
      expect(find.descendant(of: find.byType(ListTile), matching: find.text('Nikhil')), findsOneWidget);

      // Tap on the result row
      await tester.tap(find.descendant(of: find.byType(ListTile), matching: find.text('Nikhil')));
      await tester.pumpAndSettle();

      // Verify successfully navigated
      expect(find.text('Navigated to Amount Entry: Nikhil'), findsOneWidget);
    });
  });

  group('Send Flow Integration - Step 2: Amount Entry', () {
    testWidgets('Negative Case 1: Initial empty / zero amount prevents continuing', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final getMaxCoinAvailableUseCase = GetMaxCoinAvailableUseCase(fakeRepository);
      getIt.registerFactory<AmountEntryBloc>(
        () => AmountEntryBloc(getMaxCoinAvailableUseCase, fakeCurrencyRepository),
      );

      final recipient = Contact(name: 'Nikhil', address: 'nikhil@bepay', bepayId: 'nikhil@bepay', contactType: 'Verified bepayID');
      final createTx = CreateTransaction(coinSymbol: 'USDC', network: 'Solana', recipient: recipient);
      
      final router = GoRouter(
        initialLocation: AppPages.amountEntry.path,
        routes: [
          GoRoute(
            path: AppPages.amountEntry.path,
            builder: (context, state) => AmountEntryPage(createTx: createTx),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Verify BepayButton 'Continue' is disabled (onPressed is null)
      final continueButton = tester.widget<BepayButton>(find.byType(BepayButton));
      expect(continueButton.onPressed, isNull);
    });

    testWidgets('Negative Case 2: Entering amount greater than balance shows error and disables button', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final getMaxCoinAvailableUseCase = GetMaxCoinAvailableUseCase(fakeRepository);
      getIt.registerFactory<AmountEntryBloc>(
        () => AmountEntryBloc(getMaxCoinAvailableUseCase, fakeCurrencyRepository),
      );

      final recipient = Contact(name: 'Nikhil', address: 'nikhil@bepay', bepayId: 'nikhil@bepay', contactType: 'Verified bepayID');
      final createTx = CreateTransaction(coinSymbol: 'USDC', network: 'Solana', recipient: recipient);

      final router = GoRouter(
        initialLocation: AppPages.amountEntry.path,
        routes: [
          GoRoute(
            path: AppPages.amountEntry.path,
            builder: (context, state) => AmountEntryPage(createTx: createTx),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Max balance is 100.00. Input 150 by tapping keys
      await tapKeypadDigit(tester, '1');
      await tapKeypadDigit(tester, '5');
      await tapKeypadDigit(tester, '0');
      await tester.pump();

      // Check validation error warning is rendered
      expect(find.text('Amount exceeds available balance'), findsOneWidget);

      // Check button is disabled
      final continueButton = tester.widget<BepayButton>(find.byType(BepayButton));
      expect(continueButton.onPressed, isNull);
    });

    testWidgets('Positive Case: Entering valid amount enables button and navigates to review', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final getMaxCoinAvailableUseCase = GetMaxCoinAvailableUseCase(fakeRepository);
      getIt.registerFactory<AmountEntryBloc>(
        () => AmountEntryBloc(getMaxCoinAvailableUseCase, fakeCurrencyRepository),
      );

      final recipient = Contact(name: 'Nikhil', address: 'nikhil@bepay', bepayId: 'nikhil@bepay', contactType: 'Verified bepayID');
      final createTx = CreateTransaction(coinSymbol: 'USDC', network: 'Solana', recipient: recipient);

      final router = GoRouter(
        initialLocation: AppPages.amountEntry.path,
        routes: [
          GoRoute(
            path: AppPages.amountEntry.path,
            builder: (context, state) => AmountEntryPage(createTx: createTx),
          ),
          GoRoute(
            path: AppPages.reviewTransaction.path,
            builder: (context, state) {
              final tx = state.extra as CreateTransaction;
              return Scaffold(
                body: Text('Review Transaction with amount ${tx.amount}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Input 50 (valid, balance is 100)
      await tapKeypadDigit(tester, '5');
      await tapKeypadDigit(tester, '0');
      await tester.pump();

      // No validation error should be present
      expect(find.text('Amount exceeds available balance'), findsNothing);

      // Check continue button is enabled and tap it
      final continueButton = tester.widget<BepayButton>(find.byType(BepayButton));
      expect(continueButton.onPressed, isNotNull);

      await tester.tap(find.byType(BepayButton));
      await tester.pumpAndSettle();

      // Check navigation succeeded
      expect(find.text('Review Transaction with amount 50'), findsOneWidget);
    });
  });

  group('Send Flow Integration - Step 3: PIN Confirmation', () {
    testWidgets('Negative Case 1: Entering incorrect PIN displays error indicator', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final verifyPinUseCase = VerifyPinUseCase(fakeRepository);
      final completeTransactionUseCase = CompleteTransactionUseCase(fakeRepository);
      
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final sharedPrefService = SharedPrefService(prefs);

      getIt.registerFactory<PinConfirmationBloc>(
        () => PinConfirmationBloc(
          verifyPinUseCase,
          completeTransactionUseCase,
          sharedPrefService,
          fakeBiometricRepository,
        ),
      );

      final recipient = Contact(name: 'Nikhil', address: 'nikhil@bepay', bepayId: 'nikhil@bepay', contactType: 'Verified bepayID');
      final transaction = Transaction(
        transactionId: 'tx_123',
        recipientName: recipient.name,
        recipientAddress: recipient.address,
        networkName: 'Solana',
        amount: '50.0',
        fee: '0.5',
        total: '50.5',
        coinSymbol: 'USDC',
        status: TransactionStatus.pending,
        timestamp: DateTime.now(),
      );

      final router = GoRouter(
        initialLocation: AppPages.pinConfirmation.path,
        routes: [
          GoRoute(
            path: AppPages.pinConfirmation.path,
            builder: (context, state) => PinConfirmationPage(transaction: transaction),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Tap '1', '1', '1', '1' (Incorrect PIN, correct is '1234')
      await tapKeypadDigit(tester, '1');
      await tapKeypadDigit(tester, '1');
      await tapKeypadDigit(tester, '1');
      await tapKeypadDigit(tester, '1');
      await tester.pumpAndSettle();

      // Verify SnackBar or error text is displayed
      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);
    });

    testWidgets('Negative Case 2: Entering incorrect PIN 3 times triggers lockout cooldown', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final verifyPinUseCase = VerifyPinUseCase(fakeRepository);
      final completeTransactionUseCase = CompleteTransactionUseCase(fakeRepository);
      
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final sharedPrefService = SharedPrefService(prefs);

      getIt.registerFactory<PinConfirmationBloc>(
        () => PinConfirmationBloc(
          verifyPinUseCase,
          completeTransactionUseCase,
          sharedPrefService,
          fakeBiometricRepository,
        ),
      );

      final recipient = Contact(name: 'Nikhil', address: 'nikhil@bepay', bepayId: 'nikhil@bepay', contactType: 'Verified bepayID');
      final transaction = Transaction(
        transactionId: 'tx_123',
        recipientName: recipient.name,
        recipientAddress: recipient.address,
        networkName: 'Solana',
        amount: '50.0',
        fee: '0.5',
        total: '50.5',
        coinSymbol: 'USDC',
        status: TransactionStatus.pending,
        timestamp: DateTime.now(),
      );

      final router = GoRouter(
        initialLocation: AppPages.pinConfirmation.path,
        routes: [
          GoRoute(
            path: AppPages.pinConfirmation.path,
            builder: (context, state) => PinConfirmationPage(transaction: transaction),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Failed Attempt 1
      for (int i = 0; i < 4; i++) {
        await tapKeypadDigit(tester, '1');
      }
      await tester.pumpAndSettle();
      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);

      // Failed Attempt 2
      for (int i = 0; i < 4; i++) {
        await tapKeypadDigit(tester, '1');
      }
      await tester.pumpAndSettle();
      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);

      // Failed Attempt 3 -> Triggers Lockout
      for (int i = 0; i < 4; i++) {
        await tapKeypadDigit(tester, '1');
      }
      await tester.pumpAndSettle();

      // Verify that the lockout box is visible containing the lockout text
      expect(find.textContaining('Too many failed attempts. Locked out for'), findsOneWidget);
    });

    testWidgets('Positive Case: Entering correct PIN authorizes transfer and navigates to result', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final verifyPinUseCase = VerifyPinUseCase(fakeRepository);
      final completeTransactionUseCase = CompleteTransactionUseCase(fakeRepository);
      
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final sharedPrefService = SharedPrefService(prefs);

      getIt.registerFactory<PinConfirmationBloc>(
        () => PinConfirmationBloc(
          verifyPinUseCase,
          completeTransactionUseCase,
          sharedPrefService,
          fakeBiometricRepository,
        ),
      );

      final recipient = Contact(name: 'Nikhil', address: 'nikhil@bepay', bepayId: 'nikhil@bepay', contactType: 'Verified bepayID');
      final transaction = Transaction(
        transactionId: 'tx_123',
        recipientName: recipient.name,
        recipientAddress: recipient.address,
        networkName: 'Solana',
        amount: '50.0',
        fee: '0.5',
        total: '50.5',
        coinSymbol: 'USDC',
        status: TransactionStatus.pending,
        timestamp: DateTime.now(),
      );

      final router = GoRouter(
        initialLocation: AppPages.pinConfirmation.path,
        routes: [
          GoRoute(
            path: AppPages.pinConfirmation.path,
            builder: (context, state) => PinConfirmationPage(transaction: transaction),
          ),
          GoRoute(
            path: AppPages.transactionResult.path,
            builder: (context, state) {
              final tx = state.extra as Transaction;
              return Scaffold(
                body: Text('Authorized Transaction Result: ${tx.transactionId}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          routerConfig: router,
        ),
      );

      // Tap '1', '2', '3', '4' (Correct PIN)
      await tapKeypadDigit(tester, '1');
      await tapKeypadDigit(tester, '2');
      await tapKeypadDigit(tester, '3');
      await tapKeypadDigit(tester, '4');
      await tester.pumpAndSettle();

      // Verify navigation to Transaction Result page
      expect(find.text('Authorized Transaction Result: tx_123'), findsOneWidget);
    });
  });
}
