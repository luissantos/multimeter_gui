/// Narrow vertical strip that collapses or expands the data sidebar.
///
/// The strip highlights on hover and shows a directional chevron icon
/// that reflects the current [open] state. Tapping calls [onTap] so the
/// parent can update its layout state.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';

class SidebarToggle extends StatefulWidget {
  /// Whether the sidebar is currently open.
  final bool open;

  /// Called when the user taps the strip to toggle the sidebar.
  final VoidCallback onTap;

  const SidebarToggle({super.key, required this.open, required this.onTap});

  @override
  State<SidebarToggle> createState() => _SidebarToggleState();
}

class _SidebarToggleState extends State<SidebarToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.open
              ? context.l10n.tooltipHideSidebar
              : context.l10n.tooltipShowSidebar,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 16,
            height: double.infinity,
            color: _hovered ? AppColors.bg4 : AppColors.bg2,
            child: Icon(
              widget.open ? Icons.chevron_right : Icons.chevron_left,
              size: 14,
              color: _hovered ? AppColors.dim8 : AppColors.dim3,
            ),
          ),
        ),
      ),
    );
  }
}
