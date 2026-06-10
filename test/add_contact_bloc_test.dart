import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:crypto_app/shared/error/failure.dart';
import 'package:crypto_app/feature/transfer/bloc/add_contact/add_contact_bloc.dart';
import 'package:crypto_app/feature/transfer/bloc/add_contact/add_contact_event.dart';
import 'package:crypto_app/feature/transfer/bloc/add_contact/add_contact_state.dart';
import 'package:crypto_app/feature/transfer/domain/entities/contact.dart';
import 'package:crypto_app/feature/transfer/domain/repositories/transfer_repository.dart';
import 'package:crypto_app/feature/transfer/domain/usecases/add_contact_usecase.dart';

class FakeTransferRepository implements TransferRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAddContactUseCase extends AddContactUseCase {
  Either<Failure, Unit> result = const Right(unit);

  FakeAddContactUseCase() : super(FakeTransferRepository());

  @override
  Future<Either<Failure, Unit>> call(Contact contact) async {
    return result;
  }
}

void main() {
  late AddContactBloc bloc;
  late FakeAddContactUseCase fakeAddContactUseCase;

  setUp(() {
    fakeAddContactUseCase = FakeAddContactUseCase();
    bloc = AddContactBloc(fakeAddContactUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is correct', () {
    expect(bloc.state.name, '');
    expect(bloc.state.contactId, '');
    expect(bloc.state.nameError, null);
    expect(bloc.state.contactIdError, null);
    expect(bloc.state.detectedType, 'Unknown');
    expect(bloc.state.isSubmitting, false);
    expect(bloc.state.isSuccess, false);
  });

  group('Validation tests', () {
    test('Name changes update state and validate correctly', () async {
      bloc.add(const ContactNameChanged('John'));
      await expectLater(
        bloc.stream,
        emits(const AddContactState(name: 'John', nameError: null)),
      );

      bloc.add(const ContactNameChanged(' '));
      await expectLater(
        bloc.stream,
        emits(const AddContactState(name: ' ', nameError: 'Name cannot be empty.')),
      );
    });

    test('bepayID validation and type detection', () async {
      bloc.add(const ContactIdChanged('nikhil@bepay'));
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: 'nikhil@bepay',
          contactIdError: null,
          detectedType: 'Verified bepayID',
        )),
      );

      bloc.add(const ContactIdChanged('ab@bepay')); // Too short
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: 'ab@bepay',
          contactIdError: 'Invalid bepayID. Minimum 3 alphanumeric characters before @bepay.',
          detectedType: 'Unknown',
        )),
      );
    });

    test('Wallet address validation and type detection', () async {
      bloc.add(const ContactIdChanged('0x742d35Cc6634C0532925a3b844Bc454e4438f44e'));
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
          contactIdError: null,
          detectedType: 'Ethereum Network',
        )),
      );

      bloc.add(const ContactIdChanged('0x123')); // Invalid hex count
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: '0x123',
          contactIdError: 'Invalid wallet address. Must start with 0x followed by 40 hex characters.',
          detectedType: 'Unknown',
        )),
      );
    });

    test('Email address validation and type detection', () async {
      bloc.add(const ContactIdChanged('user@example.com'));
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: 'user@example.com',
          contactIdError: null,
          detectedType: 'External Contact (Email)',
        )),
      );

      bloc.add(const ContactIdChanged('user@com')); // Invalid format
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: 'user@com',
          contactIdError: 'Invalid email address format.',
          detectedType: 'Unknown',
        )),
      );
    });

    test('Phone number validation and type detection', () async {
      bloc.add(const ContactIdChanged('+919999999999'));
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: '+919999999999',
          contactIdError: null,
          detectedType: 'External Contact (Phone)',
        )),
      );

      bloc.add(const ContactIdChanged('+123')); // Too short
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: '+123',
          contactIdError: 'Invalid phone number length. Must be 7 to 15 digits.',
          detectedType: 'Unknown',
        )),
      );

      bloc.add(const ContactIdChanged('919999999999')); // Missing +
      await expectLater(
        bloc.stream,
        emits(const AddContactState(
          contactId: '919999999999',
          contactIdError: 'Phone number must start with + followed by country code.',
          detectedType: 'Unknown',
        )),
      );
    });
  });

  group('Submission tests', () {
    test('Successful submission emits isSuccess', () async {
      bloc.add(const ContactNameChanged('Nikhil'));
      bloc.add(const ContactIdChanged('nikhil@bepay'));

      await bloc.stream.firstWhere((state) => state.isValid);

      bloc.add(const AddContactSubmitted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AddContactState(
            name: 'Nikhil',
            contactId: 'nikhil@bepay',
            detectedType: 'Verified bepayID',
            isSubmitting: true,
          ),
          const AddContactState(
            name: 'Nikhil',
            contactId: 'nikhil@bepay',
            detectedType: 'Verified bepayID',
            isSubmitting: false,
            isSuccess: true,
            createdContact: Contact(
              name: 'Nikhil',
              address: 'nikhil@bepay',
              bepayId: 'nikhil@bepay',
              contactType: 'Verified bepayID',
            ),
          ),
        ]),
      );
    });

    test('Failed submission emits errorMessage', () async {
      fakeAddContactUseCase.result = Left(ServerFailure('Connection failed'));

      bloc.add(const ContactNameChanged('Nikhil'));
      bloc.add(const ContactIdChanged('nikhil@bepay'));

      await bloc.stream.firstWhere((state) => state.isValid);

      bloc.add(const AddContactSubmitted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AddContactState(
            name: 'Nikhil',
            contactId: 'nikhil@bepay',
            detectedType: 'Verified bepayID',
            isSubmitting: true,
          ),
          const AddContactState(
            name: 'Nikhil',
            contactId: 'nikhil@bepay',
            detectedType: 'Verified bepayID',
            isSubmitting: false,
            isSuccess: false,
            errorMessage: 'Connection failed',
          ),
        ]),
      );
    });
  });
}
