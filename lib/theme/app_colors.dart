/// All color constants for the OWON B41T application.
///
/// Every [Color] literal in the codebase should reference one of these
/// constants so that the entire palette lives in one place. Semantic names
/// (e.g. [green], [red]) indicate the primary role of each color; they are
/// used in [AppTheme] and referenced directly in widgets that need colors
/// not expressible through [ThemeData].
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Primary accent — green
  // ---------------------------------------------------------------------------

  /// Bright green: measurement normal state, success indicators, active tabs.
  static const green = Color(0xFF00FF88);

  /// Mid green: confirm / primary action buttons.
  static const greenMid = Color(0xFF00AA55);

  /// Dark green tint: OWON-device tile background.
  static const greenDark = Color(0xFF0A1A0F);

  // ---------------------------------------------------------------------------
  // Secondary accent — cyan
  // ---------------------------------------------------------------------------

  /// Cyan: secondary accent, function labels, scan actions, AC mode badge.
  static const cyan = Color(0xFF00C8FF);

  /// Dark cyan: control-button border.
  static const cyanDark = Color(0xFF1A3A4A);

  /// Very dark cyan: control-button background.
  static const cyanDeep = Color(0xFF050E14);

  // ---------------------------------------------------------------------------
  // Warning / status
  // ---------------------------------------------------------------------------

  /// Yellow: flags (HOLD, REL, MAX/MIN), average statistic.
  static const yellow = Color(0xFFFFCC00);

  /// Orange: BAT flag, maximum statistic.
  static const orange = Color(0xFFFF6600);

  /// Red: overload readings, errors, disconnect action.
  static const red = Color(0xFFFF4444);

  // ---------------------------------------------------------------------------
  // Backgrounds (darkest → lightest)
  // ---------------------------------------------------------------------------

  /// Deepest background — scaffold / main window.
  static const bg0 = Color(0xFF0D0D0D);

  /// Panel / card background.
  static const bg1 = Color(0xFF0A0A0A);

  /// App bar, sidebar strip, device list tiles.
  static const bg2 = Color(0xFF141414);

  /// Dialog background.
  static const bg3 = Color(0xFF1A1A1A);

  /// Hover / highlight surface.
  static const bg4 = Color(0xFF1E1E1E);

  /// Chart grid lines, switch inactive track.
  static const bg5 = Color(0xFF222222);

  /// Very dark navy — non-OWON connect-button background.
  static const navy = Color(0xFF1A1A2E);

  // ---------------------------------------------------------------------------
  // Borders
  // ---------------------------------------------------------------------------

  /// Standard panel and dialog border.
  static const border = Color(0xFF2A2A2A);

  // ---------------------------------------------------------------------------
  // Muted text / icon scale
  // ---------------------------------------------------------------------------

  /// Very dim — empty-state icons, secondary copy.
  static const dim3 = Color(0xFF333333);

  /// Dim — timestamp text, hover borders.
  static const dim4 = Color(0xFF444444);

  /// Medium dim — section labels, placeholder / hint text.
  static const dim5 = Color(0xFF555555);

  /// Light dim — secondary icons (edit, window toggle).
  static const dim8 = Color(0xFF888888);

  /// Light — secondary body text, function name labels.
  static const dimA = Color(0xFFAAAAAA);
}
