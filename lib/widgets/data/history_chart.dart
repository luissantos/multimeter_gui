/// Scrolling line chart of recent measurement values.
///
/// [HistoryChart] delegates all data computation to [HistoryChartPresenter],
/// then passes the resulting [ChartData] to [_ChartPainter] which is
/// responsible only for canvas drawing. Renders a placeholder when fewer than
/// two valid points are available.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../models/measurement.dart';
import '../../presenters/history_chart_presenter.dart';
import '../../theme/app_colors.dart';

class HistoryChart extends StatelessWidget {
  final HistoryChartPresenter _presenter;

  HistoryChart({super.key, required List<Measurement> history})
      : _presenter = HistoryChartPresenter(history);

  @override
  Widget build(BuildContext context) {
    final data = _presenter.data;

    if (data == null) {
      return Center(
        child: Text(
          context.l10n.waitingForData,
          style: const TextStyle(color: AppColors.dim5, fontSize: 14),
        ),
      );
    }

    return CustomPaint(
      painter: _ChartPainter(data),
      child: const SizedBox.expand(),
    );
  }
}

/// Pure canvas renderer for the history waveform.
///
/// Receives pre-computed [ChartData] from [HistoryChartPresenter] and paints
/// the grid lines, glow + line path, latest-point dot, and axis labels.
/// Contains no business logic.
class _ChartPainter extends CustomPainter {
  final ChartData data;

  _ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.green.withValues(alpha: 0.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = AppColors.bg5
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = data.points;
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height * (1.0 - points[i].normalized);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    final lastX = size.width.toDouble();
    final lastY = size.height * (1.0 - points.last.normalized);
    canvas.drawCircle(
      Offset(lastX, lastY),
      4,
      Paint()..color = AppColors.green,
    );

    const labelStyle = TextStyle(color: AppColors.dim5, fontSize: 10);
    _drawLabel(canvas, data.highLabel, 4, 4, labelStyle);
    _drawLabel(canvas, data.lowLabel, 4, size.height - 16, labelStyle);
  }

  void _drawLabel(Canvas canvas, String text, double x, double y, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => oldDelegate.data != data;
}
