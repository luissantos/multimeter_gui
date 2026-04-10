/// State model for the BLE scanner screen.
///
/// [ScannerState] is a sealed class with three concrete variants that cover
/// every possible condition of the scanner body:
///
/// * [ScannerEmpty] — scan is active or idle but no devices are visible.
/// * [ScannerResults] — at least one device has been discovered.
/// * [ScannerError] — the scan or a connection attempt has failed.
///
/// [MultimeterProvider] emits a new [ScannerState] via [scannerStream]
/// whenever the underlying BLE state changes. [ScannerScreen] drives its
/// entire UI from a [StreamBuilder] over that stream.
library;

import 'discovered_device.dart';

sealed class ScannerState {
  const ScannerState();
}

/// Scan is running or idle with no discovered devices.
final class ScannerEmpty extends ScannerState {
  /// Whether a BLE scan is currently active.
  final bool isScanning;

  const ScannerEmpty({required this.isScanning});
}

/// One or more BLE devices have been discovered.
final class ScannerResults extends ScannerState {
  /// All discovered devices (unfiltered).
  final List<DiscoveredDevice> results;

  /// Whether a BLE scan is currently active.
  final bool isScanning;

  /// Whether a connection attempt is in progress.
  final bool isConnecting;

  const ScannerResults({
    required this.results,
    required this.isScanning,
    required this.isConnecting,
  });
}

/// The scan or connection attempt produced an error.
final class ScannerError extends ScannerState {
  /// Human-readable error description.
  final String message;

  const ScannerError({required this.message});
}
