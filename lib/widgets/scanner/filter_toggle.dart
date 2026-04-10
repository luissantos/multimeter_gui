/// AppBar toggle for the "compatible devices only" scan filter.
///
/// [FilterToggle] renders a filter icon, a label, and a [Switch] in a
/// compact row suitable for placement in an [AppBar]'s actions list.
/// Active state is coloured green; inactive state uses the dim palette.
/// The [Switch] styling is inherited from [AppTheme]'s [switchTheme].
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';

class FilterToggle extends StatelessWidget {
  /// Whether the compatible-only filter is currently active.
  final bool value;

  /// Called when the user flips the switch.
  final ValueChanged<bool> onChanged;

  const FilterToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = value ? AppColors.green : AppColors.dim5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: IconTheme.of(context).size! * (16 / 24),
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            context.l10n.compatibleOnly,
            style: TextStyle(fontSize: 13, color: color),
          ),
          const SizedBox(width: 6),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
