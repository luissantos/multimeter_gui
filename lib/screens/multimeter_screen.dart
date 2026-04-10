import 'package:flutter/material.dart';
import '../extensions/build_context_ext.dart';
import '../providers/multimeter_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons/disconnect_button.dart';
import '../widgets/buttons/rename_button.dart';
import '../widgets/measurement/measurement_display.dart';
import '../widgets/controls/control_panel.dart';
import '../widgets/sidebar/sidebar_toggle.dart';
import '../widgets/sidebar/sidebar_panel.dart';
import '../widgets/dialogs/rename_dialog.dart';

class MultimeterScreen extends StatefulWidget {
  final MultimeterProvider provider;

  const MultimeterScreen({super.key, required this.provider});

  @override
  State<MultimeterScreen> createState() => _MultimeterScreenState();
}

class _MultimeterScreenState extends State<MultimeterScreen> {
  bool _sidebarOpen = true;

  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.provider.removeListener(_rebuild);
    super.dispose();
  }

  Future<void> _showRenameDialog() async {
    final provider = widget.provider;
    final messenger = ScaffoldMessenger.of(context);
    final renamedMsg = context.l10n.deviceRenamedSuccess;
    final current = provider.connectedDeviceName ?? '';

    await showDialog<void>(
      context: context,
      builder: (ctx) => RenameDialog(
        initialName: current,
        onConfirm: (name) async {
          final error = await provider.renameDevice(name);
          if (!ctx.mounted) return null;
          if (error != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: AppColors.red,
              ),
            );
            return error;
          }
          Navigator.of(ctx).pop();
          messenger.showSnackBar(
            SnackBar(
              content: Text(renamedMsg),
              backgroundColor: AppColors.greenMid,
            ),
          );
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.green, blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              provider.connectedDeviceName ?? context.l10n.appTitle,
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
          RenameButton(onPressed: _showRenameDialog),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DisconnectButton(onPressed: provider.disconnect),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sidebarWidth = constraints.maxWidth * 0.4;
          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MeasurementDisplay(measurement: provider.lastMeasurement),
                        const SizedBox(height: 24),
                        ControlPanel(
                          onButton: (code) { provider.sendButton(code); },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SidebarToggle(
                open: _sidebarOpen,
                onTap: () => setState(() => _sidebarOpen = !_sidebarOpen),
              ),
              ClipRect(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  width: _sidebarOpen ? sidebarWidth : 0,
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    maxWidth: sidebarWidth,
                    child: SizedBox(
                      width: sidebarWidth,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 24, 24),
                        child: SidebarPanel(
                          history: provider.history,
                          onClear: provider.clearHistory,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
