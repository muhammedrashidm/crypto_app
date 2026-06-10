import 'package:crypto_app/shared/navigation/app_pages.dart';
import 'package:crypto_app/shared/theme/app_colors.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';
import 'package:crypto_app/shared/theme/app_spacing.dart';
import 'package:crypto_app/shared/widgets/bepay_button.dart';
import 'package:crypto_app/shared/widgets/bepay_secondary_button.dart';
import 'package:crypto_app/shared/widgets/token_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_app/feature/transfer/domain/entities/create_transaction.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  @override
  void initState() {
    super.initState();
    // Dispatch LoadHomeData event
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state is HomeLoaded) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } else if (state.biometricsEnabledSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometrics Enabled successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            final colorScheme = Theme.of(context).colorScheme;

            if (state is HomeLoading || state is HomeInitial) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              );
            }

            if (state is HomeLoaded) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isWideScreen = screenWidth >= 600;
              final isSmallScreen = screenWidth < 320;
              final double horizontalPadding = isSmallScreen ? 12.0 : AppSpacing.marginMobile;

              if (isWideScreen) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960.0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Total Balance & Primary Actions & Biometrics Lock
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(context, state, false),
                                const SizedBox(height: 24.0),
                                _buildBalanceSection(context, state, false),
                                const SizedBox(height: 24.0),
                                _buildSendButton(context, state),
                                if (state.showBiometricsPrompt) ...[
                                  const SizedBox(height: 24.0),
                                  _buildBiometricsCard(context, state, false),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 32.0),
                          // Right Column: Assets List
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAssetsSection(context, state),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, state, isSmallScreen),
                    const SizedBox(height: 24.0),
                    _buildBalanceSection(context, state, isSmallScreen),
                    const SizedBox(height: 24.0),
                    _buildSendButton(context, state),
                    const SizedBox(height: 24.0),
                    if (state.showBiometricsPrompt) ...[
                      _buildBiometricsCard(context, state, isSmallScreen),
                      const SizedBox(height: 24.0),
                    ],
                    _buildAssetsSection(context, state),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeLoaded state, bool isSmallScreen) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'bepay',
          style: (isSmallScreen ? textTheme.headlineMedium : textTheme.headlineLarge)?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.history,
                color: colorScheme.onSurface,
              ),
              onPressed: () {
                context.push(AppPages.recentTransactions.path, extra: state.transactions);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: colorScheme.onSurface,
              ),
              onPressed: () {
                _showSettingsBottomSheet(context, state.selectedCurrency);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceSection(BuildContext context, HomeLoaded state, bool isSmallScreen) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Balance',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8.0),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '${state.currencySymbol}${state.totalBalance.toStringAsFixed(2)}',
            style: isSmallScreen
                ? textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.displayLarge,
          ),
        ),
        const SizedBox(height: 4.0),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            const Icon(
              Icons.arrow_upward,
              size: 16.0,
              color: AppColors.success,
            ),
            Text(
              '+2.4% (24h)',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 4.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Network Status',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Container(
              width: 8.0,
              height: 8.0,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context, HomeLoaded state) {
    return BepayButton(
      text: 'Send',
      onPressed: () {
        _showAssetSelectionBottomSheet(context, state.assets);
      },
    );
  }

  Widget _buildBiometricsCard(BuildContext context, HomeLoaded state, bool isSmallScreen) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fingerprint,
                color: colorScheme.primary,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Secure Your Assets',
                  style: (isSmallScreen ? textTheme.titleMedium : textTheme.bodyLarge)?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            'Your private keys never leave this device. Enable Biometrics for extra protection.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16.0),
          LayoutBuilder(
            builder: (context, buttonConstraints) {
              if (buttonConstraints.maxWidth < 250) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BepayButton(
                      text: 'Enable',
                      onPressed: () {
                        context.read<HomeBloc>().add(EnableBiometrics());
                      },
                    ),
                    const SizedBox(height: 8.0),
                    BepaySecondaryButton(
                      text: 'Dismiss',
                      onPressed: () {
                        context.read<HomeBloc>().add(DismissBiometricsPrompt());
                      },
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: BepaySecondaryButton(
                        text: 'Dismiss',
                        onPressed: () {
                          context.read<HomeBloc>().add(DismissBiometricsPrompt());
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: BepayButton(
                        text: 'Enable',
                        onPressed: () {
                          context.read<HomeBloc>().add(EnableBiometrics());
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsSection(BuildContext context, HomeLoaded state) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assets',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        ...state.assets.map((asset) => TokenCard(
              symbol: asset.symbol,
              name: asset.name,
              amount: asset.amount.toString(),
              value: '${state.currencySymbol}${asset.fiatValue.toStringAsFixed(2)}',
              network: asset.network,
              onTap: () {},
              onSendTap: () {
                context.push(
                  AppPages.recipientEntry.path,
                  extra: CreateTransaction(
                    coinSymbol: asset.symbol,
                    network: asset.network,
                  ),
                );
              },
            )),
      ],
    );
  }

  void _showAssetSelectionBottomSheet(BuildContext context, List<dynamic> assets) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = context.read<HomeBloc>().state as HomeLoaded;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
            ),
            border: Border.all(color: AppColors.borderSubtle, width: 1.0),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 320 ? 12.0 : AppSpacing.marginMobile,
            vertical: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle indicator
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Select Asset',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Choose an asset to transfer',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20.0),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: assets.map((asset) {
                      return TokenCard(
                        symbol: asset.symbol,
                        name: asset.name,
                        amount: asset.amount.toString(),
                        value: '${state.currencySymbol}${asset.fiatValue.toStringAsFixed(2)}',
                        network: asset.network,
                        onTap: () {
                          Navigator.pop(context);
                          context.push(
                            AppPages.recipientEntry.path,
                            extra: CreateTransaction(
                              coinSymbol: asset.symbol,
                              network: asset.network,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context, String currentCurrency) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
            ),
            border: Border.all(color: AppColors.borderSubtle, width: 1.0),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 320 ? 12.0 : AppSpacing.marginMobile,
            vertical: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Settings',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Select Primary Currency',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              ...['USD', 'INR', 'GBP', 'EUR'].map((currency) {
                final isSelected = currency == currentCurrency;
                return ListTile(
                  title: Text(
                    currency,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<HomeBloc>().add(ChangeCurrency(currency));
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
