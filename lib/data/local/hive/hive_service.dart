import 'package:hive_flutter/hive_flutter.dart';

/// Singleton service to initialize Hive, register adapters and open boxes.
class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();

  /// Initialize Hive. Call this early in app startup.
  Future<void> init({String? path}) async {
    await Hive.initFlutter(path);
  }

  /// Register a TypeAdapter if not already registered.
  void registerAdapter(TypeAdapter adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  /// Open a box of type T. If already open, returns the existing box.
  Future<Box<T>> openBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box<T>(name);
    return await Hive.openBox<T>(name);
  }

  /// Check if a box is open.
  bool isBoxOpen(String name) => Hive.isBoxOpen(name);

  /// Close all boxes and Hive.
  Future<void> closeAll() async => Hive.close();
}
