import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/discovered_device.dart';
import '../models/measurement.dart';

// OWON B41T BLE UUIDs (short form matched via .contains())
// Service: 0xFFF0, Command: 0xFFF1, Control: 0xFFF3, Notify: 0xFFF4

enum BleConnectionState { disconnected, scanning, connecting, connected, error }

enum ButtonCode { none, select, range, hold, rel, hz, max, all }

class BleService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;
  BluetoothCharacteristic? _commandChar;
  BluetoothCharacteristic? _controlChar;
  StreamSubscription? _notifySubscription;
  StreamSubscription? _connectionSubscription;

  /// Registry mapping device id → BluetoothDevice for use when connecting.
  final Map<String, BluetoothDevice> _deviceRegistry = {};

  final _measurementController = StreamController<Measurement>.broadcast();
  final _connectionStateController = StreamController<BleConnectionState>.broadcast();
  final _scanResultsController = StreamController<List<DiscoveredDevice>>.broadcast();

  Stream<Measurement> get measurements => _measurementController.stream;
  Stream<BleConnectionState> get connectionState => _connectionStateController.stream;
  Stream<List<DiscoveredDevice>> get scanResults => _scanResultsController.stream;

  Future<void> startScan() async {
    _deviceRegistry.clear();
    _connectionStateController.add(BleConnectionState.scanning);

    // Wait for the adapter to be ready before scanning — on app start the
    // adapter may still be initialising even though Bluetooth is on.
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 5));
    }

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      withServices: [],
    );

    FlutterBluePlus.scanResults.listen((results) {
      final devices = <DiscoveredDevice>[];
      for (final r in results) {
        final ad = r.advertisementData;
        final id = r.device.remoteId.str;

        _deviceRegistry[id] = r.device;

        final advName = ad.advName;
        final platformName = r.device.platformName;
        final displayName = advName.isNotEmpty
            ? advName
            : platformName.isNotEmpty
                ? platformName
                : id;

        final serviceUuids = ad.serviceUuids
            .map((u) => u.str128.toLowerCase())
            .toList();

        devices.add(DiscoveredDevice(
          id: id,
          displayName: displayName,
          advName: advName,
          platformName: platformName,
          rssi: r.rssi,
          serviceUuids: serviceUuids,
        ));

        developer.log('[BLE] device="$displayName" '
            'id=$id '
            'rssi=${r.rssi} '
            'serviceUuids=$serviceUuids '
            'localName="$advName" '
            'manufacturerData=${ad.manufacturerData.map((k, v) => MapEntry(k.toRadixString(16), v.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")))}');
      }
      _scanResultsController.add(List.unmodifiable(devices));
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning && _device == null) {
        _connectionStateController.add(BleConnectionState.disconnected);
      }
    });
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(DiscoveredDevice discovered) async {
    final device = _deviceRegistry[discovered.id];
    if (device == null) return;

    _connectionStateController.add(BleConnectionState.connecting);
    _device = device;
    _connectedDisplayName = discovered.displayName;

    try {
      await device.connect(timeout: const Duration(seconds: 15));

      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
      });

      await _discoverServices();
      _connectionStateController.add(BleConnectionState.connected);
    } catch (e) {
      _connectionStateController.add(BleConnectionState.error);
      rethrow;
    }
  }

  Future<void> _discoverServices() async {
    if (_device == null) return;

    final services = await _device!.discoverServices();
    for (final service in services) {
      final svcUuid = service.uuid.toString().toLowerCase();
      developer.log('[BLE] service=$svcUuid');

      if (svcUuid.contains('fff0')) {
        for (final char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          final props = char.properties;
          developer.log('[BLE]   char=$uuid '
              'notify=${props.notify} '
              'write=${props.write} '
              'writeNoResp=${props.writeWithoutResponse}');

          if (uuid.contains('fff4')) {
            _notifyChar = char;
          } else if (uuid.contains('fff1')) {
            _commandChar = char;
          } else if (uuid.contains('fff3')) {
            _controlChar = char;
          }
        }
      }
    }

    developer.log('[BLE] notifyChar=${_notifyChar?.uuid} '
        'commandChar=${_commandChar?.uuid} '
        'controlChar=${_controlChar?.uuid}');

    if (_notifyChar != null) {
      await _notifyChar!.setNotifyValue(true);
      _notifySubscription = _notifyChar!.onValueReceived.listen(_onData);
    }
  }

  void _onData(List<int> bytes) {
    if (bytes.isEmpty) return;
    developer.log('[BLE] packet(${bytes.length}b): ${bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")}');
    final measurement = Measurement.fromPacket(bytes);
    if (measurement != null) {
      _measurementController.add(measurement);
    }
  }

  void _onDisconnected() {
    _notifySubscription?.cancel();
    _connectionStateController.add(BleConnectionState.disconnected);
    _device = null;
    _connectedDisplayName = null;
    _notifyChar = null;
    _commandChar = null;
    _controlChar = null;
  }

  Future<void> disconnect() async {
    await _notifySubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _device?.disconnect();
    _device = null;
    _connectedDisplayName = null;
    _notifyChar = null;
    _commandChar = null;
    _controlChar = null;
    _connectionStateController.add(BleConnectionState.disconnected);
  }

  /// Rename the device. Max 14 chars, no ?, *, @, or comma.
  /// Returns an error message if validation fails, null on success.
  Future<String?> renameDevice(String name) async {
    if (name.isEmpty) return 'Name cannot be empty';
    if (name.length > 14) return 'Name must be 14 characters or fewer';
    if (RegExp(r'[?*@,]').hasMatch(name)) return 'Name cannot contain ?, *, @, or comma';
    if (name.codeUnits.any((c) => c < 32 || c > 126)) return 'Name contains invalid characters';
    await sendCommand('@$name');
    return null;
  }

  Future<void> sendButton(ButtonCode button, {bool longPress = false}) async {
    if (_controlChar == null) return;
    final code = button.index;
    final value = longPress ? (code & 0x0F) : (0x0100 | (code & 0x0F));
    final withoutResponse = _controlChar!.properties.writeWithoutResponse &&
        !_controlChar!.properties.write;
    await _controlChar!.write(
      [value & 0xFF, (value >> 8) & 0xFF],
      withoutResponse: withoutResponse,
    );
  }

  Future<void> sendCommand(String command) async {
    if (_commandChar == null) return;
    final bytes = List<int>.filled(16, 0);
    final cmdBytes = command.codeUnits;
    for (int i = 0; i < cmdBytes.length && i < 16; i++) {
      bytes[i] = cmdBytes[i];
    }
    final withoutResponse = _commandChar!.properties.writeWithoutResponse &&
        !_commandChar!.properties.write;
    developer.log('[BLE] sendCommand="${command.substring(0, command.length.clamp(0, 16))}" '
        'withoutResponse=$withoutResponse '
        'bytes=${bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")}');
    await _commandChar!.write(bytes, withoutResponse: withoutResponse);
  }

  String? _connectedDisplayName;

  bool get isConnected => _device != null;

  String? get connectedDeviceName => _connectedDisplayName;

  void dispose() {
    _notifySubscription?.cancel();
    _connectionSubscription?.cancel();
    _measurementController.close();
    _connectionStateController.close();
    _scanResultsController.close();
  }
}
