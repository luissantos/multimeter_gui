/// Sorted list of BLE scan results.
///
/// [DeviceList] delegates ordering to [ScannerPresenter.sort], which places
/// OWON-compatible devices first and then sorts remaining entries by
/// descending RSSI. Each entry is rendered by [DeviceTile].
library;

import 'package:flutter/material.dart';
import '../../models/discovered_device.dart';
import '../../presenters/scanner_presenter.dart';
import 'device_tile.dart';

class DeviceList extends StatelessWidget {
  final Future<void> Function(DiscoveredDevice) onConnect;
  final bool isConnecting;
  final ScannerPresenter _presenter;

  DeviceList({
    super.key,
    required List<DiscoveredDevice> results,
    required this.onConnect,
    required this.isConnecting,
  }) : _presenter = ScannerPresenter(results);

  @override
  Widget build(BuildContext context) {
    final sorted = _presenter.sorted;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, i) => DeviceTile(
        device: sorted[i],
        onConnect: onConnect,
        isConnecting: isConnecting,
      ),
    );
  }
}
