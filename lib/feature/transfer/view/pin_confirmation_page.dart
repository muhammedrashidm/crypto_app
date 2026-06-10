import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto_app/shared/di/injection.dart';
import 'package:crypto_app/feature/transfer/domain/entities/transaction.dart';
import '../bloc/pin_confirmation/pin_confirmation_bloc.dart';
import '../bloc/pin_confirmation/pin_confirmation_event.dart';
import '../bloc/pin_confirmation/pin_confirmation_state.dart';
import 'package:crypto_app/shared/theme/app_colors.dart';
import 'package:crypto_app/shared/theme/app_spacing.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';
import 'package:crypto_app/shared/widgets/bepay_keypad.dart';
import 'package:crypto_app/shared/widgets/pin_dots.dart';
import 'package:crypto_app/shared/navigation/app_pages.dart';

class PinConfirmationPage extends StatefulWidget {
  final Transaction transaction;

  const PinConfirmationPage({super.key, required this.transaction});

  @override
  State<PinConfirmationPage> createState() => _PinConfirmationPageState();
}

class _PinConfirmationPageState extends State<PinConfirmationPage> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late final PinConfirmationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<PinConfirmationBloc>();
    _bloc.add(InitPinConfirmationEvent(widget.transaction));
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider<PinConfirmationBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<PinConfirmationBloc, PinConfirmationState>(
            listener: (context, state) {
              if (state.status == PinConfirmationStatus.success) {
                context.go(AppPages.transactionResult.path, extra: widget.transaction);
              }
              if (state.pinError) {
                _shakeController.forward(from: 0.0);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Incorrect PIN. Try again.'),
                    backgroundColor: colorScheme.error,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isVerifying = state.status == PinConfirmationStatus.verifying;
              final isLockedOut = state.status == PinConfirmationStatus.lockedOut;
              final blockInputs = isVerifying || isLockedOut;

              return Stack(
                children: [
                  CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.marginMobile,
                            vertical: 16.0,
                          ),
                          child: Column(
                            children: [
                              const Spacer(),

                              // Title & Subtitle
                              Text(
                                'Security PIN',
                                style: textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Enter your PIN to confirm',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),

                              // Animated PIN Dots
                              AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  final double offset = state.pinError 
                                      ? (0.5 - (0.5 - _shakeController.value).abs()) * 20.0 * 
                                         (0.5 - _shakeController.value > 0 ? 1 : -1) 
                                      : 0.0;
                                  return Transform.translate(
                                    offset: Offset(offset, 0.0),
                                    child: PinDots(
                                      length: state.pin.length,
                                      hasError: state.pinError,
                                    ),
                                  );
                                },
                              ),
                              const Spacer(),

                              // Security Info / Lockout Box
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isLockedOut
                                    ? Container(
                                        key: const ValueKey('lockout_box'),
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: colorScheme.error.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                          border: Border.all(
                                            color: colorScheme.error.withValues(alpha: 0.5),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.lock_clock_outlined,
                                              color: colorScheme.error,
                                              size: 20.0,
                                            ),
                                            const SizedBox(width: 12.0),
                                            Expanded(
                                              child: Text(
                                                'Too many failed attempts. Locked out for ${state.lockoutSecondsRemaining}s.',
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: colorScheme.error,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        key: const ValueKey('security_box'),
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                          border: Border.all(
                                            color: AppColors.borderSubtle,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.security_outlined,
                                              color: colorScheme.primary,
                                              size: 20.0,
                                            ),
                                            const SizedBox(width: 12.0),
                                            Expanded(
                                              child: Text(
                                                'Your PIN ensures only you can authorize this transfer.',
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              const Spacer(),

                              // Keypad (no Max button shown, no decimal point)
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: blockInputs ? 0.4 : 1.0,
                                child: AbsorbPointer(
                                  absorbing: blockInputs,
                                  child: BepayKeypad(
                                    onDigitTap: (digit) {
                                      _bloc.add(EnterPinDigitEvent(digit));
                                    },
                                    onBackspaceTap: () {
                                      _bloc.add(DeletePinDigitEvent());
                                    },
                                    showDecimal: false,
                                    isRandomized: true,
                                    onBiometricTap: state.isBiometricsEnabled
                                        ? () => _bloc.add(const AuthenticateWithBiometricsEvent())
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Blocking loader during transaction verification
                  if (isVerifying)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
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
