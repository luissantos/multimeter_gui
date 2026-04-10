/// Panel of hardware-button shortcuts for the OWON B41T multimeter.
///
/// Renders a labelled group of [ControlButton]s that map to physical buttons
/// on the device. The panel is decoupled from [MultimeterProvider]: the
/// parent supplies [onButton] and decides how to route the [ButtonCode] to
/// the BLE service.
///
/// Button labels and icons are sourced from [ButtonCodeDisplay] extensions on
/// [ButtonCode], keeping presentation metadata out of this widget.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../extensions/button_code_ext.dart';
import '../../services/ble_service.dart';
import '../../theme/app_colors.dart';
import 'control_button.dart';

/// The ordered set of buttons shown in the control panel.
const _panelButtons = [
  ButtonCode.hold,
  ButtonCode.rel,
  ButtonCode.range,
  ButtonCode.hz,
  ButtonCode.max,
  ButtonCode.select,
];

class ControlPanel extends StatelessWidget {
  /// Called whenever the user taps a button. The [ButtonCode] identifies
  /// which physical button to simulate.
  final void Function(ButtonCode) onButton;

  const ControlPanel({super.key, required this.onButton});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.controlsPanelLabel,
            style: const TextStyle(
              color: AppColors.dim5,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final button in _panelButtons)
                ControlButton(
                  label: button.label,
                  icon: button.icon,
                  onPressed: () => onButton(button),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
