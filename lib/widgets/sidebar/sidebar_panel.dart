/// Right-hand sidebar panel with tabbed HISTORY and CONSOLE views plus a
/// session [StatsPanel] below the tab content.
///
/// Owns its own [TabController] so the parent screen does not need a
/// [TickerProvider] solely for the tabs. The [onClear] callback is forwarded
/// to [ClearButton]; [MultimeterScreen] wires it to
/// [MultimeterProvider.clearHistory].
///
/// Tab colours, indicator and label style are inherited from
/// [AppTheme]'s [TabBarTheme].
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../models/measurement.dart';
import '../../theme/app_colors.dart';
import '../buttons/clear_button.dart';
import '../data/history_chart.dart';
import '../data/console_view.dart';
import '../stats/stats_panel.dart';

class SidebarPanel extends StatefulWidget {
  /// Full measurement history passed through to [HistoryChart],
  /// [ConsoleView] and [StatsPanel].
  final List<Measurement> history;

  /// Called when the user taps the Clear button.
  final VoidCallback onClear;

  const SidebarPanel({
    super.key,
    required this.history,
    required this.onClear,
  });

  @override
  State<SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends State<SidebarPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                // Colours and label style come from AppTheme.tabBarTheme.
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.tabHistory),
                  Tab(text: l10n.tabConsole),
                ],
              ),
            ),
            ClearButton(onPressed: widget.onClear),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            padding: const EdgeInsets.all(12),
            child: TabBarView(
              controller: _tabController,
              children: [
                HistoryChart(history: widget.history),
                ConsoleView(history: widget.history),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        StatsPanel(history: widget.history),
      ],
    );
  }
}
