/// Session statistics panel showing minimum, average and maximum readings.
///
/// Delegates all computation to [StatsPresenter.compute], which filters the
/// history to valid readings and returns pre-formatted label strings.
/// Renders nothing ([SizedBox.shrink]) when no valid readings are available.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../models/measurement.dart';
import '../../presenters/stats_presenter.dart';
import '../../theme/app_colors.dart';
import 'stat_item.dart';

class StatsPanel extends StatelessWidget {
  final StatsPresenter _presenter;

  StatsPanel({super.key, required List<Measurement> history})
      : _presenter = StatsPresenter(history);

  @override
  Widget build(BuildContext context) {
    final stats = _presenter.data;
    if (stats == null) return const SizedBox.shrink();

    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatItem(label: l10n.statMin, value: stats.min, color: AppColors.cyan),
          StatItem(label: l10n.statAvg, value: stats.avg, color: AppColors.yellow),
          StatItem(label: l10n.statMax, value: stats.max, color: AppColors.orange),
        ],
      ),
    );
  }
}
