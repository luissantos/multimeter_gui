/// AppBar action button that starts or stops a BLE scan.
///
/// Shows a [CircularProgressIndicator] and the scanning label while
/// [isScanning] is `true`; shows a refresh icon and the scan label otherwise.
/// Tapping always calls [onPressed] — the parent decides whether that maps
/// to start or stop.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';

class ScanButton extends StatelessWidget {
  /// Whether a scan is currently running.
  final bool isScanning;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  const ScanButton({
    super.key,
    required this.isScanning,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: isScanning
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.cyan,
              ),
            )
          : const Icon(Icons.refresh, color: AppColors.cyan),
      label: Text(
        isScanning ? context.l10n.buttonScanning : context.l10n.buttonScan,
        style: const TextStyle(color: AppColors.cyan),
      ),
    );
  }
}
