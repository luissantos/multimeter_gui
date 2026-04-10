/// BLE scan-result row widget.
///
/// [DeviceTile] renders a single [DiscoveredDevice] as a styled list tile with
/// a signal-strength indicator and a [ConnectButton]. OWON-compatible devices
/// receive a highlighted border and an "OWON" badge.
///
/// Device compatibility is determined by [DevicePresenter.isOwon].
/// Signal quality colour comes from [SignalStrengthColor.color] on the
/// [SignalStrength] derived from RSSI.
library;

import 'package:flutter/material.dart';
import '../../models/discovered_device.dart';
import '../../models/signal_strength.dart';
import '../../presenters/device_presenter.dart';
import '../../theme/app_colors.dart';
import '../buttons/connect_button.dart';

/// A single row in the BLE device list.
///
/// Highlights OWON-compatible devices with a green border and badge.
/// Signal strength colour is driven by [SignalStrength]. The Connect button
/// is handled by [ConnectButton].
class DeviceTile extends StatelessWidget {
  final DiscoveredDevice device;
  final Future<void> Function(DiscoveredDevice) onConnect;
  final bool isConnecting;
  final DevicePresenter _presenter;

  DeviceTile({
    super.key,
    required this.device,
    required this.onConnect,
    required this.isConnecting,
  }) : _presenter = DevicePresenter(device);

  @override
  Widget build(BuildContext context) {
    final isOwon = _presenter.isOwon;
    final signalColor = device.rssi.signalStrength.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isOwon ? AppColors.greenDark : AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwon
              ? AppColors.green.withValues(alpha: 0.4)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          Icons.bluetooth,
          color: isOwon ? AppColors.green : AppColors.dim4,
        ),
        title: Row(
          children: [
            Text(
              device.displayName,
              style: TextStyle(
                color: isOwon ? Colors.white : AppColors.dimA,
                fontWeight: isOwon ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            if (isOwon) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.green, width: 1),
                ),
                child: const Text(
                  'OWON',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          device.id,
          style: const TextStyle(color: AppColors.dim5, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.signal_cellular_alt,
                  color: signalColor,
                  size: IconTheme.of(context).size! * (16 / 24),
                ),
                Text(
                  '${device.rssi} dBm',
                  style: TextStyle(color: signalColor, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(width: 12),
            ConnectButton(
              isOwon: isOwon,
              isConnecting: isConnecting,
              onConnect: () => onConnect(device),
            ),
          ],
        ),
      ),
    );
  }
}
