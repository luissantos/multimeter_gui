/// A single labelled icon button for sending hardware commands to the
/// OWON B41T multimeter.
///
/// Used by [ControlPanel] to build the row of instrument controls. Visual
/// styling (colour, border, padding, font size) is inherited from
/// [AppTheme]'s [OutlinedButtonThemeData] so no inline style is needed here.
library;

import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ControlButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      // Icon size scales with the app-level zoom factor.
      icon: Icon(icon, size: IconTheme.of(context).size! * (14 / 24)),
      label: Text(label),
    );
  }
}
