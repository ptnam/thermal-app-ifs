import 'package:flutter/material.dart';

/// Service để mở drawer từ bất kỳ đâu trong app
/// Sử dụng GlobalKey để access scaffold state
class AppDrawerService {
  static GlobalKey<ScaffoldState>? _scaffoldKey;

  static GlobalKey<ScaffoldState> createAndBindScaffoldKey() {
    final key = GlobalKey<ScaffoldState>();
    _scaffoldKey = key;
    return key;
  }

  static void unbindScaffoldKey(GlobalKey<ScaffoldState> key) {
    if (identical(_scaffoldKey, key)) {
      _scaffoldKey = null;
    }
  }

  /// Mở drawer
  static void openDrawer() {
    _scaffoldKey?.currentState?.openDrawer();
  }

  /// Đóng drawer
  static void closeDrawer() {
    _scaffoldKey?.currentState?.closeDrawer();
  }

  /// Kiểm tra drawer có đang mở không
  static bool isDrawerOpen() {
    return _scaffoldKey?.currentState?.isDrawerOpen ?? false;
  }

  /// Toggle drawer (mở/đóng)
  static void toggleDrawer() {
    if (isDrawerOpen()) {
      closeDrawer();
    } else {
      openDrawer();
    }
  }
}
