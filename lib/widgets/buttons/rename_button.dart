/// AppBar action button that opens the device-rename dialog.
///
/// Rendered as a dim edit icon so it is visible but unobtrusive next to
/// the device name in the title bar.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';

class RenameButton extends StatelessWidget {
  /// Called when the user taps the button.
  final VoidCallback onPressed;

  const RenameButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.edit, color: AppColors.dim8),
      tooltip: context.l10n.tooltipRenameDevice,
    );
  }
}
