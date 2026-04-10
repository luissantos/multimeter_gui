/// Placeholder shown when the BLE scan returns no results.
///
/// [EmptyView] renders a centred bluetooth-searching icon with a context-
/// aware message. When [compatibleOnly] is true the message explains that
/// no OWON-compatible devices were found and suggests disabling the filter;
/// otherwise it simply tells the user the scan is in progress.
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';

class EmptyView extends StatelessWidget {
  /// When true, the message reflects the compatible-only filter being active.
  final bool compatibleOnly;

  const EmptyView({super.key, this.compatibleOnly = false});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: IconTheme.of(context).size! * (64 / 24),
            color: AppColors.dim3,
          ),
          const SizedBox(height: 16),
          Text(
            compatibleOnly ? l10n.noCompatibleDevices : l10n.searchingForDevices,
            style: const TextStyle(color: AppColors.dim5, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            compatibleOnly ? l10n.compatibleDeviceHint : l10n.devicePowerOnHint,
            style: const TextStyle(color: AppColors.dim3, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
