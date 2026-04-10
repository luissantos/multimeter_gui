import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/discovered_device.dart';
import '../models/measurement.dart';
import '../models/scanner_state.dart';
import '../services/ble_service.dart';

class MultimeterProvider extends ChangeNotifier {
  final BleService _ble = BleService();

  BleConnectionState _connectionState = BleConnectionState.disconnected;
  Measurement? _lastMeasurement;
  List<DiscoveredDevice> _scanResults = [];
  List<DiscoveredDevice> _pendingScanResults = [];
  Timer? _scanThrottleTimer;
  String? _errorMessage;

  final List<Measurement> _history = [];
  static const int _maxHistory = 200;

  final _scannerController = StreamController<ScannerState>.broadcast();

  StreamSubscription? _measurementSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _scanSub;

  BleConnectionState get connectionState => _connectionState;
  Measurement? get lastMeasurement => _lastMeasurement;
  List<DiscoveredDevice> get scanResults => List.unmodifiable(_scanResults);
  String? get errorMessage => _errorMessage;
  List<Measurement> get history => List.unmodifiable(_history);
  bool get isConnected => _connectionState == BleConnectionState.connected;
  bool get isScanning => _connectionState == BleConnectionState.scanning;
  String? get connectedDeviceName => _ble.connectedDeviceName;

  /// Emits a new [ScannerState] whenever scanner-relevant BLE state changes.
  Stream<ScannerState> get scannerStream => _scannerController.stream;

  MultimeterProvider() {
    _connectionSub = _ble.connectionState.listen((state) {
      _connectionState = state;
      if (state == BleConnectionState.disconnected) {
        _lastMeasurement = null;
      }
      _emitScannerState();
      notifyListeners();
    });

    _measurementSub = _ble.measurements.listen((m) {
      _lastMeasurement = m;
      _history.add(m);
      if (_history.length > _maxHistory) {
        _history.removeAt(0);
      }
      notifyListeners();
    });

    _scanSub = _ble.scanResults.listen((results) {
      _pendingScanResults = results;
      _scanThrottleTimer ??= Timer(const Duration(milliseconds: 1000), () {
        _scanResults = _pendingScanResults;
        _scanThrottleTimer = null;
        _emitScannerState();
        notifyListeners();
      });
    });
  }

  void _emitScannerState() {
    if (_errorMessage != null) {
      _scannerController.add(ScannerError(message: _errorMessage!));
      return;
    }
    final isScanning = _connectionState == BleConnectionState.scanning;
    final isConnecting = _connectionState == BleConnectionState.connecting;
    if (_scanResults.isEmpty) {
      _scannerController.add(ScannerEmpty(isScanning: isScanning));
    } else {
      _scannerController.add(ScannerResults(
        results: List.unmodifiable(_scanResults),
        isScanning: isScanning,
        isConnecting: isConnecting,
      ));
    }
  }

  Future<void> startScan() async {
    _errorMessage = null;
    _scanResults = [];
    _pendingScanResults = [];
    _scanThrottleTimer?.cancel();
    _scanThrottleTimer = null;
    _emitScannerState();
    notifyListeners();
    try {
      await _ble.startScan();
    } catch (e) {
      _errorMessage = e.toString();
      _connectionState = BleConnectionState.error;
      _emitScannerState();
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    await _ble.stopScan();
  }

  Future<void> connect(DiscoveredDevice device) async {
    _errorMessage = null;
    try {
      await _ble.connect(device);
    } catch (e) {
      _errorMessage = 'Connection failed: $e';
      _emitScannerState();
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await _ble.disconnect();
    _history.clear();
    notifyListeners();
  }

  Future<void> sendButton(ButtonCode button, {bool longPress = false}) async {
    await _ble.sendButton(button, longPress: longPress);
  }

  Future<String?> renameDevice(String name) async {
    return await _ble.renameDevice(name);
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _measurementSub?.cancel();
    _connectionSub?.cancel();
    _scanSub?.cancel();
    _scanThrottleTimer?.cancel();
    _scannerController.close();
    _ble.dispose();
    super.dispose();
  }
}
