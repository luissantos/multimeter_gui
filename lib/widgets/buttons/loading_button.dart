/// A generic [ElevatedButton] that replaces its label with a spinner while
/// an async operation is running.
///
/// Pass [isLoading] from the parent's state together with a synchronous
/// [onPressed]. When [isLoading] is `true` the button is disabled and shows
/// a [CircularProgressIndicator]; when `false` it shows [label].
///
/// Background colour, shape, and text style are inherited from
/// [AppTheme]'s [ElevatedButtonThemeData].
library;

import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  /// Text label shown when the button is idle.
  final String label;

  /// Whether to show a loading spinner instead of [label].
  /// The button is disabled while loading.
  final bool isLoading;

  /// Called when the button is tapped and not loading.
  final VoidCallback? onPressed;

  const LoadingButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
