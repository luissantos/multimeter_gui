/// Connect button used in the BLE device list.
///
/// Shows a [CircularProgressIndicator] while a connection is in progress and
/// disables itself until the attempt completes. OWON-compatible devices
/// receive a green background; non-OWON devices receive a navy background.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';

class ConnectButton extends StatelessWidget {
  /// Whether the target device is an OWON-compatible multimeter.
  /// Controls the background colour of the button.
  final bool isOwon;

  /// Whether a BLE connection attempt is currently in progress.
  /// Disables the button and shows a spinner when `true`.
  final bool isConnecting;

  /// Called when the user taps Connect and [isConnecting] is `false`.
  final VoidCallback onConnect;

  const ConnectButton({
    super.key,
    required this.isOwon,
    required this.isConnecting,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isConnecting ? null : onConnect,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOwon ? AppColors.greenMid : AppColors.navy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isConnecting
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(context.l10n.buttonConnect),
    );
  }
}
