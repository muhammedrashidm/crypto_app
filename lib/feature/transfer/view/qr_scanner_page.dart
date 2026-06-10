import 'package:flutter/material.dart';
import 'package:crypto_app/shared/theme/app_colors.dart';
import 'package:crypto_app/shared/theme/app_radius.dart';
import 'package:crypto_app/shared/theme/app_spacing.dart';

class QrScannerPage extends StatefulWidget {
  final bool animate;

  const QrScannerPage({
    super.key,
    this.animate = true,
  });

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scannerAnimation;
  final TextEditingController _customInputController = TextEditingController();
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.animate) {
      _animationController.repeat(reverse: true);
    }

    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customInputController.dispose();
    super.dispose();
  }

  void _onScanResult(String result) {
    if (result.trim().isNotEmpty) {
      Navigator.of(context).pop(result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Align the QR code inside the frame to scan',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 30),

              // Mock Camera View Finder
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30, width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        // Background simulator lines
                        Container(color: Colors.grey[900]),
                        
                        // Corner borders (HUD Look)
                        ..._buildCornerIndicators(),

                        // Laser Scanner animation
                        AnimatedBuilder(
                          animation: _scannerAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _scannerAnimation.value * 250,
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Simulation Controls
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'QR Scanner Simulator',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap an option below to simulate scanning a wallet address or bepayID.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Quick buttons
                    ElevatedButton.icon(
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text('Scan Wallet (0x742D...)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        foregroundColor: colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _onScanResult('0x742D35cc6634C0532925a3B844BC454E4438f44E'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.alternate_email),
                      label: const Text('Scan bepayID (nikhil@bepay)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        foregroundColor: colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _onScanResult('nikhil@bepay'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.account_balance_wallet_rounded),
                      label: const Text('Scan Custom Hash (0x98b5...)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        foregroundColor: colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _onScanResult('0x98b50e2ddc9943efb387052637738f61765c3de'),
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.borderSubtle),
                    const SizedBox(height: 12),

                    // Custom Code Scan
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customInputController,
                            style: textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Enter custom address to scan',
                              hintStyle: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHigh,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _onScanResult(_customInputController.text),
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerIndicators() {
    return [
      Positioned(
        top: 10,
        left: 10,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 3),
              left: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
      Positioned(
        top: 10,
        right: 10,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 3),
              right: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 10,
        left: 10,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 3),
              left: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 10,
        right: 10,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 3),
              right: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
    ];
  }
}
