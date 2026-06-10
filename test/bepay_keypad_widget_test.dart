import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/shared/widgets/bepay_keypad.dart';

void main() {
  group('BepayKeypad Widget Tests', () {
    testWidgets('renders all digits and handles digit/backspace taps', (tester) async {
      String tappedDigit = '';
      bool backspaceTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: BepayKeypad(
              onDigitTap: (digit) => tappedDigit = digit,
              onBackspaceTap: () => backspaceTapped = true,
              showDecimal: true,
            ),
          ),
        ),
      );

      // Verify digits 0-9 and decimal are rendered
      for (int i = 0; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }
      expect(find.text('.'), findsOneWidget);
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

      // Tap '5' and verify callback
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(tappedDigit, '5');

      // Tap '.' and verify callback
      await tester.tap(find.text('.'));
      await tester.pump();
      expect(tappedDigit, '.');

      // Tap backspace and verify callback
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(backspaceTapped, true);
    });

    testWidgets('hides decimal key when showDecimal is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: BepayKeypad(
              onDigitTap: (_) {},
              onBackspaceTap: () {},
              showDecimal: false,
            ),
          ),
        ),
      );

      expect(find.text('.'), findsNothing);
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('displays biometric fingerprint key when onBiometricTap is provided', (tester) async {
      bool biometricTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: BepayKeypad(
              onDigitTap: (_) {},
              onBackspaceTap: () {},
              showDecimal: true,
              onBiometricTap: () => biometricTapped = true,
            ),
          ),
        ),
      );

      // Decimals should be replaced by biometrics
      expect(find.text('.'), findsNothing);
      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);

      // Tap biometric key and verify callback
      await tester.tap(find.byIcon(Icons.fingerprint_rounded));
      await tester.pump();
      expect(biometricTapped, true);
    });
  });
}
