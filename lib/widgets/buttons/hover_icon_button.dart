/// A hover-sensitive icon button with an animated container decoration.
///
/// [HoverIconButton] shows [icon] in the idle state and [activeIcon] (or
/// [icon] if not provided) when [isActive] is `true`. Colours transition
/// between the idle, hover, and active states. On hover the button gains a
/// visible background fill and border, giving tactile feedback without taking
/// permanent space in the layout.
///
/// The tooltip wait duration is inherited from [AppTheme]'s [TooltipTheme].
library;

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HoverIconButton extends StatefulWidget {
  /// Icon shown when the button is idle (not active, not hovered).
  final IconData icon;

  /// Icon shown when [isActive] is `true`. Defaults to [icon] when omitted.
  final IconData? activeIcon;

  /// Whether the button is in its active / toggled-on state.
  final bool isActive;

  /// Tooltip message shown on long-hover.
  final String tooltip;

  /// Called when the user taps the button.
  final VoidCallback onTap;

  const HoverIconButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
    this.activeIcon,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final displayIcon =
        widget.isActive ? (widget.activeIcon ?? widget.icon) : widget.icon;

    final iconColor = widget.isActive
        ? AppColors.green
        : _hovered
            ? AppColors.dimA
            : AppColors.dim5;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: IconTheme.of(context).size! * (22 / 24),
            height: IconTheme.of(context).size! * (22 / 24),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.border
                  : AppColors.bg0.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _hovered ? AppColors.dim4 : Colors.transparent,
                width: 1,
              ),
            ),
            child: Icon(
              displayIcon,
              size: IconTheme.of(context).size! * (14 / 24),
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
