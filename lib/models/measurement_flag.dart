/// Typed representation of a single active status flag from a BLE packet.
///
/// [MeasurementFlag] replaces the raw `List<String>` that
/// [MeasurementFlags.activeFlags] used to return, giving each flag a stable
/// identity and co-locating its display properties (label, badge colour) with
/// the type rather than scattering string comparisons across widgets.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum MeasurementFlag { hold, rel, auto, lowBattery, min, max, overload, maxMin }

extension MeasurementFlagDisplay on MeasurementFlag {
  /// Short uppercase label shown in the badge (e.g. `'BAT'`, `'MAX/MIN'`).
  String get label => switch (this) {
        MeasurementFlag.hold => 'HOLD',
        MeasurementFlag.rel => 'REL',
        MeasurementFlag.auto => 'AUTO',
        MeasurementFlag.lowBattery => 'BAT',
        MeasurementFlag.min => 'MIN',
        MeasurementFlag.max => 'MAX',
        MeasurementFlag.overload => 'OL',
        MeasurementFlag.maxMin => 'MAX/MIN',
      };

  /// Badge accent colour. Low-battery uses orange; all other flags use yellow.
  Color get badgeColor =>
      this == MeasurementFlag.lowBattery ? AppColors.orange : AppColors.yellow;
}
