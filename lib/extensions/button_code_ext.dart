/// Display metadata for the physical buttons on the OWON B41T.
///
/// [ButtonCodeDisplay] co-locates each button's label string and icon with
/// the [ButtonCode] enum itself, so [ControlPanel] can iterate over the codes
/// and retrieve presentation details without embedding parallel look-up tables
/// or hard-coded string literals.
library;

import 'package:flutter/material.dart';
import '../services/ble_service.dart';

extension ButtonCodeDisplay on ButtonCode {
  /// Short label shown on the control button (e.g. `'Hz/%'`, `'MAX/MIN'`).
  String get label => switch (this) {
        ButtonCode.hold => 'HOLD',
        ButtonCode.rel => 'REL',
        ButtonCode.range => 'RANGE',
        ButtonCode.hz => 'Hz/%',
        ButtonCode.max => 'MAX/MIN',
        ButtonCode.select => 'SELECT',
        ButtonCode.none => '',
        ButtonCode.all => '',
      };

  /// Icon that visually represents the button's action.
  IconData get icon => switch (this) {
        ButtonCode.hold => Icons.pause,
        ButtonCode.rel => Icons.exposure,
        ButtonCode.range => Icons.swap_vert,
        ButtonCode.hz => Icons.waves,
        ButtonCode.max => Icons.show_chart,
        ButtonCode.select => Icons.tune,
        ButtonCode.none => Icons.circle,
        ButtonCode.all => Icons.circle,
      };
}
