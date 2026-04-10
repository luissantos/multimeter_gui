/// Presentation logic for a single discovered BLE device.
///
/// Instantiate with a [device] and read [isOwon] to determine device
/// compatibility. [DeviceTile] creates one in its [build] method.
///
/// A device is considered compatible when it advertises the OWON service UUID
/// (0xFFF0), or when its display name contains one of the known tokens:
/// "OWON", "B41", "LILLIPUT", or the short name "BDM".
library;

import '../models/discovered_device.dart';

class DevicePresenter {
  final DiscoveredDevice device;

  const DevicePresenter(this.device);

  /// Returns `true` when [device] is likely an OWON B41T multimeter.
  bool get isOwon {
    const owonServiceUuid = 'fff0';
    if (device.serviceUuids.any((s) => s.contains(owonServiceUuid))) {
      return true;
    }

    // Check advName and platformName independently — one may match even when
    // the other is empty or contains an unrelated string.
    for (final name in [device.advName, device.platformName]) {
      final upper = name.toUpperCase();
      if (upper.contains('OWON') ||
          upper.contains('B41') ||
          upper.contains('LILLIPUT') ||
          upper == 'BDM') {
        return true;
      }
    }
    return false;
  }
}
