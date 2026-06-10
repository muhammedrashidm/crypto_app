// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:crypto_app/feature/home/bloc/home_bloc.dart' as _i389;
import 'package:crypto_app/feature/home/data/datasources/home_remote_data_source.dart'
    as _i844;
import 'package:crypto_app/feature/home/data/repositories/biometric_repository_impl.dart'
    as _i524;
import 'package:crypto_app/feature/home/data/repositories/home_repository_impl.dart'
    as _i288;
import 'package:crypto_app/feature/home/domain/repositories/biometric_repository.dart'
    as _i865;
import 'package:crypto_app/feature/home/domain/repositories/home_repository.dart'
    as _i556;
import 'package:crypto_app/feature/home/domain/usecases/enable_biometrics_usecase.dart'
    as _i867;
import 'package:crypto_app/feature/home/domain/usecases/get_assets_usecase.dart'
    as _i813;
import 'package:crypto_app/feature/home/domain/usecases/get_biometrics_settings_usecase.dart'
    as _i449;
import 'package:crypto_app/feature/home/domain/usecases/update_biometrics_prompt_dismissed_usecase.dart'
    as _i80;
import 'package:crypto_app/feature/transfer/bloc/add_contact/add_contact_bloc.dart'
    as _i335;
import 'package:crypto_app/feature/transfer/bloc/amount_entry/amount_entry_bloc.dart'
    as _i78;
import 'package:crypto_app/feature/transfer/bloc/pin_confirmation/pin_confirmation_bloc.dart'
    as _i47;
import 'package:crypto_app/feature/transfer/bloc/recipient_entry/recipient_entry_bloc.dart'
    as _i944;
import 'package:crypto_app/feature/transfer/bloc/review_transaction/review_transaction_bloc.dart'
    as _i359;
import 'package:crypto_app/feature/transfer/data/datasources/transfer_remote_data_source.dart'
    as _i310;
import 'package:crypto_app/feature/transfer/data/repositories/transfer_repository_impl.dart'
    as _i595;
import 'package:crypto_app/feature/transfer/domain/repositories/transfer_repository.dart'
    as _i692;
import 'package:crypto_app/feature/transfer/domain/usecases/add_contact_usecase.dart'
    as _i214;
import 'package:crypto_app/feature/transfer/domain/usecases/complete_transaction_usecase.dart'
    as _i972;
import 'package:crypto_app/feature/transfer/domain/usecases/create_transaction_usecase.dart'
    as _i339;
import 'package:crypto_app/feature/transfer/domain/usecases/get_max_coin_available_usecase.dart'
    as _i467;
import 'package:crypto_app/feature/transfer/domain/usecases/get_recent_recipients_usecase.dart'
    as _i675;
import 'package:crypto_app/feature/transfer/domain/usecases/get_recent_transactions_usecase.dart'
    as _i180;
import 'package:crypto_app/feature/transfer/domain/usecases/verify_pin_usecase.dart'
    as _i421;
import 'package:crypto_app/shared/data/repositories/currency_repository.dart'
    as _i870;
import 'package:crypto_app/shared/data/repositories/currency_repository_impl.dart'
    as _i472;
import 'package:crypto_app/shared/di/register_module.dart' as _i782;
import 'package:crypto_app/shared/services/shared_pref_service.dart' as _i567;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i567.SharedPrefService>(
        () => _i567.SharedPrefService(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i310.TransferRemoteDataSource>(() =>
        _i310.TransferRemoteDataSourceImpl(gh<_i567.SharedPrefService>()));
    gh.lazySingleton<_i865.BiometricRepository>(
        () => _i524.BiometricRepositoryImpl(gh<_i567.SharedPrefService>()));
    gh.lazySingleton<_i867.EnableBiometricsUseCase>(
        () => _i867.EnableBiometricsUseCase(gh<_i865.BiometricRepository>()));
    gh.lazySingleton<_i449.GetBiometricsSettingsUseCase>(() =>
        _i449.GetBiometricsSettingsUseCase(gh<_i865.BiometricRepository>()));
    gh.lazySingleton<_i80.UpdateBiometricsPromptDismissedUseCase>(() =>
        _i80.UpdateBiometricsPromptDismissedUseCase(
            gh<_i865.BiometricRepository>()));
    gh.lazySingleton<_i870.CurrencyRepository>(
        () => _i472.CurrencyRepositoryImpl(gh<_i567.SharedPrefService>()));
    gh.lazySingleton<_i844.HomeRemoteDataSource>(
        () => _i844.HomeRemoteDataSourceImpl(gh<_i567.SharedPrefService>()));
    gh.lazySingleton<_i556.HomeRepository>(
        () => _i288.HomeRepositoryImpl(gh<_i844.HomeRemoteDataSource>()));
    gh.lazySingleton<_i692.TransferRepository>(() =>
        _i595.TransferRepositoryImpl(gh<_i310.TransferRemoteDataSource>()));
    gh.lazySingleton<_i214.AddContactUseCase>(
        () => _i214.AddContactUseCase(gh<_i692.TransferRepository>()));
    gh.lazySingleton<_i972.CompleteTransactionUseCase>(
        () => _i972.CompleteTransactionUseCase(gh<_i692.TransferRepository>()));
    gh.lazySingleton<_i339.CreateTransactionUseCase>(
        () => _i339.CreateTransactionUseCase(gh<_i692.TransferRepository>()));
    gh.lazySingleton<_i467.GetMaxCoinAvailableUseCase>(
        () => _i467.GetMaxCoinAvailableUseCase(gh<_i692.TransferRepository>()));
    gh.lazySingleton<_i675.GetRecentRecipientsUseCase>(
        () => _i675.GetRecentRecipientsUseCase(gh<_i692.TransferRepository>()));
    gh.lazySingleton<_i180.GetRecentTransactionsUseCase>(() =>
        _i180.GetRecentTransactionsUseCase(gh<_i692.TransferRepository>()));
    gh.lazySingleton<_i421.VerifyPinUseCase>(
        () => _i421.VerifyPinUseCase(gh<_i692.TransferRepository>()));
    gh.factory<_i335.AddContactBloc>(
        () => _i335.AddContactBloc(gh<_i214.AddContactUseCase>()));
    gh.factory<_i359.ReviewTransactionBloc>(() => _i359.ReviewTransactionBloc(
          gh<_i339.CreateTransactionUseCase>(),
          gh<_i870.CurrencyRepository>(),
        ));
    gh.factory<_i78.AmountEntryBloc>(() => _i78.AmountEntryBloc(
          gh<_i467.GetMaxCoinAvailableUseCase>(),
          gh<_i870.CurrencyRepository>(),
        ));
    gh.factory<_i47.PinConfirmationBloc>(() => _i47.PinConfirmationBloc(
          gh<_i421.VerifyPinUseCase>(),
          gh<_i972.CompleteTransactionUseCase>(),
          gh<_i567.SharedPrefService>(),
          gh<_i865.BiometricRepository>(),
        ));
    gh.lazySingleton<_i813.GetAssetsUseCase>(
        () => _i813.GetAssetsUseCase(gh<_i556.HomeRepository>()));
    gh.factory<_i944.RecipientEntryBloc>(
        () => _i944.RecipientEntryBloc(gh<_i675.GetRecentRecipientsUseCase>()));
    gh.factory<_i389.HomeBloc>(() => _i389.HomeBloc(
          gh<_i813.GetAssetsUseCase>(),
          gh<_i449.GetBiometricsSettingsUseCase>(),
          gh<_i80.UpdateBiometricsPromptDismissedUseCase>(),
          gh<_i867.EnableBiometricsUseCase>(),
          gh<_i870.CurrencyRepository>(),
          gh<_i180.GetRecentTransactionsUseCase>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i782.RegisterModule {}
