import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/feature/transfer/view/qr_scanner_page.dart';

void main() {
  group('QrScannerPage Widget Tests', () {
    testWidgets('renders QR Scanner Page title, simulated options, and elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const QrScannerPage(animate: false),
        ),
      );

      // Verify page title and scanner description
      expect(find.text('Scan QR Code'), findsOneWidget);
      expect(find.text('Align the QR code inside the frame to scan'), findsOneWidget);
      
      // Verify laser scanner animation elements / mock camera viewfinder borders
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));

      // Verify simulator card elements
      expect(find.text('QR Scanner Simulator'), findsOneWidget);
      expect(find.text('Scan Wallet (0x742D...)'), findsOneWidget);
      expect(find.text('Scan bepayID (nikhil@bepay)'), findsOneWidget);
      expect(find.text('Scan Custom Hash (0x98b5...)'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('simulated scan button pops back with correct address value', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? scanResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  scanResult = await Navigator.push<String?>(
                    context,
                    MaterialPageRoute(builder: (_) => const QrScannerPage(animate: false)),
                  );
                },
                child: const Text('Open Scanner'),
              );
            },
          ),
        ),
      );

      // Tap to open scanner
      await tester.tap(find.text('Open Scanner'));
      await tester.pumpAndSettle();

      // Verify scanner is opened
      expect(find.text('Scan QR Code'), findsOneWidget);

      // Tap on the wallet scan simulator button
      await tester.tap(find.text('Scan Wallet (0x742D...)'));
      await tester.pumpAndSettle();

      // Verify screen popped and returned the simulated address hash
      expect(find.text('Scan QR Code'), findsNothing);
      expect(scanResult, '0x742D35cc6634C0532925a3B844BC454E4438f44E');
    });

    testWidgets('custom simulated address input submits and pops back', (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? scanResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  scanResult = await Navigator.push<String?>(
                    context,
                    MaterialPageRoute(builder: (_) => const QrScannerPage(animate: false)),
                  );
                },
                child: const Text('Open Scanner'),
              );
            },
          ),
        ),
      );

      // Tap to open scanner
      await tester.tap(find.text('Open Scanner'));
      await tester.pumpAndSettle();

      // Enter a custom scanned result address
      await tester.enterText(find.byType(TextField), '0xScannedCustomAddressHashValue');
      await tester.pump();

      // Tap send simulation button
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Verify screen popped and returned the scanned value
      expect(find.text('Scan QR Code'), findsNothing);
      expect(scanResult, '0xScannedCustomAddressHashValue');
    });
  });
}
