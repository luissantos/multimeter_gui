/// Minimal BLE device model shared across the app.
///
/// All flutter_blue_plus types are confined to [BleService]. This model
/// carries only what the UI needs: a stable identifier, a resolved display
/// name, signal strength, and service UUIDs for compatibility detection.
library;

class DiscoveredDevice {
  final String id;

  /// Resolved display name: advName → platformName → id.
  final String displayName;

  /// Raw advertisement local name. Empty if the device does not include it.
  final String advName;

  /// OS-cached peripheral name. May be empty on first encounter.
  final String platformName;

  final int rssi;
  final List<String> serviceUuids;

  const DiscoveredDevice({
    required this.id,
    required this.displayName,
    required this.advName,
    required this.platformName,
    required this.rssi,
    required this.serviceUuids,
  });
}
