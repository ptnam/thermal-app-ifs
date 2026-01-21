import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_service.dart';

/// Generic repository for basic Hive CRUD and reactive helpers.
class HiveRepository<T> {
  final String boxName;
  Box<T>? _box;

  HiveRepository(this.boxName);

  /// Must call before using the repo (usually at app startup or before first use).
  Future<void> init() async {
    _box = await HiveService.instance.openBox<T>(boxName);
  }

  Box<T> get box {
    if (_box == null) throw Exception('Box $boxName not initialized. Call init() first.');
    return _box!;
  }

  Future<void> put(dynamic key, T value) => box.put(key, value);
  Future<void> putAll(Map<dynamic, T> entries) => box.putAll(entries);
  T? get(dynamic key) => box.get(key);
  bool containsKey(dynamic key) => box.containsKey(key);
  Future<void> delete(dynamic key) => box.delete(key);
  Future<void> clear() => box.clear();
  List<T> getAll() => box.values.cast<T>().toList();

  /// Watch for changes to a specific key or the whole box.
  Stream<BoxEvent> watch({dynamic key}) => box.watch(key: key);

  /// ValueListenable for use with ValueListenableBuilder.
  /// Provide a ValueListenable for UI widgets. Optionally pass specific keys to listen to.
  ValueListenable<Box<T>> listenable({List<dynamic>? keys}) => box.listenable(keys: keys);
}
