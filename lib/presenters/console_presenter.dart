/// Presentation logic for a single console log row.
///
/// Instantiate with a [measurement] and read the formatted getters directly.
/// [_ConsoleLine] creates one per row in its [build] method and renders the
/// properties without any formatting code of its own.
library;

import '../models/measurement.dart';

class ConsolePresenter {
  final Measurement _measurement;

  const ConsolePresenter(this._measurement);

  /// HH:MM:SS.cs timestamp string.
  String get time {
    final ts = _measurement.timestamp;
    final hh = ts.hour.toString().padLeft(2, '0');
    final mm = ts.minute.toString().padLeft(2, '0');
    final ss = ts.second.toString().padLeft(2, '0');
    final cs = (ts.millisecond ~/ 10).toString().padLeft(2, '0');
    return '$hh:$mm:$ss.$cs';
  }

  /// Human-readable function name (e.g. "V DC").
  String get functionName => _measurement.functionName;

  /// Whether the reading is an overload.
  bool get isOverload => _measurement.isOverload || _measurement.flags.overload;

  /// Display value string; "OL" when [isOverload] is true.
  String get value => isOverload ? 'OL' : _measurement.displayValue;

  /// Scale-prefixed unit string (e.g. "mV").
  String get unit => _measurement.displayUnit;

  /// Active flag label strings (e.g. ["HOLD", "REL"]).
  List<String> get flagLabels =>
      _measurement.flags.activeFlags.map((f) => f.label).toList();
}
