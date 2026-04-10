// OWON B41T BLE Protocol Parser
// Service: 0xFFF0
// Notify characteristic: 0xFFF4
// Packet: 6 bytes -> 3 x uint16 (little-endian)

import 'measurement_flag.dart';

export 'measurement_flag.dart';

enum MeasurementFunction {
  vDc,
  vAc,
  aDc,
  aAc,
  ohm,
  farad,
  hz,
  duty,
  tempC,
  tempF,
  voltsDiode,
  ohmsContinuity,
  hfe,
  ncv,
}

/// Display and classification properties for each measurement function.
///
/// Using a switch expression instead of parallel index-matched arrays means
/// the compiler enforces exhaustiveness: adding a new [MeasurementFunction]
/// value produces a compile error here until its properties are defined.
extension MeasurementFunctionInfo on MeasurementFunction {
  /// Short label shown in the function row (e.g. `'V DC'`, `'Ω'`).
  String get label => switch (this) {
        MeasurementFunction.vDc => 'V DC',
        MeasurementFunction.vAc => 'V AC',
        MeasurementFunction.aDc => 'A DC',
        MeasurementFunction.aAc => 'A AC',
        MeasurementFunction.ohm => 'Ω',
        MeasurementFunction.farad => 'F',
        MeasurementFunction.hz => 'Hz',
        MeasurementFunction.duty => 'Duty',
        MeasurementFunction.tempC => '°C',
        MeasurementFunction.tempF => '°F',
        MeasurementFunction.voltsDiode => 'Diode',
        MeasurementFunction.ohmsContinuity => 'Cont.',
        MeasurementFunction.hfe => 'hFE',
        MeasurementFunction.ncv => 'NCV',
      };

  /// SI unit symbol appended to the scale prefix in the value display.
  String get unit => switch (this) {
        MeasurementFunction.vDc => 'V',
        MeasurementFunction.vAc => 'V',
        MeasurementFunction.aDc => 'A',
        MeasurementFunction.aAc => 'A',
        MeasurementFunction.ohm => 'Ω',
        MeasurementFunction.farad => 'F',
        MeasurementFunction.hz => 'Hz',
        MeasurementFunction.duty => '%',
        MeasurementFunction.tempC => '°C',
        MeasurementFunction.tempF => '°F',
        MeasurementFunction.voltsDiode => 'V',
        MeasurementFunction.ohmsContinuity => 'Ω',
        MeasurementFunction.hfe => '',
        MeasurementFunction.ncv => '',
      };

  /// `true` for AC voltage and AC current modes.
  bool get isAc =>
      this == MeasurementFunction.vAc || this == MeasurementFunction.aAc;

  /// `true` for DC voltage and DC current modes.
  bool get isDc =>
      this == MeasurementFunction.vDc || this == MeasurementFunction.aDc;
}

const _scaleChars = ['%', 'n', 'μ', 'm', '', 'k', 'M', 'G'];

class MeasurementFlags {
  final bool hold;
  final bool rel;
  final bool auto;
  final bool lowBattery;
  final bool min;
  final bool max;
  final bool overload;
  final bool maxMin;

  const MeasurementFlags({
    this.hold = false,
    this.rel = false,
    this.auto = false,
    this.lowBattery = false,
    this.min = false,
    this.max = false,
    this.overload = false,
    this.maxMin = false,
  });

  factory MeasurementFlags.fromByte(int byte) {
    return MeasurementFlags(
      hold: (byte & (1 << 0)) != 0,
      rel: (byte & (1 << 1)) != 0,
      auto: (byte & (1 << 2)) != 0,
      lowBattery: (byte & (1 << 3)) != 0,
      min: (byte & (1 << 4)) != 0,
      max: (byte & (1 << 5)) != 0,
      overload: (byte & (1 << 6)) != 0,
      maxMin: (byte & (1 << 7)) != 0,
    );
  }

  /// Active flags in bit order as typed [MeasurementFlag] values.
  List<MeasurementFlag> get activeFlags {
    final result = <MeasurementFlag>[];
    if (hold) result.add(MeasurementFlag.hold);
    if (rel) result.add(MeasurementFlag.rel);
    if (auto) result.add(MeasurementFlag.auto);
    if (lowBattery) result.add(MeasurementFlag.lowBattery);
    if (min) result.add(MeasurementFlag.min);
    if (max) result.add(MeasurementFlag.max);
    if (overload) result.add(MeasurementFlag.overload);
    if (maxMin) result.add(MeasurementFlag.maxMin);
    return result;
  }
}

class Measurement {
  final MeasurementFunction function;
  final double? value;
  final bool isOverload;
  final MeasurementFlags flags;
  final int scaleIndex;
  final DateTime timestamp;

  const Measurement({
    required this.function,
    required this.value,
    required this.isOverload,
    required this.flags,
    required this.scaleIndex,
    required this.timestamp,
  });

  String get functionName => function.label;
  String get unit => function.unit;
  String get scaleChar => _scaleChars[scaleIndex];

  bool get isAc => function.isAc;
  bool get isDc => function.isDc;

  String get displayValue {
    if (isOverload || flags.overload) return 'OL';
    if (value == null) return '---';
    if (value!.isNaN || value!.isInfinite) return 'OL';
    return value!.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
  }

  String get displayUnit => '$scaleChar$unit';

  /// Parse a 6-byte BLE notification packet from the OWON B41T
  static Measurement? fromPacket(List<int> bytes) {
    if (bytes.length < 6) return null;

    // Mask each byte to 0xFF — on iOS flutter_blue_plus can return signed
    // bytes (e.g. 0x80 → -128), which would corrupt the word assembly.
    final d0 = (bytes[0] & 0xFF) | ((bytes[1] & 0xFF) << 8);
    final d1 = (bytes[2] & 0xFF) | ((bytes[3] & 0xFF) << 8);
    final d2 = (bytes[4] & 0xFF) | ((bytes[5] & 0xFF) << 8);

    final funcCode = (d0 >> 6) & 0xF;
    final scaleIndex = (d0 >> 3) & 0x7;
    final magnitude = d0 & 0x7;

    if (funcCode >= MeasurementFunction.values.length) return null;

    final function = MeasurementFunction.values[funcCode];
    final flags = MeasurementFlags.fromByte(d1);

    double? value;
    bool isOverload = magnitude == 7;

    if (!isOverload) {
      // d2 is sign-magnitude encoded: bit 15 = sign, bits 14–0 = absolute value.
      // This is NOT two's complement — 0x8000 is negative zero (i.e. 0.0).
      final isNegative = (d2 & 0x8000) != 0;
      final rawAbs = d2 & 0x7FFF;
      // Only apply the sign when the absolute value is non-zero; this prevents
      // -0.0 (from d2 == 0x8000) from rendering as "-0" in the display.
      value = (isNegative && rawAbs != 0 ? -rawAbs.toDouble() : rawAbs.toDouble()) / _pow10(magnitude);
    }

    return Measurement(
      function: function,
      value: value,
      isOverload: isOverload,
      flags: flags,
      scaleIndex: scaleIndex,
      timestamp: DateTime.now(),
    );
  }

  static double _pow10(int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= 10.0;
    }
    return result;
  }
}
