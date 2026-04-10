/// Error state shown when the BLE scan fails.
///
/// [ErrorView] displays a centred error icon, the [message] returned by
/// the BLE layer, and a [RetryButton] that invokes [onRetry].
library;

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../buttons/retry_button.dart';

class ErrorView extends StatelessWidget {
  /// Human-readable error description from the BLE layer.
  final String message;

  /// Called when the user taps the retry button.
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: IconTheme.of(context).size! * 2,
            color: AppColors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          RetryButton(onPressed: onRetry),
        ],
      ),
    );
  }
}
