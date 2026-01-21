import 'package:hive/hive.dart';

/// Generic Hive storage for simple key-value data (strings, maps, etc.)
/// Use this as a template for storing any new data in Hive
class HiveStorage {
  final String boxName;

  HiveStorage(this.boxName);

  /// Open and get the Hive box
  Future<Box<dynamic>> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  /// Save data with a key
  Future<void> save<T>(String key, T value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  /// Read data by key
  Future<T?> read<T>(String key) async {
    final box = await _getBox();
    return box.get(key) as T?;
  }

  /// Delete data by key
  Future<void> delete(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  /// Clear all data in the box
  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }

  /// Save a JSON-serializable object (Map or List)
  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    final box = await _getBox();
    await box.put(key, json);
  }

  /// Read a JSON-serializable object
  Future<Map<String, dynamic>?> readJson(String key) async {
    final box = await _getBox();
    final value = box.get(key);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
