/// Full-width retry button shown on BLE error screens.
///
/// Background colour and shape are inherited from [AppTheme]'s
/// [ElevatedButtonThemeData].
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';

class RetryButton extends StatelessWidget {
  /// Called when the user taps the button.
  final VoidCallback onPressed;

  const RetryButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(context.l10n.buttonRetry),
    );
  }
}
