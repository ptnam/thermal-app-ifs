/// =============================================================================
/// File: notification_count_chart.dart
/// Description: Bar chart widget for notification count statistics
///
/// Purpose:
/// - Display weekly notification counts
/// - Show 7-day bar chart with labels
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:thermal_mobile/domain/models/notification.dart';
import 'package:intl/intl.dart';

/// Widget to display notification count statistics as a bar chart
class NotificationCountChart extends StatelessWidget {
  final List<NotificationCountEntity> counts;
  final String title;
  final String subtitle;

  const NotificationCountChart({
    super.key,
    required this.counts,
    this.title = 'Tổng số cảnh báo',
    this.subtitle = 'Tuần này',
  });

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1E2936), const Color(0xFF151B24)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart
          SizedBox(height: 200, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Find max value for scaling
    final maxCount = counts.fold<int>(
      0,
      (max, item) =>
          item.numberOfNotifications > max ? item.numberOfNotifications : max,
    );

    if (maxCount == 0) {
      return _buildEmptyState();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: counts.map((count) {
        final heightRatio = count.numberOfNotifications / maxCount;
        final label = _formatDateLabel(count.dataDate);
        final tooltipMessage = _buildTooltipMessage(count);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Tooltip(
              message: tooltipMessage,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2936),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF0288D1), width: 1),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              preferBelow: false,
              verticalOffset: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value label above bar
                  if (count.numberOfNotifications > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        count.numberOfNotifications.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  // Bar
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        height: (heightRatio * 140).clamp(4.0, 140.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF4FC3F7),
                              const Color(0xFF0288D1),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0288D1).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date label
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            'Không có dữ liệu',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Format date label (T2, T3, T4, T5, T6, T7, CN)
  String _formatDateLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final weekday = date.weekday;

      switch (weekday) {
        case DateTime.monday:
          return 'T2';
        case DateTime.tuesday:
          return 'T3';
        case DateTime.wednesday:
          return 'T4';
        case DateTime.thursday:
          return 'T5';
        case DateTime.friday:
          return 'T6';
        case DateTime.saturday:
          return 'T7';
        case DateTime.sunday:
          return 'CN';
        default:
          return DateFormat('dd/MM').format(date);
      }
    } catch (e) {
      return dateStr.substring(8, 10); // Return day only
    }
  }

  /// Build tooltip message for a bar
  String _buildTooltipMessage(NotificationCountEntity count) {
    try {
      final date = DateTime.parse(count.dataDate);
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      final weekdayLabel = _formatDateLabel(count.dataDate);
      return '$formattedDate ($weekdayLabel)\nTổng: ${count.numberOfNotifications} cảnh báo';
    } catch (e) {
      return '${count.dataDate}\nTổng: ${count.numberOfNotifications} cảnh báo';
    }
  }
}
