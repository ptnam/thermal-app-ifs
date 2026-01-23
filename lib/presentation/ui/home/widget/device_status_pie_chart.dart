import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/domain/models/machine_thermal_entity.dart';
import 'package:thermal_mobile/presentation/bloc/machine_thermal/machine_thermal_bloc.dart';

/// Enum for device evaluation status
enum DeviceStatus {
  good, // Tốt
  fair, // Khá
  average, // Trung bình
  bad, // Xấu
}

/// Widget displays pie chart of device status statistics
class DeviceStatusPieChart extends StatefulWidget {
  final int? areaId;

  const DeviceStatusPieChart({super.key, this.areaId});

  @override
  State<DeviceStatusPieChart> createState() => _DeviceStatusPieChartState();
}

class _DeviceStatusPieChartState extends State<DeviceStatusPieChart> {
  MachineThermalBloc? _bloc;

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.areaId == null) {
      return _buildNoAreaSelected();
    }

    return BlocProvider(
      create: (_) {
        _bloc = getIt<MachineThermalBloc>()
          ..add(LoadAreaThermalOverview(widget.areaId!));
        return _bloc!;
      },
      child: BlocBuilder<MachineThermalBloc, MachineThermalState>(
        builder: (context, state) {
          if (state is MachineThermalLoading) {
            return _buildLoading();
          }

          if (state is MachineThermalLoaded) {
            final machines = state.overview.machines;
            if (machines.isEmpty) {
              return _buildNoData();
            }

            // Calculate statistics - for now use simulated data based on temperature
            // In real implementation, this would use compareResultObject from API
            final stats = _calculateDeviceStatistics(machines);
            return _buildChart(stats);
          }

          if (state is MachineThermalError) {
            return _buildError(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Calculate device statistics based on evaluation results from API
  /// Each device gets the "lowest" (worst) status among all its components
  /// Devices without evaluation data default to "Good" status
  Map<DeviceStatus, int> _calculateDeviceStatistics(
      List<MachineThermalSummaryEntity> machines) {
    final stats = <DeviceStatus, int>{
      DeviceStatus.good: 0,
      DeviceStatus.fair: 0,
      DeviceStatus.average: 0,
      DeviceStatus.bad: 0,
    };

    for (final machine in machines) {
      // Get worst status from API evaluation results
      final worstCode = machine.worstStatusCode;
      final status = _codeToStatus(worstCode);
      stats[status] = (stats[status] ?? 0) + 1;
    }

    debugPrint(
        '📊 DeviceStatusPieChart: Stats calculated - Good: ${stats[DeviceStatus.good]}, Fair: ${stats[DeviceStatus.fair]}, Average: ${stats[DeviceStatus.average]}, Bad: ${stats[DeviceStatus.bad]}');
    return stats;
  }

  /// Convert API status code to DeviceStatus enum
  DeviceStatus _codeToStatus(String? code) {
    switch (code) {
      case 'Bad':
        return DeviceStatus.bad;
      case 'Warning':
        return DeviceStatus.average;
      case 'Fair':
        return DeviceStatus.fair;
      case 'Good':
        return DeviceStatus.good;
      default:
        return DeviceStatus.good; // Default to good if no data
    }
  }

  Widget _buildChart(Map<DeviceStatus, int> stats) {
    final total = stats.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return _buildNoData();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2332), Color(0xFF0F1419)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D3748), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Thống kê đánh giá - Tổng hợp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Chart and Legend
          Row(
            children: [
              // Pie chart
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _PieChartPainter(stats, total),
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      color: const Color(0xFF10B981),
                      label: 'Tốt',
                      count: stats[DeviceStatus.good] ?? 0,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: const Color(0xFF3B82F6),
                      label: 'Khá',
                      count: stats[DeviceStatus.fair] ?? 0,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: const Color(0xFFF59E0B),
                      label: 'Trung bình',
                      count: stats[DeviceStatus.average] ?? 0,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: const Color(0xFFEF4444),
                      label: 'Xấu',
                      count: stats[DeviceStatus.bad] ?? 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2332), Color(0xFF0F1419)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D3748), width: 1),
      ),
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF3B82F6),
          ),
        ),
      ),
    );
  }

  Widget _buildNoAreaSelected() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2332), Color(0xFF0F1419)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D3748), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn khu vực để xem thống kê',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2332), Color(0xFF0F1419)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D3748), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.devices_other,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Không có thiết bị trong khu vực này',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2332), Color(0xFF0F1419)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 8),
          Text(
            'Lỗi: $message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for pie chart
class _PieChartPainter extends CustomPainter {
  final Map<DeviceStatus, int> stats;
  final int total;

  _PieChartPainter(this.stats, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.55; // Donut chart

    // Colors for each status
    final colors = {
      DeviceStatus.good: const Color(0xFF10B981),
      DeviceStatus.fair: const Color(0xFF3B82F6),
      DeviceStatus.average: const Color(0xFFF59E0B),
      DeviceStatus.bad: const Color(0xFFEF4444),
    };

    if (total == 0) return;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    // Draw order: good, fair, average, bad
    final order = [
      DeviceStatus.good,
      DeviceStatus.fair,
      DeviceStatus.average,
      DeviceStatus.bad,
    ];

    for (final status in order) {
      final count = stats[status] ?? 0;
      if (count == 0) continue;

      final sweepAngle = (count / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = colors[status]!
        ..style = PaintingStyle.fill;

      // Draw arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw count label on the arc
      if (count > 0) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = (radius + innerRadius) / 2;
        final labelX = center.dx + labelRadius * math.cos(labelAngle);
        final labelY = center.dy + labelRadius * math.sin(labelAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelX - textPainter.width / 2,
            labelY - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle;
    }

    // Draw inner circle (donut hole)
    final holePaint = Paint()
      ..color = const Color(0xFF0F1419)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
