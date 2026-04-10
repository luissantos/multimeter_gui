/// AppBar action button that disconnects from the connected BLE device.
///
/// Styled in red to convey a destructive / terminating action.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';

class DisconnectButton extends StatelessWidget {
  /// Called when the user taps the button.
  final VoidCallback onPressed;

  const DisconnectButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.bluetooth_disabled, color: AppColors.red),
      label: Text(
        context.l10n.buttonDisconnect,
        style: const TextStyle(color: AppColors.red),
      ),
    );
  }
}
