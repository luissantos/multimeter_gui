/// Scrollable console log of raw measurement readings.
///
/// [ConsoleView] renders each [Measurement] in [history] as a compact
/// monospace line. Each row is rendered by [_ConsoleLine], which owns a
/// [ConsolePresenter] and reads its formatted properties directly.
///
/// New entries auto-scroll to the bottom unless the user has scrolled up.
/// A [HoverIconButton] freezes the displayed list at a snapshot, letting the
/// user read individual rows without them shifting.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../models/measurement.dart';
import '../../presenters/console_presenter.dart';
import '../../theme/app_colors.dart';
import '../buttons/hover_icon_button.dart';

class ConsoleView extends StatefulWidget {
  final List<Measurement> history;

  const ConsoleView({super.key, required this.history});

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<ConsoleView> {
  final ScrollController _scroll = ScrollController();
  bool _isAtBottom = true;
  bool _paused = false;
  List<Measurement> _snapshot = [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    _isAtBottom = pos.pixels >= pos.maxScrollExtent - 4;
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      if (_paused) _snapshot = List.of(widget.history);
    });
  }

  @override
  void didUpdateWidget(ConsoleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_paused &&
        _isAtBottom &&
        widget.history.length != oldWidget.history.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _paused ? _snapshot : widget.history;

    if (data.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noDataYet,
          style: const TextStyle(color: AppColors.dim3, fontSize: 13),
        ),
      );
    }

    return Stack(
      children: [
        SelectionArea(
          child: ListView.builder(
            controller: _scroll,
            itemCount: data.length,
            itemBuilder: (_, i) => _ConsoleLine(measurement: data[i]),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: HoverIconButton(
            icon: Icons.pause,
            activeIcon: Icons.play_arrow,
            isActive: _paused,
            tooltip: _paused ? context.l10n.tooltipResume : context.l10n.tooltipPause,
            onTap: _togglePause,
          ),
        ),
      ],
    );
  }
}

/// A single row in the console log.
///
/// Owns a [ConsolePresenter] as a field and renders its formatted properties.
/// Contains no formatting logic of its own.
class _ConsoleLine extends StatelessWidget {
  final ConsolePresenter _presenter;

  _ConsoleLine({required Measurement measurement})
      : _presenter = ConsolePresenter(measurement);

  @override
  Widget build(BuildContext context) {
    final presenter = _presenter;

    return Row(
      children: [
        Text(
          presenter.time,
          style: const TextStyle(color: AppColors.dim4, fontSize: 11, fontFamily: 'monospace'),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: Text(
            presenter.functionName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.cyan, fontSize: 11, fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Text(
            '${presenter.value} ${presenter.unit}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: presenter.isOverload ? AppColors.red : AppColors.green,
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (presenter.flagLabels.isNotEmpty) ...[
          const SizedBox(width: 6),
          Flexible(
            flex: 2,
            child: Text(
              presenter.flagLabels.join(' '),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.yellow,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
