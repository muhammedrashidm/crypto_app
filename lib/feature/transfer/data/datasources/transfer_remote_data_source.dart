import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../shared/services/shared_pref_service.dart';
import '../../../home/data/models/crypto_asset_model.dart';
import '../models/contact_model.dart';
import '../models/transaction_model.dart';
import '../../../../shared/utils/coin_formatter.dart';

abstract class TransferRemoteDataSource {
  Future<List<ContactModel>> getRecentRecipients({String? query});
  
  Future<String> getMaxCoinAvailable({
    required String coinSymbol,
    required String network,
  });

  Future<TransactionModel> createTransaction({
    required ContactModel recipient,
    required String amount,
    required String fee,
    required String coinSymbol,
    required String network,
    String? memo,
  });

  Future<bool> verifyPin({required String pin});

  Future<void> completeTransaction(TransactionModel transaction);

  Future<List<TransactionModel>> getTransactions();

  Future<void> addContact(ContactModel contact);
}

@LazySingleton(as: TransferRemoteDataSource)
class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final SharedPrefService _sharedPrefService;
  List<ContactModel>? _mockContacts;

  TransferRemoteDataSourceImpl(this._sharedPrefService);

  List<ContactModel> get _contacts {
    if (_mockContacts != null) return _mockContacts!;
    
    // Check if contacts are saved in SharedPreferences
    final savedContactsJson = _sharedPrefService.getString('contacts');
    if (savedContactsJson != null && savedContactsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(savedContactsJson);
        _mockContacts = decoded.map((e) => ContactModel.fromJson(e as Map<String, dynamic>)).toList();
        return _mockContacts!;
      } catch (_) {
        // Fall back to generation if parsing fails
      }
    }
    
    // If empty, generate the 100 contacts
    _mockContacts = [];
    final firstNames = ['Alex', 'Ben', 'Charlie', 'David', 'Emma', 'Frank', 'Grace', 'Henry', 'Ivy', 'Jack', 'Kate', 'Leo', 'Mia', 'Noah', 'Olivia', 'Paul', 'Quinn', 'Ruby', 'Sam', 'Toby', 'Uma', 'Victor', 'Will', 'Xavier', 'Yara', 'Zane'];
    final lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Miller', 'Davis', 'Garcia', 'Rodriguez', 'Wilson', 'Martinez', 'Anderson', 'Taylor', 'Thomas', 'Hernandez', 'Moore', 'Martin', 'Jackson', 'Thompson', 'White'];
    
    for (int i = 1; i <= 100; i++) {
      final firstName = firstNames[i % firstNames.length];
      final lastName = lastNames[i % lastNames.length];
      final name = '$firstName $lastName';
      
      final typeIndex = i % 4;
      if (typeIndex == 0) {
        // bepayID
        final username = '${firstName.toLowerCase()}${lastName.toLowerCase()}$i';
        _mockContacts!.add(ContactModel(
          name: name,
          bepayId: '$username@bepay',
          address: '$username@bepay',
          contactType: 'Verified bepayID',
        ));
      } else if (typeIndex == 1) {
        // Wallet Address
        final hex = (i * 987654321).toRadixString(16).padLeft(40, '0');
        _mockContacts!.add(ContactModel(
          name: '$name (Wallet)',
          bepayId: '',
          address: '0x$hex',
          contactType: 'Ethereum Network',
        ));
      } else if (typeIndex == 2) {
        // Email
        final email = '${firstName.toLowerCase()}.$i@example.com';
        _mockContacts!.add(ContactModel(
          name: name,
          bepayId: '',
          address: email,
          contactType: 'External Contact (Email)',
        ));
      } else {
        // Phone
        final phone = '+9199999${i.toString().padLeft(5, '0')}';
        _mockContacts!.add(ContactModel(
          name: name,
          bepayId: '',
          address: phone,
          contactType: 'External Contact (Phone)',
        ));
      }
    }
    
    // Save generated contacts to SharedPreferences
    final contactsJson = jsonEncode(_mockContacts!.map((c) => c.toJson()).toList());
    _sharedPrefService.setString('contacts', contactsJson);
    
    return _mockContacts!;
  }

  @override
  Future<void> addContact(ContactModel contact) async {
    // Simulate remote network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Load contacts to ensure cache is populated
    final currentContacts = _contacts;
    
    // Prepend the new contact
    currentContacts.insert(0, contact);
    
    // Save to SharedPreferences
    final contactsJson = jsonEncode(currentContacts.map((c) => c.toJson()).toList());
    await _sharedPrefService.setString('contacts', contactsJson);
  }

  bool _isValidWalletAddress(String query) {
    final clean = query.trim();
    if (!clean.startsWith('0x')) return false;
    final hexPart = clean.substring(2);
    if (hexPart.length != 40) return false;
    final hexRegExp = RegExp(r'^[a-fA-F0-9]+$');
    return hexRegExp.hasMatch(hexPart);
  }

  @override
  Future<List<ContactModel>> getRecentRecipients({String? query}) async {
    // Simulate remote network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (query == null || query.trim().isEmpty) {
      // Fetch dynamic recent recipients from transaction history
      final history = await getTransactions();
      
      // Sort by timestamp descending
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      final List<ContactModel> recent = [];
      final Set<String> addedAddresses = {};
      
      for (final tx in history) {
        final address = tx.recipientAddress;
        if (!addedAddresses.contains(address.toLowerCase())) {
          addedAddresses.add(address.toLowerCase());
          
          String contactType = 'External Contact';
          if (address.endsWith('@bepay')) {
            contactType = 'Verified bepayID';
          } else if (address.startsWith('0x')) {
            contactType = tx.networkName;
          } else if (address.contains('@')) {
            contactType = 'External Contact (Email)';
          } else if (address.startsWith('+')) {
            contactType = 'External Contact (Phone)';
          }
          
          recent.add(ContactModel(
            name: tx.recipientName,
            bepayId: address.endsWith('@bepay') ? address : '',
            address: address,
            contactType: contactType,
          ));
          
          if (recent.length >= 3) break;
        }
      }
      
      // Fallback to initial mock list if history is empty
      if (recent.isEmpty) {
        return const [
          ContactModel(
            name: 'nikhil@bepay',
            bepayId: 'nikhil@bepay',
            address: 'nikhil@bepay',
            contactType: 'Verified bepayID',
          ),
          ContactModel(
            name: '0x742d...f44e',
            bepayId: '',
            address: '0x742D35cc6634C0532925a3B844BC454E4438f44E',
            contactType: 'Ethereum Network',
          ),
          ContactModel(
            name: 'user@example.com',
            bepayId: '',
            address: 'user@example.com',
            contactType: 'External Contact',
          ),
        ];
      }
      return recent;
    }

    final lowercaseQuery = query.trim().toLowerCase();
    
    // Check if query is a valid wallet address format
    final isValidWallet = _isValidWalletAddress(query);
    
    // Filter the 100 mock contacts
    final results = _contacts.where((contact) {
      return contact.name.toLowerCase().contains(lowercaseQuery) ||
          contact.address.toLowerCase().contains(lowercaseQuery) ||
          contact.bepayId.toLowerCase().contains(lowercaseQuery);
    }).toList();

    // If query is a valid wallet address but not found in mock contacts, add transient contact
    if (isValidWallet) {
      final exists = results.any((c) => c.address.toLowerCase() == lowercaseQuery);
      if (!exists) {
        results.insert(0, ContactModel(
          name: query.trim(),
          bepayId: '',
          address: query.trim(),
          contactType: 'External Address',
        ));
      }
    }

    return results;
  }

  @override
  Future<String> getMaxCoinAvailable({
    required String coinSymbol,
    required String network,
  }) async {
    // Simulate remote network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    final assetsJson = _sharedPrefService.getString('crypto_assets');
    if (assetsJson != null) {
      final List<dynamic> decoded = jsonDecode(assetsJson);
      final assets = decoded.map((e) => CryptoAssetModel.fromJson(e as Map<String, dynamic>)).toList();
      final asset = assets.firstWhere(
        (a) => a.symbol.toLowerCase() == coinSymbol.toLowerCase() &&
               a.network.toLowerCase() == network.toLowerCase(),
        orElse: () => CryptoAssetModel(
          id: 'temp',
          symbol: coinSymbol,
          name: coinSymbol,
          amount: 0.0,
          fiatValue: 0.0,
          network: network,
        ),
      );
      return asset.amount.toString();
    }
    return '0.0';
  }

  @override
  Future<TransactionModel> createTransaction({
    required ContactModel recipient,
    required String amount,
    required String fee,
    required String coinSymbol,
    required String network,
    String? memo,
  }) async {
    // Simulate remote network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final doubleAmt = double.tryParse(amount) ?? 0.0;
    final doubleFee = double.tryParse(fee) ?? 0.0;
    final doubleTotal = doubleAmt + doubleFee;

    // Determine simulated transaction status
    String status = 'success';
    if (amount.endsWith('.88')) {
      status = 'pending';
    } else if (amount.endsWith('.99')) {
      status = 'failed';
    } else {
      // Mocked API response determines status: e.g. 75% success, 15% pending, 10% failed
      final random = DateTime.now().microsecondsSinceEpoch % 100;
      if (random < 10) {
        status = 'failed';
      } else if (random < 25) {
        status = 'pending';
      } else {
        status = 'success';
      }
    }

    return TransactionModel(
      recipientName: recipient.name,
      recipientAddress: recipient.address,
      networkName: network,
      amount: amount,
      fee: fee,
      total: CoinFormatter.formatAmount(doubleTotal, coinSymbol),
      transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      coinSymbol: coinSymbol,
      memo: memo,
      status: status,
    );
  }

  @override
  Future<bool> verifyPin({required String pin}) async {
    // Simulate remote network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return pin == '1234';
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final historyJson = _sharedPrefService.getString('transaction_history');
    if (historyJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> completeTransaction(TransactionModel transaction) async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Deduct amount from assets only if the transaction did not fail
    if (transaction.status != 'failed') {
      final assetsJson = _sharedPrefService.getString('crypto_assets');
      if (assetsJson != null) {
        final List<dynamic> decoded = jsonDecode(assetsJson);
        final assets = decoded.map((e) => CryptoAssetModel.fromJson(e as Map<String, dynamic>)).toList();
        
        final updatedAssets = assets.map((asset) {
          if (asset.symbol.toLowerCase() == transaction.coinSymbol.toLowerCase() &&
              asset.network.toLowerCase() == transaction.networkName.toLowerCase()) {
            final txAmount = double.tryParse(transaction.amount) ?? 0.0;
            final newAmount = (asset.amount - txAmount).clamp(0.0, double.infinity);
            double newFiatValue = 0.0;
            if (asset.amount > 0.0) {
              newFiatValue = newAmount * (asset.fiatValue / asset.amount);
            }
            return CryptoAssetModel(
              id: asset.id,
              symbol: asset.symbol,
              name: asset.name,
              amount: newAmount,
              fiatValue: newFiatValue,
              network: asset.network,
            );
          }
          return asset;
        }).toList();

        final updatedAssetsJson = jsonEncode(updatedAssets.map((e) => e.toJson()).toList());
        await _sharedPrefService.setString('crypto_assets', updatedAssetsJson);
      }
    }

    // 2. Save transaction to history
    final List<TransactionModel> history = await getTransactions();
    history.add(transaction);

    final updatedHistoryJson = jsonEncode(history.map((e) => e.toJson()).toList());
    await _sharedPrefService.setString('transaction_history', updatedHistoryJson);
  }
}
