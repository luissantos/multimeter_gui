/// Modal dialog for renaming the connected OWON B41T device over BLE.
///
/// The dialog is decoupled from the provider: [onConfirm] receives the
/// trimmed name and should delegate to [BleService.renameDevice]. It must
/// return an error string on validation failure or `null` on success. When
/// an error is returned the dialog stays open and shows a [SnackBar]; the
/// caller is responsible for dismissing the dialog on success (typically via
/// [Navigator.pop] inside [onConfirm]).
///
/// Background colour, shape, and title text style are inherited from
/// [AppTheme]'s [DialogTheme]. The [TextField] inherits its fill colour
/// and border styles from [AppTheme]'s [InputDecorationTheme].
library;

import 'package:flutter/material.dart';
import '../../extensions/build_context_ext.dart';
import '../../theme/app_colors.dart';
import '../buttons/loading_button.dart';

class RenameDialog extends StatefulWidget {
  /// The device's current name, pre-filled into the text field.
  final String initialName;

  /// Asynchronous confirmation handler. Returns an error message if the
  /// name is rejected by the firmware, or `null` on success.
  final Future<String?> Function(String name) onConfirm;

  const RenameDialog({
    super.key,
    required this.initialName,
    required this.onConfirm,
  });

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late final TextEditingController _controller;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      // Background, shape and titleTextStyle come from AppTheme.dialogTheme.
      title: Text(l10n.renameDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 14,
            style: const TextStyle(color: Colors.white),
            // Fill colour and border styles come from AppTheme.inputDecorationTheme.
            decoration: InputDecoration(hintText: l10n.renameDialogHint),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.renameDialogValidationNote,
            style: const TextStyle(color: AppColors.dim5, fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel, style: const TextStyle(color: AppColors.dim8)),
        ),
        LoadingButton(
          label: l10n.buttonRename,
          isLoading: _loading,
          onPressed: () async {
            setState(() => _loading = true);
            await widget.onConfirm(_controller.text.trim());
            if (mounted) setState(() => _loading = false);
          },
        ),
      ],
    );
  }
}
