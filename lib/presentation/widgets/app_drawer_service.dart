import 'package:flutter/material.dart';

/// Service để mở drawer từ bất kỳ đâu trong app
/// Sử dụng GlobalKey để access scaffold state
class AppDrawerService {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// Mở drawer
  static void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  /// Đóng drawer
  static void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

  /// Kiểm tra drawer có đang mở không
  static bool isDrawerOpen() {
    return scaffoldKey.currentState?.isDrawerOpen ?? false;
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
