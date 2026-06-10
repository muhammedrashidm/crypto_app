import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_app/shared/di/injection.dart';
import 'package:crypto_app/feature/transfer/domain/entities/contact.dart';
import 'package:crypto_app/feature/transfer/domain/entities/create_transaction.dart';
import '../bloc/recipient_entry/recipient_entry_bloc.dart';
import '../bloc/recipient_entry/recipient_entry_event.dart';
import '../bloc/recipient_entry/recipient_entry_state.dart';
import 'package:crypto_app/shared/theme/app_colors.dart';
import 'package:crypto_app/shared/theme/app_spacing.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';
import 'package:crypto_app/shared/navigation/app_pages.dart';

class RecipientEntryPage extends StatefulWidget {
  final CreateTransaction createTx;

  const RecipientEntryPage({super.key, required this.createTx});

  @override
  State<RecipientEntryPage> createState() => _RecipientEntryPageState();
}

class _RecipientEntryPageState extends State<RecipientEntryPage> {
  Timer? _debounce;
  late final RecipientEntryBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<RecipientEntryBloc>()..add(const LoadRecipientsEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _bloc.add(LoadRecipientsEvent(query: query));
      }
    });
  }

  Future<void> _launchQrScanner(BuildContext context) async {
    final result = await context.push<String?>(AppPages.qrScanner.path);
    if (result != null && mounted) {
      _searchController.text = result;
      _onSearchChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider<RecipientEntryBloc>.value(
      value: _bloc,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.push<Contact?>(AppPages.addContact.path);
            if (result != null && context.mounted) {
              final updatedTx = widget.createTx.copyWith(recipient: result);
              context.push(AppPages.amountEntry.path, extra: updatedTx);
              _bloc.add(const LoadRecipientsEvent());
            }
          },
          backgroundColor: colorScheme.primary,
          child: const Icon(Icons.person_add, color: Colors.white),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              context.pop();
            },
          ),
          title: Text(
            'Send To',
            style:
                textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipient Search Input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.search, color: colorScheme.primary),
                              hintText: 'Search recipient name, ID, or address',
                              hintStyle: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.defaultRadius),
                                borderSide:
                                    const BorderSide(color: AppColors.borderSubtle),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.defaultRadius),
                                borderSide:
                                    const BorderSide(color: AppColors.borderSubtle),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Material(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius:
                              BorderRadius.circular(AppRadius.defaultRadius),
                          child: InkWell(
                            onTap: () => _launchQrScanner(context),
                            borderRadius:
                                BorderRadius.circular(AppRadius.defaultRadius),
                            child: Container(
                              height: 56.0,
                              width: 56.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borderSubtle),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.defaultRadius),
                              ),
                              child: Icon(
                                Icons.qr_code_scanner,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  BlocBuilder<RecipientEntryBloc, RecipientEntryState>(
                    builder: (context, state) {
                      if (state.validationError != null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.marginMobile,
                            vertical: 8.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    state.validationError!,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Header title (Recent Recipients or Search Results)
                  BlocBuilder<RecipientEntryBloc, RecipientEntryState>(
                    builder: (context, state) {
                      final title = state.query.isEmpty
                          ? 'Recent Recipients'
                          : 'Search Results';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.marginMobile,
                          vertical: 12.0,
                        ),
                        child: Text(
                          title,
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),

                  Expanded(
                    child: BlocBuilder<RecipientEntryBloc, RecipientEntryState>(
                      builder: (context, state) {
                        if (state.status == RecipientEntryStatus.loading) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary),
                            ),
                          );
                        }

                        final displayList = state.query.isEmpty
                            ? state.recentRecipients
                            : state.searchResults;

                        if (displayList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                state.query.isEmpty
                                    ? 'No recent recipients.'
                                    : 'No matching contacts found.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.marginMobile,
                            vertical: 8.0,
                          ),
                          child: Column(
                            children: [
                              ...displayList.map((Contact recipient) {
                                final isExternalAddress =
                                    recipient.contactType == 'External Address';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  decoration: BoxDecoration(
                                    color: isExternalAddress
                                        ? AppColors.warning.withValues(alpha: 0.05)
                                        : colorScheme.surfaceContainerLow,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                    border: Border.all(
                                      color: isExternalAddress
                                          ? AppColors.warning.withValues(alpha: 0.5)
                                          : AppColors.borderSubtle,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isExternalAddress
                                              ? AppColors.warning
                                                  .withValues(alpha: 0.15)
                                              : colorScheme
                                                  .surfaceContainerHigh,
                                          child: Icon(
                                            isExternalAddress
                                                ? Icons.warning_amber_rounded
                                                : (recipient.contactType
                                                        .contains('bepay')
                                                    ? Icons.alternate_email
                                                    : (recipient.contactType
                                                            .contains('Wallet')
                                                        ? Icons.account_balance_wallet
                                                        : (recipient.contactType
                                                                .contains('Phone')
                                                            ? Icons.phone
                                                            : (recipient
                                                                    .contactType
                                                                    .contains('Email')
                                                                ? Icons.email
                                                                : Icons.person)))),
                                            color: isExternalAddress
                                                ? AppColors.warning
                                                : colorScheme.primary,
                                            size: 20.0,
                                          ),
                                        ),
                                        title: Text(
                                          isExternalAddress
                                              ? 'Manual Wallet Address'
                                              : recipient.name,
                                          style: textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(
                                          isExternalAddress
                                              ? recipient.address
                                              : recipient.contactType,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.4),
                                            fontSize: 12.0,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14.0,
                                          color: colorScheme.onSurface,
                                        ),
                                        onTap: () {
                                          final updatedTx = widget.createTx
                                              .copyWith(recipient: recipient);
                                          context.push(
                                              AppPages.amountEntry.path,
                                              extra: updatedTx);
                                        },
                                      ),
                                      if (isExternalAddress)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            bottom: 12.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.info_outline,
                                                color: AppColors.warning,
                                                size: 14.0,
                                              ),
                                              const SizedBox(width: 8.0),
                                              Expanded(
                                                child: Text(
                                                  'Warning: This recipient is an external wallet address not in your contacts. Ensure you verify the address carefully before proceeding.',
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: AppColors.warning,
                                                    fontSize: 11.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Invite & Earn Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border:
                          Border.all(color: AppColors.borderSubtle, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: colorScheme.primary,
                              size: 24.0,
                            ),
                            const SizedBox(width: 12.0),
                            Text(
                              'Invite & Earn',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "Send assets to friends who aren't on bepay yet and unlock rewards.",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
