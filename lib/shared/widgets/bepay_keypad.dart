import 'package:flutter/material.dart';

class BepayKeypad extends StatefulWidget {
  final Function(String) onDigitTap;
  final VoidCallback onBackspaceTap;
  final bool showDecimal;
  final bool isRandomized;
  final VoidCallback? onBiometricTap;

  const BepayKeypad({
    super.key,
    required this.onDigitTap,
    required this.onBackspaceTap,
    this.showDecimal = true,
    this.isRandomized = false,
    this.onBiometricTap,
  });

  @override
  State<BepayKeypad> createState() => _BepayKeypadState();
}

class _BepayKeypadState extends State<BepayKeypad> {
  late final List<String> _row1;
  late final List<String> _row2;
  late final List<String> _row3;
  late final String _bottomDigit;

  @override
  void initState() {
    super.initState();
    if (widget.isRandomized) {
      final List<String> digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']..shuffle();
      _row1 = digits.sublist(0, 3);
      _row2 = digits.sublist(3, 6);
      _row3 = digits.sublist(6, 9);
      _bottomDigit = digits[9];
    } else {
      _row1 = ['1', '2', '3'];
      _row2 = ['4', '5', '6'];
      _row3 = ['7', '8', '9'];
      _bottomDigit = '0';
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return Column(
      children: [
        _buildRow(buildContext, _row1),
        const SizedBox(height: 12.0),
        _buildRow(buildContext, _row2),
        const SizedBox(height: 12.0),
        _buildRow(buildContext, _row3),
        const SizedBox(height: 12.0),
        _buildBottomRow(buildContext),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) => Expanded(child: _buildKey(context, val))).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: widget.onBiometricTap != null
              ? _buildActionKeyIcon(
                  context,
                  Icons.fingerprint_rounded,
                  widget.onBiometricTap!,
                )
              : (widget.showDecimal
                  ? _buildKey(context, '.')
                  : const SizedBox.shrink()),
        ),
        Expanded(child: _buildKey(context, _bottomDigit)),
        Expanded(
          child: _buildActionKeyIcon(
            context,
            Icons.backspace_outlined,
            widget.onBackspaceTap,
          ),
        ),
      ],
    );
  }

  Widget _buildKey(BuildContext context, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onDigitTap(value),
        borderRadius: BorderRadius.circular(40.0),
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          height: 72.0,
          alignment: Alignment.center,
          child: Text(
            value,
            style: textTheme.displayMedium,
          ),
        ),
      ),
    );
  }


  Widget _buildActionKeyIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40.0),
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        child: Container(
          height: 72.0,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 24.0,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
