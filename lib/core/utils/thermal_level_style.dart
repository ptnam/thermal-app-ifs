import 'package:flutter/material.dart';

/// Maps a machine/component's raw `level` string (backend's
/// `TemperatureLevel` enum: Undefined / Good / Fair / Average / Bad — see
/// [MachineResultEntity.level]) to a display color and Vietnamese label, so
/// the diagram screen's device pins (and anywhere else showing device
/// health) use one consistent visual language.
///
/// Colors reused from the existing status legend in
/// `device_status_pie_chart.dart` to stay consistent with the rest of the
/// app: green = good, blue = fair, yellow = average, red = bad.
class ThermalLevelStyle {
  const ThermalLevelStyle._(this.color, this.label);

  final Color color;
  final String label;

  static const _undefined = ThermalLevelStyle._(
    Color(0xFF94A3B8),
    'Không xác định',
  );
  static const _good = ThermalLevelStyle._(Color(0xFF10B981), 'Tốt');
  static const _fair = ThermalLevelStyle._(Color(0xFF3B82F6), 'Khá');
  static const _average = ThermalLevelStyle._(
    Color(0xFFF59E0B),
    'Trung bình',
  );
  static const _bad = ThermalLevelStyle._(Color(0xFFEF4444), 'Xấu');

  /// [treatUndefinedAsGood]: the summary `machinesAndResultByArea` endpoint
  /// (used for pin colors) only ever sets `level` to "Bad" when a threshold
  /// is breached, leaving it at the default "Undefined" otherwise — it never
  /// actually reports "Good"/"Fair"/"Average". So for that source, an
  /// "Undefined" level means "no problem found", not "unknown", and should
  /// read as green rather than grey. The detailed `thermalByComponent`
  /// endpoint does report the real level, so leave this false there.
  static ThermalLevelStyle of(String? level, {bool treatUndefinedAsGood = false}) {
    final normalized = level?.toLowerCase();
    if (treatUndefinedAsGood &&
        (normalized == null || normalized.isEmpty || normalized == 'undefined')) {
      return _good;
    }
    switch (normalized) {
      case 'good':
        return _good;
      case 'fair':
        return _fair;
      case 'average':
        return _average;
      case 'bad':
        return _bad;
      default:
        return _undefined;
    }
  }
}
