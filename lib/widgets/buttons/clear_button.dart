/// Inline text button that clears the measurement history.
///
/// Styled with a dim colour to keep visual weight low next to the tab bar.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';

class ClearButton extends StatelessWidget {
  /// Called when the user taps the button.
  final VoidCallback onPressed;

  const ClearButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        context.l10n.buttonClear,
        style: const TextStyle(color: AppColors.dim5, fontSize: 12),
      ),
    );
  }
}
