/// Primary measurement readout for the OWON B41T multimeter.
///
/// [MeasurementDisplay] is the centrepiece of the instrument screen. It
/// presents three rows:
///
/// 1. **Function row** — AC/DC badge and measurement function name (e.g. "V DC").
/// 2. **Value row** — large selectable numeric readout with its scale-prefixed
///    unit (e.g. "−4.579 mV"). The value glows green for normal readings and
///    turns red on overload.
/// 3. **Flags row** — active status badges derived from the packet's flag byte.
///    Each [MeasurementFlag] supplies its own label and badge colour.
///
/// Passing `null` for [measurement] renders placeholder dashes, which is the
/// correct state before the first BLE packet arrives.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../models/measurement.dart';
import '../../theme/app_colors.dart';

class MeasurementDisplay extends StatelessWidget {
  final Measurement? measurement;

  const MeasurementDisplay({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FunctionRow(
            isAc: measurement?.isAc ?? false,
            isDc: measurement?.isDc ?? false,
            functionName: measurement?.functionName ?? '---',
          ),
          const SizedBox(height: 16),
          _ValueDisplay(
            displayValue: measurement?.displayValue ?? '---',
            displayUnit: measurement?.displayUnit ?? '',
            isOverload: measurement?.isOverload ?? false,
          ),
          const SizedBox(height: 16),
          _FlagsRow(flags: measurement?.flags.activeFlags ?? []),
        ],
      ),
    );
  }
}

/// AC/DC mode badge and measurement function label row.
class _FunctionRow extends StatelessWidget {
  final bool isAc;
  final bool isDc;
  final String functionName;

  const _FunctionRow({
    required this.isAc,
    required this.isDc,
    required this.functionName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isAc)
              _Badge(label: context.l10n.badgeAc, color: AppColors.cyan)
            else if (isDc)
              _Badge(label: context.l10n.badgeDc, color: AppColors.green),
          ],
        ),
        Text(
          functionName,
          style: const TextStyle(
            color: AppColors.dimA,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 60),
      ],
    );
  }
}

/// Large numeric readout with optional scale-prefixed unit label.
///
/// The value text is selectable so it can be copied to the clipboard.
/// Colour switches from green to red when [isOverload] is true.
class _ValueDisplay extends StatelessWidget {
  final String displayValue;
  final String displayUnit;
  final bool isOverload;

  const _ValueDisplay({
    required this.displayValue,
    required this.displayUnit,
    required this.isOverload,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = isOverload ? AppColors.red : AppColors.green;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SelectableText(
              displayValue,
              style: TextStyle(
                color: valueColor,
                fontSize: 80,
                fontWeight: FontWeight.w300,
                fontFamily: 'monospace',
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: valueColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (displayUnit.isNotEmpty) ...[
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              displayUnit,
              style: const TextStyle(
                color: AppColors.dim8,
                fontSize: 28,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Row of active status badges.
///
/// Each [MeasurementFlag] carries its own [MeasurementFlag.label] and
/// [MeasurementFlag.badgeColor], so no string comparisons or colour look-ups
/// are needed here. Renders nothing when [flags] is empty.
class _FlagsRow extends StatelessWidget {
  final List<MeasurementFlag> flags;

  const _FlagsRow({required this.flags});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: flags
          .map((f) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _Badge(label: f.label, color: f.badgeColor),
              ))
          .toList(),
    );
  }
}

/// Small pill-shaped label badge with a coloured border and tinted background.
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(4),
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
