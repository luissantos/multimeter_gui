import 'package:flutter_test/flutter_test.dart';
import 'package:multimeter_gui/models/measurement.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a 6-byte packet from its three little-endian uint16 words.
List<int> packet(int d0, int d1, int d2) => [
      d0 & 0xFF,
      (d0 >> 8) & 0xFF,
      d1 & 0xFF,
      (d1 >> 8) & 0xFF,
      d2 & 0xFF,
      (d2 >> 8) & 0xFF,
    ];

/// Build d0 from its three logical fields.
int d0Word({required int funcCode, required int scaleIndex, required int magnitude}) =>
    (funcCode << 6) | (scaleIndex << 3) | magnitude;

void main() {
  // =========================================================================
  // MeasurementFlags.fromByte
  // =========================================================================
  group('MeasurementFlags.fromByte', () {
    test('all bits clear → no flags set', () {
      final f = MeasurementFlags.fromByte(0x00);
      expect(f.hold, isFalse);
      expect(f.rel, isFalse);
      expect(f.auto, isFalse);
      expect(f.lowBattery, isFalse);
      expect(f.min, isFalse);
      expect(f.max, isFalse);
      expect(f.overload, isFalse);
      expect(f.maxMin, isFalse);
    });

    test('all bits set → all flags set', () {
      final f = MeasurementFlags.fromByte(0xFF);
      expect(f.hold, isTrue);
      expect(f.rel, isTrue);
      expect(f.auto, isTrue);
      expect(f.lowBattery, isTrue);
      expect(f.min, isTrue);
      expect(f.max, isTrue);
      expect(f.overload, isTrue);
      expect(f.maxMin, isTrue);
    });

    test('individual bits map to correct flags', () {
      expect(MeasurementFlags.fromByte(1 << 0).hold, isTrue);
      expect(MeasurementFlags.fromByte(1 << 1).rel, isTrue);
      expect(MeasurementFlags.fromByte(1 << 2).auto, isTrue);
      expect(MeasurementFlags.fromByte(1 << 3).lowBattery, isTrue);
      expect(MeasurementFlags.fromByte(1 << 4).min, isTrue);
      expect(MeasurementFlags.fromByte(1 << 5).max, isTrue);
      expect(MeasurementFlags.fromByte(1 << 6).overload, isTrue);
      expect(MeasurementFlags.fromByte(1 << 7).maxMin, isTrue);
    });
  });

  group('MeasurementFlags.activeFlags', () {
    test('empty list when no flags are set', () {
      expect(MeasurementFlags.fromByte(0x00).activeFlags, isEmpty);
    });

    test('returns flags in bit order', () {
      final f = MeasurementFlags.fromByte(0xFF);
      expect(f.activeFlags, [
        MeasurementFlag.hold,
        MeasurementFlag.rel,
        MeasurementFlag.auto,
        MeasurementFlag.lowBattery,
        MeasurementFlag.min,
        MeasurementFlag.max,
        MeasurementFlag.overload,
        MeasurementFlag.maxMin,
      ]);
    });

    test('AUTO flag (bit 2)', () {
      expect(MeasurementFlags.fromByte(0x04).activeFlags, [MeasurementFlag.auto]);
    });
  });

  // =========================================================================
  // Measurement.fromPacket — input validation
  // =========================================================================
  group('fromPacket — input validation', () {
    test('returns null for empty list', () {
      expect(Measurement.fromPacket([]), isNull);
    });

    test('returns null for fewer than 6 bytes', () {
      expect(Measurement.fromPacket([0x23, 0xF0, 0x04, 0x00, 0xE3]), isNull);
    });

    test('returns null for unknown function code', () {
      // funcCode = 15 (0xF) → out of range; set via bits 9-6 of d0
      final d0 = (15 << 6) | (4 << 3) | 3; // funcCode=15, scaleIndex=4, magnitude=3
      expect(Measurement.fromPacket(packet(d0, 0x0004, 0x11E3)), isNull);
    });

    test('accepts exactly 6 bytes', () {
      final d0 = d0Word(funcCode: 0, scaleIndex: 4, magnitude: 3);
      expect(Measurement.fromPacket(packet(d0, 0x04, 0x11E3)), isNotNull);
    });
  });

  // =========================================================================
  // Measurement.fromPacket — real-world packets
  // =========================================================================
  group('fromPacket — real-world packets', () {
    // Packet from the field: meter shows 0.0000 V DC
    // bytes: 24 f0 04 00 00 80
    test('zero-reading packet (0x8000 = negative zero) → 0.0 V DC', () {
      final m = Measurement.fromPacket([0x24, 0xF0, 0x04, 0x00, 0x00, 0x80]);
      expect(m, isNotNull);
      expect(m!.function, MeasurementFunction.vDc);
      expect(m.value, 0.0);
      expect(m.isOverload, isFalse);
      expect(m.displayValue, '0');
    });

    // Packet from the field: meter shows ≈ −4.579 V DC
    // bytes: 23 f0 04 00 e3 91
    test('negative voltage packet → −4.579 V DC', () {
      final m = Measurement.fromPacket([0x23, 0xF0, 0x04, 0x00, 0xE3, 0x91]);
      expect(m, isNotNull);
      expect(m!.function, MeasurementFunction.vDc);
      expect(m.value, closeTo(-4.579, 0.001));
      expect(m.isOverload, isFalse);
    });
  });

  // =========================================================================
  // fromPacket — sign-magnitude value encoding
  // =========================================================================
  group('fromPacket — sign-magnitude encoding', () {
    // d0 with funcCode=0 (vDc), scaleIndex=4 (no prefix), magnitude=3
    const baseD0 = (0 << 6) | (4 << 3) | 3; // 0x0023

    test('positive value: 0x1194 = +4500 → +4.500', () {
      // rawAbs = 0x1194 = 4500, sign=0 → +4.500
      final m = Measurement.fromPacket(packet(baseD0, 0x04, 0x1194));
      expect(m!.value, closeTo(4.500, 0.001));
    });

    test('negative value: 0x9194 = −4500 → −4.500', () {
      // rawAbs = 0x1194 = 4500, sign=1 → −4.500
      final m = Measurement.fromPacket(packet(baseD0, 0x04, 0x9194));
      expect(m!.value, closeTo(-4.500, 0.001));
    });

    test('negative zero: 0x8000 → 0.0', () {
      final m = Measurement.fromPacket(packet(baseD0, 0x04, 0x8000));
      expect(m!.value, 0.0);
    });

    test('positive zero: 0x0000 → 0.0', () {
      final m = Measurement.fromPacket(packet(baseD0, 0x04, 0x0000));
      expect(m!.value, 0.0);
    });

    test('maximum positive: 0x7FFF = 32767 → 32.767', () {
      final m = Measurement.fromPacket(packet(baseD0, 0x04, 0x7FFF));
      expect(m!.value, closeTo(32.767, 0.001));
    });

    test('maximum negative: 0xFFFF = −32767 → −32.767', () {
      final m = Measurement.fromPacket(packet(baseD0, 0x04, 0xFFFF));
      expect(m!.value, closeTo(-32.767, 0.001));
    });
  });

  // =========================================================================
  // fromPacket — magnitude (decimal scaling)
  // =========================================================================
  group('fromPacket — magnitude scaling', () {
    // rawAbs = 0x0001 = 1, sign = positive; value = 1 / 10^magnitude
    for (final entry in {
      0: 1.0,
      1: 0.1,
      2: 0.01,
      3: 0.001,
      4: 0.0001,
      5: 0.00001,
      6: 0.000001,
    }.entries) {
      test('magnitude=${entry.key} → value=${entry.value}', () {
        final d0 = d0Word(funcCode: 0, scaleIndex: 4, magnitude: entry.key);
        final m = Measurement.fromPacket(packet(d0, 0x00, 0x0001));
        expect(m!.value, closeTo(entry.value, entry.value * 1e-9));
      });
    }

    test('magnitude=7 → isOverload (special sentinel)', () {
      final d0 = d0Word(funcCode: 0, scaleIndex: 4, magnitude: 7);
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x1234));
      expect(m!.isOverload, isTrue);
      expect(m.value, isNull);
    });
  });

  // =========================================================================
  // fromPacket — function codes
  // =========================================================================
  group('fromPacket — function codes', () {
    final cases = {
      0: MeasurementFunction.vDc,
      1: MeasurementFunction.vAc,
      2: MeasurementFunction.aDc,
      3: MeasurementFunction.aAc,
      4: MeasurementFunction.ohm,
      5: MeasurementFunction.farad,
      6: MeasurementFunction.hz,
      7: MeasurementFunction.duty,
      8: MeasurementFunction.tempC,
      9: MeasurementFunction.tempF,
      10: MeasurementFunction.voltsDiode,
      11: MeasurementFunction.ohmsContinuity,
      12: MeasurementFunction.hfe,
      13: MeasurementFunction.ncv,
    };

    for (final entry in cases.entries) {
      test('funcCode=${entry.key} → ${entry.value}', () {
        final d0 = d0Word(funcCode: entry.key, scaleIndex: 4, magnitude: 2);
        final m = Measurement.fromPacket(packet(d0, 0x00, 0x0001));
        expect(m!.function, entry.value);
      });
    }
  });

  // =========================================================================
  // fromPacket — scale index
  // =========================================================================
  group('fromPacket — scaleIndex', () {
    final scaleChars = ['%', 'n', 'μ', 'm', '', 'k', 'M', 'G'];

    for (var i = 0; i < scaleChars.length; i++) {
      test('scaleIndex=$i → scaleChar="${scaleChars[i]}"', () {
        final d0 = d0Word(funcCode: 0, scaleIndex: i, magnitude: 2);
        final m = Measurement.fromPacket(packet(d0, 0x00, 0x0001));
        expect(m!.scaleChar, scaleChars[i]);
      });
    }
  });

  // =========================================================================
  // fromPacket — iOS signed-byte robustness (& 0xFF masking)
  // =========================================================================
  group('fromPacket — iOS signed-byte robustness', () {
    test('bytes with values > 127 parse identically to their unsigned equivalents', () {
      // Simulate what iOS flutter_blue_plus may hand us: 0x91 as -111 (signed)
      final signedBytes = [0x23, -16, 0x04, 0x00, 0xE3 - 256, -111];
      final unsignedBytes = [0x23, 0xF0, 0x04, 0x00, 0xE3, 0x91];

      final fromSigned = Measurement.fromPacket(signedBytes);
      final fromUnsigned = Measurement.fromPacket(unsignedBytes);

      expect(fromSigned, isNotNull);
      expect(fromSigned!.value, closeTo(fromUnsigned!.value!, 0.001));
      expect(fromSigned.function, fromUnsigned.function);
      expect(fromSigned.scaleIndex, fromUnsigned.scaleIndex);
    });
  });

  // =========================================================================
  // fromPacket — flags parsing
  // =========================================================================
  group('fromPacket — flags', () {
    const baseD0 = (0 << 6) | (4 << 3) | 3;

    test('AUTO flag (d1 bit 2) is parsed', () {
      final m = Measurement.fromPacket(packet(baseD0, 0x04, 0x1194));
      expect(m!.flags.auto, isTrue);
      expect(m.flags.activeFlags, contains(MeasurementFlag.auto));
    });

    test('no flags when d1 = 0x00', () {
      final m = Measurement.fromPacket(packet(baseD0, 0x00, 0x1194));
      expect(m!.flags.activeFlags, isEmpty);
    });

    test('overload flag in flags → displayValue returns OL', () {
      // bit 6 of d1 = overload flag
      final m = Measurement.fromPacket(packet(baseD0, 0x40, 0x1194));
      expect(m!.flags.overload, isTrue);
      expect(m.displayValue, 'OL');
    });
  });

  // =========================================================================
  // Measurement computed properties
  // =========================================================================
  group('Measurement.isAc / isDc', () {
    test('vDc → isDc true, isAc false', () {
      final d0 = d0Word(funcCode: 0, scaleIndex: 4, magnitude: 2);
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x0001))!;
      expect(m.isDc, isTrue);
      expect(m.isAc, isFalse);
    });

    test('vAc → isAc true, isDc false', () {
      final d0 = d0Word(funcCode: 1, scaleIndex: 4, magnitude: 2);
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x0001))!;
      expect(m.isAc, isTrue);
      expect(m.isDc, isFalse);
    });

    test('aDc → isDc true', () {
      final d0 = d0Word(funcCode: 2, scaleIndex: 4, magnitude: 2);
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x0001))!;
      expect(m.isDc, isTrue);
    });

    test('aAc → isAc true', () {
      final d0 = d0Word(funcCode: 3, scaleIndex: 4, magnitude: 2);
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x0001))!;
      expect(m.isAc, isTrue);
    });

    test('ohm → neither AC nor DC', () {
      final d0 = d0Word(funcCode: 4, scaleIndex: 4, magnitude: 2);
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x0001))!;
      expect(m.isAc, isFalse);
      expect(m.isDc, isFalse);
    });
  });

  group('Measurement.displayValue', () {
    const baseD0 = (0 << 6) | (4 << 3) | 3;

    test('isOverload (magnitude=7) → "OL"', () {
      final d0 = d0Word(funcCode: 0, scaleIndex: 4, magnitude: 7);
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x1234))!;
      expect(m.displayValue, 'OL');
    });

    test('flags.overload set → "OL" even with valid value', () {
      final m = Measurement.fromPacket(packet(baseD0, 0x40, 0x1194))!;
      expect(m.displayValue, 'OL');
    });

    test('trailing zeros are stripped: 4.500 → "4.5"', () {
      // rawAbs = 4500, magnitude=3 → 4.500
      final m = Measurement.fromPacket(packet(baseD0, 0x00, 0x1194))!;
      expect(m.displayValue, '4.5');
    });

    test('whole number strips decimal: 5.000 → "5"', () {
      // rawAbs = 5000, magnitude=3 → 5.000
      final m = Measurement.fromPacket(packet(baseD0, 0x00, 0x1388))!;
      expect(m.displayValue, '5');
    });

    test('negative value displays with minus sign', () {
      // rawAbs = 4500, negative → −4.500 → "−4.5"
      final m = Measurement.fromPacket(packet(baseD0, 0x00, 0x9194))!;
      expect(m.displayValue, startsWith('-'));
    });

    test('zero displays as "0"', () {
      final m = Measurement.fromPacket(packet(baseD0, 0x00, 0x8000))!;
      expect(m.displayValue, '0');
    });
  });

  group('Measurement.displayUnit', () {
    test('vDc with no scale prefix → "V"', () {
      final d0 = d0Word(funcCode: 0, scaleIndex: 4, magnitude: 3); // scaleIndex 4 = ''
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x1194))!;
      expect(m.displayUnit, 'V');
    });

    test('vDc with milli prefix → "mV"', () {
      final d0 = d0Word(funcCode: 0, scaleIndex: 3, magnitude: 3); // scaleIndex 3 = 'm'
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x1194))!;
      expect(m.displayUnit, 'mV');
    });

    test('ohm with kilo prefix → "kΩ"', () {
      final d0 = d0Word(funcCode: 4, scaleIndex: 5, magnitude: 3); // scaleIndex 5 = 'k'
      final m = Measurement.fromPacket(packet(d0, 0x00, 0x1194))!;
      expect(m.displayUnit, 'kΩ');
    });
  });

  group('Measurement.functionName', () {
    test('vDc → "V DC"', () {
      final d0 = d0Word(funcCode: 0, scaleIndex: 4, magnitude: 2);
      expect(Measurement.fromPacket(packet(d0, 0x00, 0x0001))!.functionName, 'V DC');
    });

    test('ohm → "Ω"', () {
      final d0 = d0Word(funcCode: 4, scaleIndex: 4, magnitude: 2);
      expect(Measurement.fromPacket(packet(d0, 0x00, 0x0001))!.functionName, 'Ω');
    });

    test('hz → "Hz"', () {
      final d0 = d0Word(funcCode: 6, scaleIndex: 4, magnitude: 2);
      expect(Measurement.fromPacket(packet(d0, 0x00, 0x0001))!.functionName, 'Hz');
    });
  });
}
