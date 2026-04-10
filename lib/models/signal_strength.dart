/// Qualitative signal-strength category derived from an RSSI dBm value.
///
/// Widgets use [RssiSignalStrength.signalStrength] to convert a raw integer
/// RSSI into a [SignalStrength] and then call [SignalStrengthColor.color] to
/// obtain the corresponding display colour — keeping threshold logic out of
/// widget `build` methods.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SignalStrength { strong, moderate, weak }

extension SignalStrengthColor on SignalStrength {
  /// Green for strong, yellow for moderate, red for weak.
  Color get color => switch (this) {
        SignalStrength.strong => AppColors.green,
        SignalStrength.moderate => AppColors.yellow,
        SignalStrength.weak => AppColors.red,
      };
}

/// Converts a raw RSSI dBm integer into a [SignalStrength] category.
extension RssiSignalStrength on int {
  /// > −60 dBm → [SignalStrength.strong]
  /// > −80 dBm → [SignalStrength.moderate]
  /// ≤ −80 dBm → [SignalStrength.weak]
  SignalStrength get signalStrength => this > -60
      ? SignalStrength.strong
      : this > -80
          ? SignalStrength.moderate
          : SignalStrength.weak;
}
