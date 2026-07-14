/// =============================================================================
/// File: thermal_data_hub_service.dart
/// Description: Realtime client for the backend's SignalR `ThermalDataHub`
/// (`/thermalDataHub`), used to push live temperature-level changes for
/// machines/components shown on the diagram screen.
/// =============================================================================

import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import 'package:thermal_mobile/core/logger/app_logger.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:thermal_mobile/data/network/api/base_url_provider.dart';

/// A single machine/component whose temperature level changed, as pushed by
/// the hub's `newThermalData` event. Mirrors the backend's
/// `MachineComponentThermalInfo` (Id/Key/DeviceType/Level).
class MachineLevelUpdate {
  final int id;
  final String key;
  final String deviceType;

  /// Normalized to the same vocabulary used by the REST API's `level`
  /// field: Undefined / Good / Fair / Average / Bad.
  final String level;

  const MachineLevelUpdate({
    required this.id,
    required this.key,
    required this.deviceType,
    required this.level,
  });
}

/// Wraps a [HubConnection] to the backend's `ThermalDataHub`.
///
/// Usage: call [connect] once, then [registerMachines] with the machine ids
/// currently of interest (e.g. the ones shown on the open diagram) to start
/// receiving [updates] for them.
class ThermalDataHubService {
  ThermalDataHubService(
    BaseUrlProvider baseUrlProvider,
    GetAccessToken getAccessToken, {
    AppLogger? logger,
  }) : _baseUrlProvider = baseUrlProvider,
       _getAccessToken = getAccessToken,
       _logger = logger ?? AppLogger(tag: 'ThermalDataHubService');

  static const String _hubPath = '/thermalDataHub';

  // Backend's TemperatureLevel enum (ThermalMonitoring.Common/Commons/Enums.cs)
  // is sent as a raw index (0-4) over SignalR (no StringEnumConverter is wired
  // for the hub's Newtonsoft protocol, unlike the REST API), so it must be
  // mapped back to the same name strings the REST API returns.
  static const List<String> _levelNames = [
    'Undefined',
    'Good',
    'Fair',
    'Average',
    'Bad',
  ];

  final BaseUrlProvider _baseUrlProvider;
  final GetAccessToken _getAccessToken;
  final AppLogger _logger;

  HubConnection? _connection;
  final Set<int> _registeredMachineIds = {};
  final StreamController<List<MachineLevelUpdate>> _updatesController =
      StreamController<List<MachineLevelUpdate>>.broadcast();

  /// Emits batches of level updates whenever the hub pushes `newThermalData`.
  Stream<List<MachineLevelUpdate>> get updates => _updatesController.stream;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  /// Connects to the hub if not already connected/connecting. Safe to call
  /// multiple times.
  Future<void> connect() async {
    if (_connection != null) return;

    final connection = HubConnectionBuilder()
        .withUrl(
          '${_baseUrlProvider.apiBaseUrl}$_hubPath',
          options: HttpConnectionOptions(accessTokenFactory: _getAccessToken),
        )
        .withAutomaticReconnect()
        .build();

    connection.on('newThermalData', _onNewThermalData);
    connection.onclose(({error}) {
      _logger.warning('ThermalDataHub connection closed: $error');
    });

    _connection = connection;
    try {
      await connection.start();
      if (_registeredMachineIds.isNotEmpty) {
        await _sendRegisterMachines(_registeredMachineIds.toList());
      }
    } catch (e) {
      _logger.error('Failed to connect to ThermalDataHub: $e');
      _connection = null;
    }
  }

  /// Registers interest in [machineIds] so the hub starts pushing
  /// `newThermalData` updates for them to this connection. Accumulates with
  /// any previously registered ids (matching `RegisterMachines`'s
  /// replace-the-list-for-this-connection server behavior).
  Future<void> registerMachines(Iterable<int> machineIds) async {
    _registeredMachineIds.addAll(machineIds);
    if (isConnected) {
      await _sendRegisterMachines(_registeredMachineIds.toList());
    }
  }

  Future<void> _sendRegisterMachines(List<int> machineIds) async {
    try {
      await _connection?.invoke('RegisterMachines', args: [machineIds]);
    } catch (e) {
      _logger.error('RegisterMachines invocation failed: $e');
    }
  }

  void _onNewThermalData(List<Object?>? arguments) {
    final payload = (arguments != null && arguments.isNotEmpty)
        ? arguments.first
        : null;
    if (payload is! Map) return;

    final updates = <MachineLevelUpdate>[];
    for (final entry in payload.values) {
      if (entry is! Map) continue;
      // Hub JSON uses PascalCase field names (no camelCase resolver is
      // configured for the SignalR protocol, unlike the REST API), so match
      // case-insensitively rather than assuming a specific casing.
      final map = entry.map(
        (key, value) => MapEntry(key.toString().toLowerCase(), value),
      );
      final rawId = map['id'];
      final key = map['key'];
      if (rawId == null || key == null) continue;

      updates.add(
        MachineLevelUpdate(
          id: rawId is num ? rawId.toInt() : int.tryParse('$rawId') ?? 0,
          key: key.toString(),
          deviceType: map['devicetype']?.toString() ?? '',
          level: _normalizeLevel(map['level']),
        ),
      );
    }
    if (updates.isNotEmpty) _updatesController.add(updates);
  }

  String _normalizeLevel(Object? raw) {
    if (raw is num) {
      final index = raw.toInt();
      if (index >= 0 && index < _levelNames.length) return _levelNames[index];
      return 'Undefined';
    }
    if (raw == null) return 'Undefined';
    return raw.toString();
  }

  /// Disconnects and forgets registered machine ids. Call when no screen
  /// needs realtime updates anymore (e.g. leaving the diagram screen).
  Future<void> disconnect() async {
    _registeredMachineIds.clear();
    final connection = _connection;
    _connection = null;
    try {
      await connection?.stop();
    } catch (e) {
      _logger.warning('Error stopping ThermalDataHub connection: $e');
    }
  }
}
