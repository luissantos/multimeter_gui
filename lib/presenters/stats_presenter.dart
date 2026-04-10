/// Presentation logic for the session statistics panel.
///
/// Instantiate with a measurement [history] and read [data] to obtain
/// pre-formatted min / average / max label strings. [data] is `null` when
/// no valid (non-overload, non-null) readings exist in [history].
library;

import '../models/measurement.dart';

/// Pre-formatted statistics derived from a measurement history.
class StatsData {
  final String min;
  final String avg;
  final String max;

  const StatsData({required this.min, required this.avg, required this.max});
}

class StatsPresenter {
  final List<Measurement> history;

  const StatsPresenter(this.history);

  /// Computes [StatsData] from [history], or `null` if there are no valid
  /// (non-overload, non-null) readings.
  StatsData? get data {
    final valid = history
        .where((m) => m.value != null && !m.isOverload && !m.flags.overload)
        .toList();

    if (valid.isEmpty) return null;

    final values = valid.map((m) => m.value!).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final avg = values.fold(0.0, (a, b) => a + b) / values.length;

    final ref = valid.last;
    String fmt(double v) => '${v.toStringAsFixed(3)} ${ref.scaleChar}${ref.unit}';

    return StatsData(min: fmt(min), avg: fmt(avg), max: fmt(max));
  }
}
