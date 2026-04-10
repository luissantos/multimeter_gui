import 'package:flutter/material.dart';
import '../extensions/build_context_ext.dart';
import '../models/discovered_device.dart';
import '../models/scanner_state.dart';
import '../presenters/scanner_presenter.dart';
import '../providers/multimeter_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons/scan_button.dart';
import '../widgets/scanner/device_list.dart';
import '../widgets/scanner/empty_view.dart';
import '../widgets/scanner/error_view.dart';
import '../widgets/scanner/filter_toggle.dart';

class ScannerScreen extends StatefulWidget {
  final MultimeterProvider provider;

  const ScannerScreen({super.key, required this.provider});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _compatibleOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return StreamBuilder<ScannerState>(
      stream: provider.scannerStream,
      initialData: const ScannerEmpty(isScanning: false),
      builder: (context, snapshot) {
        final state = snapshot.requireData;

        return Scaffold(
          backgroundColor: AppColors.bg0,
          appBar: AppBar(
            backgroundColor: AppColors.bg2,
            title: Row(
              children: [
                const Icon(Icons.bluetooth, color: AppColors.cyan),
                const SizedBox(width: 8),
                Text(
                  context.l10n.scanScreenTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              FilterToggle(
                value: _compatibleOnly,
                onChanged: (v) => setState(() => _compatibleOnly = v),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ScanButton(
                  isScanning: switch (state) {
                    ScannerEmpty(:final isScanning) => isScanning,
                    ScannerResults(:final isScanning) => isScanning,
                    ScannerError() => false,
                  },
                  onPressed: switch (state) {
                    ScannerEmpty(:final isScanning) =>
                      isScanning ? provider.stopScan : provider.startScan,
                    ScannerResults(:final isScanning) =>
                      isScanning ? provider.stopScan : provider.startScan,
                    ScannerError() => provider.startScan,
                  },
                ),
              ),
            ],
          ),
          body: _buildBody(state, provider),
        );
      },
    );
  }

  Widget _buildBody(ScannerState state, MultimeterProvider provider) {
    return switch (state) {
      ScannerError(:final message) => ErrorView(
          message: message,
          onRetry: provider.startScan,
        ),
      ScannerEmpty() => EmptyView(compatibleOnly: _compatibleOnly),
      ScannerResults(:final results, :final isConnecting) => _buildResults(
          results,
          isConnecting,
          provider,
        ),
    };
  }

  Widget _buildResults(
    List<DiscoveredDevice> results,
    bool isConnecting,
    MultimeterProvider provider,
  ) {
    final filtered = ScannerPresenter(results).filter(
      compatibleOnly: _compatibleOnly,
    );
    if (filtered.isEmpty) return EmptyView(compatibleOnly: _compatibleOnly);
    return DeviceList(
      results: filtered,
      isConnecting: isConnecting,
      onConnect: (device) async {
        await provider.stopScan();
        if (context.mounted) {
          await provider.connect(device);
        }
      },
    );
  }
}
