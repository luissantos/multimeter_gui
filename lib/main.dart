import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gen_l10n/app_localizations.dart';
import 'providers/multimeter_provider.dart';
import 'providers/zoom_provider.dart';
import 'screens/scanner_screen.dart';
import 'screens/multimeter_screen.dart';
import 'services/ble_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final multimeterProvider = MultimeterProvider();
  final zoomProvider = ZoomProvider();

  runApp(OwonApp(
    multimeterProvider: multimeterProvider,
    zoomProvider: zoomProvider,
  ));
}

// Intents for zoom shortcuts
class _ZoomInIntent extends Intent { const _ZoomInIntent(); }
class _ZoomOutIntent extends Intent { const _ZoomOutIntent(); }
class _ZoomResetIntent extends Intent { const _ZoomResetIntent(); }

class OwonApp extends StatelessWidget {
  final MultimeterProvider multimeterProvider;
  final ZoomProvider zoomProvider;

  const OwonApp({
    super.key,
    required this.multimeterProvider,
    required this.zoomProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isMac = Platform.isMacOS;
    return MaterialApp(
      title: 'OWON B41T',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: zoomProvider,
          builder: (context, _) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(zoomProvider.scale),
              ),
              child: IconTheme(
                data: IconThemeData(size: 24 * zoomProvider.scale),
                child: Shortcuts(
                  shortcuts: {
                    SingleActivator(LogicalKeyboardKey.equal,
                        meta: isMac, control: !isMac): const _ZoomInIntent(),
                    SingleActivator(LogicalKeyboardKey.numpadAdd,
                        meta: isMac, control: !isMac): const _ZoomInIntent(),
                    SingleActivator(LogicalKeyboardKey.minus,
                        meta: isMac, control: !isMac): const _ZoomOutIntent(),
                    SingleActivator(LogicalKeyboardKey.numpadSubtract,
                        meta: isMac, control: !isMac): const _ZoomOutIntent(),
                    SingleActivator(LogicalKeyboardKey.digit0,
                        meta: isMac, control: !isMac): const _ZoomResetIntent(),
                  },
                  child: Actions(
                    actions: {
                      _ZoomInIntent: CallbackAction<_ZoomInIntent>(
                          onInvoke: (_) => zoomProvider.zoomIn()),
                      _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(
                          onInvoke: (_) => zoomProvider.zoomOut()),
                      _ZoomResetIntent: CallbackAction<_ZoomResetIntent>(
                          onInvoke: (_) => zoomProvider.reset()),
                    },
                    child: Focus(autofocus: true, child: child!),
                  ),
                ),
              ),
            );
          },
        );
      },
      home: _AppNavigator(multimeterProvider: multimeterProvider),
    );
  }
}

class _AppNavigator extends StatefulWidget {
  final MultimeterProvider multimeterProvider;

  const _AppNavigator({required this.multimeterProvider});

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  @override
  void initState() {
    super.initState();
    widget.multimeterProvider.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.multimeterProvider.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.multimeterProvider.connectionState == BleConnectionState.connected) {
      return MultimeterScreen(provider: widget.multimeterProvider);
    }
    return ScannerScreen(provider: widget.multimeterProvider);
  }
}
