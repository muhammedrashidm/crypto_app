import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_app/shared/di/injection.dart';
import 'package:crypto_app/shared/theme/app_colors.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';
import 'package:crypto_app/shared/theme/app_spacing.dart';
import 'package:crypto_app/shared/widgets/bepay_button.dart';
import '../bloc/add_contact_bloc.dart';
import '../bloc/add_contact_event.dart';
import '../bloc/add_contact_state.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  late final AddContactBloc _bloc;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<AddContactBloc>();
    _nameController.addListener(() {
      _bloc.add(ContactNameChanged(_nameController.text));
    });
    _idController.addListener(() {
      _bloc.add(ContactIdChanged(_idController.text));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider<AddContactBloc>.value(
      value: _bloc,
      child: BlocConsumer<AddContactBloc, AddContactState>(
        listener: (context, state) {
          if (state.isSuccess && state.createdContact != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.createdContact!.name} added successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            );
            // Return the newly created contact to the Recipient page
            context.pop(state.createdContact);
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Add Contact',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
                            Text(
                              'Create a new contact by entering their name and an address identifier.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 24.0),

                            // Contact Name
                            Text(
                              'Contact Name',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _nameController,
                              style: textTheme.bodyLarge,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Enter name (e.g. Nikhil)',
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                                errorText: state.nameError,
                                filled: true,
                                fillColor: colorScheme.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),

                            // Contact ID / Address
                            Text(
                              'Contact ID / Address',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _idController,
                              style: textTheme.bodyLarge,
                              decoration: InputDecoration(
                                hintText: 'bepayID, wallet address, email or phone',
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                                errorText: state.contactIdError,
                                filled: true,
                                fillColor: colorScheme.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                                ),
                              ),
                            ),

                            // Helper Indicator for Detected Type
                            if (state.detectedType != 'Unknown' && state.contactId.isNotEmpty && state.contactIdError == null) ...[
                              const SizedBox(height: 12.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getIconForType(state.detectedType),
                                      color: colorScheme.primary,
                                      size: 16.0,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      'Detected Type: ${state.detectedType}',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24.0),

                            // Sample Values Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 20.0),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        'Valid Address Examples',
                                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  _buildExampleRow('bepayID', 'nikhil@bepay', textTheme, colorScheme),
                                  const Divider(height: 16.0, color: AppColors.borderSubtle),
                                  _buildExampleRow('Wallet', '0x742d35Cc6634C0532925a3b844Bc454e4438f44e', textTheme, colorScheme),
                                  const Divider(height: 16.0, color: AppColors.borderSubtle),
                                  _buildExampleRow('Email', 'user@example.com', textTheme, colorScheme),
                                  const Divider(height: 16.0, color: AppColors.borderSubtle),
                                  _buildExampleRow('Phone', '+919999999999', textTheme, colorScheme),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    BepayButton(
                      text: 'Save Contact',
                      isLoading: state.isSubmitting,
                      onPressed: state.isValid
                          ? () {
                              context.read<AddContactBloc>().add(const AddContactSubmitted());
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.contains('bepay')) return Icons.alternate_email;
    if (type.contains('Wallet')) return Icons.account_balance_wallet;
    if (type.contains('Phone')) return Icons.phone;
    if (type.contains('Email')) return Icons.email;
    return Icons.person;
  }

  Widget _buildExampleRow(String label, String value, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _idController.text = value;
                },
                child: Text(
                  'Use Example',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          SelectableText(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
