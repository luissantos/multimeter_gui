/// Presentation logic for the BLE scanner screen.
///
/// Instantiate with a list of [results] and use [sorted] or [filter] to
/// obtain a view-ready ordering or subset. Compatibility checks are delegated
/// to [DevicePresenter] so the predicate lives in one place.
library;

import '../models/discovered_device.dart';
import 'device_presenter.dart';

class ScannerPresenter {
  final List<DiscoveredDevice> results;

  const ScannerPresenter(this.results);

  /// Returns a sorted copy of [results]: OWON devices first, then by
  /// descending RSSI within each group.
  List<DiscoveredDevice> get sorted {
    return [...results]..sort((a, b) {
        final aOwon = DevicePresenter(a).isOwon;
        final bOwon = DevicePresenter(b).isOwon;
        if (aOwon && !bOwon) return -1;
        if (!aOwon && bOwon) return 1;
        return b.rssi.compareTo(a.rssi);
      });
  }

  /// Returns [results] filtered to OWON-compatible devices when
  /// [compatibleOnly] is `true`; otherwise returns [results] unchanged.
  List<DiscoveredDevice> filter({required bool compatibleOnly}) {
    if (!compatibleOnly) return results;
    return results.where((d) => DevicePresenter(d).isOwon).toList();
  }
}
