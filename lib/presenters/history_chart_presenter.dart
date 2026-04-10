/// Presentation logic for the history line chart.
///
/// Instantiate with a measurement [history] and read [data] to obtain
/// normalised plot points and formatted Y-axis labels. [data] is `null` when
/// fewer than two valid readings are available. The resulting [ChartData] is
/// pure data — [_ChartPainter] only handles canvas drawing.
library;

import '../models/measurement.dart';

/// A single normalised data point for the chart.
///
/// [normalized] is clamped to [0, 1] so the painter never needs to clip.
typedef ChartPoint = ({double value, double normalized});

/// Pre-computed chart data derived from a measurement history.
class ChartData {
  /// Normalised plot points in history order (oldest → newest).
  final List<ChartPoint> points;

  /// Formatted label for the top of the Y axis (padded high bound).
  final String highLabel;

  /// Formatted label for the bottom of the Y axis (padded low bound).
  final String lowLabel;

  const ChartData({
    required this.points,
    required this.highLabel,
    required this.lowLabel,
  });
}

class HistoryChartPresenter {
  final List<Measurement> history;

  const HistoryChartPresenter(this.history);

  /// Returns [ChartData] from [history], or `null` when fewer than two valid
  /// (non-overload, non-null) readings are available.
  ChartData? get data {
    final valid = history
        .where((m) => m.value != null && !m.isOverload && !m.flags.overload)
        .toList();

    if (valid.length < 2) return null;

    final values = valid.map((m) => m.value!).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    final effectiveRange = range < 1e-10 ? 1.0 : range;
    final padding = effectiveRange * 0.1;
    final lo = minVal - padding;
    final hi = maxVal + padding;

    final ref = valid.last;
    String fmt(double v) => '${v.toStringAsFixed(2)}${ref.scaleChar}${ref.unit}';

    final points = valid.map((m) {
      final normalized = ((m.value! - lo) / (hi - lo)).clamp(0.0, 1.0);
      return (value: m.value!, normalized: normalized);
    }).toList();

    return ChartData(
      points: points,
      highLabel: fmt(hi),
      lowLabel: fmt(lo),
    );
  }
}
