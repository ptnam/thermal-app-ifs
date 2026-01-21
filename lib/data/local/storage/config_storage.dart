import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý cấu hình domain và port
class ConfigStorage {
  static const String _keyDomain = 'app_domain';
  static const String _keyPort = 'app_port';
  static const String _keyStreamPort = 'app_stream_port';

  // Giá trị mặc định
  static const String defaultDomain = 'thermal.infosysvietnam.com.vn';
  static const String defaultPort = '10253';
  static const String defaultStreamPort = '1984';

  static const String _keySelectedAreaId = 'selected_area_id';
  static const String _keySelectedAreaName = 'selected_area_name';

  final SharedPreferences _prefs;

  ConfigStorage(this._prefs);

  /// Get selected area id (nullable)
  int? getSelectedAreaId() {
    return _prefs.getInt(_keySelectedAreaId);
  }

  /// Get selected area name (nullable)
  String? getSelectedAreaName() {
    return _prefs.getString(_keySelectedAreaName);
  }

  /// Save selected area
  Future<void> saveSelectedArea({required int id, required String name}) async {
    await Future.wait([
      _prefs.setInt(_keySelectedAreaId, id),
      _prefs.setString(_keySelectedAreaName, name),
    ]);
  }

  /// Clear selected area
  Future<void> clearSelectedArea() async {
    await Future.wait([
      _prefs.remove(_keySelectedAreaId),
      _prefs.remove(_keySelectedAreaName),
    ]);
  }
  /// Lấy domain đã lưu hoặc trả về mặc định
  String getDomain() {
    return _prefs.getString(_keyDomain) ?? defaultDomain;
  }

  /// Lấy port đã lưu hoặc trả về mặc định
  String getPort() {
    return _prefs.getString(_keyPort) ?? defaultPort;
  }

  /// Lấy stream port đã lưu hoặc trả về mặc định
  String getStreamPort() {
    return _prefs.getString(_keyStreamPort) ?? defaultStreamPort;
  }

  /// Lấy API base URL đầy đủ
  String getApiBaseUrl() {
    final domain = getDomain();
    final port = getPort();
    return 'https://$domain:$port';
  }

  /// Lấy Stream URL đầy đủ
  String getStreamUrl() {
    final domain = getDomain();
    final port = getStreamPort();
    return 'https://$domain:$port/api/stream.m3u8?src=';
  }

  /// Lưu domain
  Future<void> saveDomain(String domain) async {
    await _prefs.setString(_keyDomain, domain);
  }

  /// Lưu port
  Future<void> savePort(String port) async {
    await _prefs.setString(_keyPort, port);
  }

  /// Lưu stream port
  Future<void> saveStreamPort(String port) async {
    await _prefs.setString(_keyStreamPort, port);
  }

  /// Lưu toàn bộ cấu hình
  Future<void> saveConfig({
    required String domain,
    required String port,
    required String streamPort,
  }) async {
    await Future.wait([
      saveDomain(domain),
      savePort(port),
      saveStreamPort(streamPort),
    ]);
  }

  /// Reset về cấu hình mặc định
  Future<void> resetToDefault() async {
    await Future.wait([
      _prefs.remove(_keyDomain),
      _prefs.remove(_keyPort),
      _prefs.remove(_keyStreamPort),
    ]);
  }

  /// Kiểm tra có cấu hình tùy chỉnh không
  bool hasCustomConfig() {
    return _prefs.containsKey(_keyDomain) ||
        _prefs.containsKey(_keyPort) ||
        _prefs.containsKey(_keyStreamPort);
  }
}
