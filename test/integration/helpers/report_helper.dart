/// =============================================================================
/// File: report_helper.dart
/// Description: Helper để tạo báo cáo test tự động
///
/// Tạo file report markdown cho mỗi test case với thông tin chi tiết
/// =============================================================================

import 'dart:io';
import 'package:intl/intl.dart';

class ReportHelper {
  static const String _reportsDir = 'test_reports';
  
  /// Tạo báo cáo test cho một API endpoint
  static Future<void> createReport({
    required String groupName,
    required String testName,
    required String description,
    required bool isSuccess,
    required Map<String, dynamic> requestInfo,
    dynamic responseData,
    String? errorMessage,
    Duration? duration,
  }) async {
    try {
      // Tạo folder structure
      final groupFolder = '$_reportsDir/$groupName';
      final directory = Directory(groupFolder);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Tạo tên file với timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '${testName}_$timestamp.md';
      final filePath = '$groupFolder/$fileName';

      // Tạo nội dung báo cáo
      final content = _generateReportContent(
        testName: testName,
        description: description,
        isSuccess: isSuccess,
        requestInfo: requestInfo,
        responseData: responseData,
        errorMessage: errorMessage,
        duration: duration,
      );

      // Ghi file
      final file = File(filePath);
      await file.writeAsString(content);

      print('📝 Đã tạo báo cáo: $filePath');
    } catch (e) {
      print('❌ Lỗi khi tạo báo cáo: $e');
    }
  }

  static String _generateReportContent({
    required String testName,
    required String description,
    required bool isSuccess,
    required Map<String, dynamic> requestInfo,
    dynamic responseData,
    String? errorMessage,
    Duration? duration,
  }) {
    final buffer = StringBuffer();
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    // Header
    buffer.writeln('# 📊 BÁO CÁO TEST API');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    // Thông tin cơ bản
    buffer.writeln('## 📋 Thông Tin Test');
    buffer.writeln();
    buffer.writeln('| Thuộc tính | Giá trị |');
    buffer.writeln('|------------|---------|');
    buffer.writeln('| **Tên test** | $testName |');
    buffer.writeln('| **Thời gian** | $now |');
    buffer.writeln('| **Kết quả** | ${isSuccess ? '✅ THÀNH CÔNG' : '❌ THẤT BẠI'} |');
    if (duration != null) {
      buffer.writeln('| **Thời gian thực thi** | ${duration.inMilliseconds}ms |');
    }
    buffer.writeln();

    // Mô tả chức năng
    buffer.writeln('## 📝 Mô Tả Chức Năng');
    buffer.writeln();
    buffer.writeln(description);
    buffer.writeln();

    // Thông tin request
    buffer.writeln('## 📤 Thông Tin Request');
    buffer.writeln();
    buffer.writeln('```json');
    buffer.writeln(_formatJson(requestInfo));
    buffer.writeln('```');
    buffer.writeln();

    // Kết quả
    if (isSuccess) {
      buffer.writeln('## ✅ Kết Quả Thành Công');
      buffer.writeln();
      
      if (responseData != null) {
        buffer.writeln('### 📦 Dữ Liệu Trả Về');
        buffer.writeln();
        buffer.writeln('```json');
        buffer.writeln(_formatResponseData(responseData));
        buffer.writeln('```');
      }
    } else {
      buffer.writeln('## ❌ Lỗi');
      buffer.writeln();
      buffer.writeln('```');
      buffer.writeln(errorMessage ?? 'Không có thông tin lỗi');
      buffer.writeln('```');
    }
    buffer.writeln();

    // Footer
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('*Báo cáo tự động được tạo bởi Integration Test*');

    return buffer.toString();
  }

  static String _formatJson(Map<String, dynamic> json, {int indent = 2}) {
    final buffer = StringBuffer();
    final spaces = ' ' * indent;
    buffer.writeln('{');
    
    final entries = json.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isLast = i == entries.length - 1;
      final comma = isLast ? '' : ',';
      
      if (entry.value is List) {
        final list = entry.value as List;
        if (list.isEmpty) {
          buffer.writeln('$spaces"${entry.key}": []$comma');
        } else {
          buffer.writeln('$spaces"${entry.key}": [');
          // Hiển thị TẤT CẢ items, không giới hạn
          for (var j = 0; j < list.length; j++) {
            final item = list[j];
            final itemComma = j == list.length - 1 ? '' : ',';
            if (item is Map) {
              final formattedMap = _formatJsonRecursive(item as Map<String, dynamic>, indent: indent + 2);
              buffer.write('$spaces  ');
              buffer.write(formattedMap.trim());
              buffer.writeln(itemComma);
            } else {
              buffer.writeln('$spaces  ${_formatValue(item)}$itemComma');
            }
          }
          buffer.writeln('$spaces]$comma');
        }
      } else if (entry.value is Map) {
        final map = entry.value as Map<String, dynamic>;
        final formattedMap = _formatJsonRecursive(map, indent: indent);
        buffer.write('$spaces"${entry.key}": ');
        buffer.write(formattedMap.trim());
        buffer.writeln(comma);
      } else {
        buffer.writeln('$spaces"${entry.key}": ${_formatValue(entry.value)}$comma');
      }
    }
    
    buffer.writeln('}');
    return buffer.toString();
  }

  static String _formatJsonRecursive(Map<String, dynamic> json, {int indent = 2}) {
    final buffer = StringBuffer();
    final spaces = ' ' * indent;
    buffer.writeln('{');
    
    final entries = json.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isLast = i == entries.length - 1;
      final comma = isLast ? '' : ',';
      
      if (entry.value is Map) {
        final nested = _formatJsonRecursive(entry.value as Map<String, dynamic>, indent: indent + 2);
        buffer.write('$spaces  "${entry.key}": ');
        buffer.write(nested.trim());
        buffer.writeln(comma);
      } else if (entry.value is List) {
        final list = entry.value as List;
        if (list.isEmpty) {
          buffer.writeln('$spaces  "${entry.key}": []$comma');
        } else {
          buffer.writeln('$spaces  "${entry.key}": [');
          for (var j = 0; j < list.length; j++) {
            final item = list[j];
            final itemComma = j == list.length - 1 ? '' : ',';
            buffer.writeln('$spaces    ${_formatValue(item)}$itemComma');
          }
          buffer.writeln('$spaces  ]$comma');
        }
      } else {
        buffer.writeln('$spaces  "${entry.key}": ${_formatValue(entry.value)}$comma');
      }
    }
    
    buffer.writeln('$spaces}');
    return buffer.toString();
  }

  static String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    return '"$value"';
  }

  static String _formatMapInline(Map<String, dynamic> map) {
    final entries = map.entries.map((e) => '"${e.key}": ${_formatValue(e.value)}').join(', ');
    return '{ $entries }';
  }

  static String _formatResponseData(dynamic data) {
    if (data == null) return 'null';
    
    if (data is Map) {
      return _formatJson(data as Map<String, dynamic>);
    }
    
    if (data is List) {
      if (data.isEmpty) return '[]';
      
      final buffer = StringBuffer();
      buffer.writeln('[');
      
      // Hiển thị TẤT CẢ items, không giới hạn
      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        final comma = i == data.length - 1 ? '' : ',';
        if (item is Map) {
          final formattedMap = _formatJsonRecursive(item as Map<String, dynamic>, indent: 2);
          buffer.write('  ');
          buffer.write(formattedMap.trim());
          buffer.writeln(comma);
        } else {
          buffer.writeln('  ${_formatValue(item)}$comma');
        }
      }
      
      buffer.writeln(']');
      return buffer.toString();
    }
    
    return data.toString();
  }

  /// Tạo báo cáo tổng hợp cho một nhóm test
  static Future<void> createSummaryReport({
    required String groupName,
    required String groupDescription,
    required List<TestResult> results,
  }) async {
    try {
      final groupFolder = '$_reportsDir/$groupName';
      final directory = Directory(groupFolder);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '_SUMMARY_$timestamp.md';
      final filePath = '$groupFolder/$fileName';

      final content = _generateSummaryContent(
        groupName: groupName,
        groupDescription: groupDescription,
        results: results,
      );

      final file = File(filePath);
      await file.writeAsString(content);

      print('📊 Đã tạo báo cáo tổng hợp: $filePath');
    } catch (e) {
      print('❌ Lỗi khi tạo báo cáo tổng hợp: $e');
    }
  }

  static String _generateSummaryContent({
    required String groupName,
    required String groupDescription,
    required List<TestResult> results,
  }) {
    final buffer = StringBuffer();
    final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final successCount = results.where((r) => r.isSuccess).length;
    final failCount = results.length - successCount;

    buffer.writeln('# 📊 BÁO CÁO TỔNG HỢP - $groupName');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    buffer.writeln('## 📋 Thông Tin Chung');
    buffer.writeln();
    buffer.writeln('| Thuộc tính | Giá trị |');
    buffer.writeln('|------------|---------|');
    buffer.writeln('| **Thời gian** | $now |');
    buffer.writeln('| **Tổng số test** | ${results.length} |');
    buffer.writeln('| **Thành công** | ✅ $successCount |');
    buffer.writeln('| **Thất bại** | ❌ $failCount |');
    buffer.writeln('| **Tỷ lệ thành công** | ${((successCount / results.length) * 100).toStringAsFixed(1)}% |');
    buffer.writeln();

    buffer.writeln('## 📝 Mô Tả Nhóm Chức Năng');
    buffer.writeln();
    buffer.writeln(groupDescription);
    buffer.writeln();

    buffer.writeln('## 📊 Chi Tiết Kết Quả');
    buffer.writeln();
    buffer.writeln('| # | Tên Test | Kết Quả | Thời Gian |');
    buffer.writeln('|---|----------|---------|-----------|');
    
    for (var i = 0; i < results.length; i++) {
      final result = results[i];
      final status = result.isSuccess ? '✅' : '❌';
      final duration = result.duration != null 
          ? '${result.duration!.inMilliseconds}ms' 
          : '-';
      buffer.writeln('| ${i + 1} | ${result.testName} | $status | $duration |');
    }
    buffer.writeln();

    if (failCount > 0) {
      buffer.writeln('## ⚠️ Các Test Thất Bại');
      buffer.writeln();
      final failures = results.where((r) => !r.isSuccess).toList();
      for (var failure in failures) {
        buffer.writeln('### ❌ ${failure.testName}');
        buffer.writeln();
        buffer.writeln('**Lỗi:** ${failure.errorMessage ?? 'Không rõ'}');
        buffer.writeln();
      }
    }

    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('*Báo cáo tổng hợp tự động được tạo bởi Integration Test*');

    return buffer.toString();
  }
}

/// Class lưu trữ kết quả test
class TestResult {
  final String testName;
  final bool isSuccess;
  final Duration? duration;
  final String? errorMessage;

  TestResult({
    required this.testName,
    required this.isSuccess,
    this.duration,
    this.errorMessage,
  });
}
