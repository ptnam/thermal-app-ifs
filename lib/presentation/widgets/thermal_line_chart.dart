/// =============================================================================
/// File: thermal_line_chart.dart
/// Description: Line chart widget for displaying thermal data
///
/// Purpose:
/// - Display multi-series thermal data over time
/// - Interactive chart with zoom and pan
/// - Color-coded temperature levels
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:thermal_mobile/data/network/thermal_data/dto/thermal_data_dto.dart';

/// Line chart widget for thermal data visualization
class ThermalLineChart extends StatefulWidget {
  final List<String> categories;
  final List<ThermalChartSeries> series;
  final String? title;
  final bool showGrid;
  final bool showLegend;

  const ThermalLineChart({
    super.key,
    required this.categories,
    required this.series,
    this.title,
    this.showGrid = false,
    this.showLegend = false,
  });

  @override
  State<ThermalLineChart> createState() => _ThermalLineChartState();
}

class _ThermalLineChartState extends State<ThermalLineChart> {
  // Predefined colors for series - matching the image style
  final List<Color> _seriesColors = [
    const Color(0xFF00D9FF), // Cyan/Light blue
    const Color(0xFFFFB800), // Orange/Yellow
    const Color(0xFF00FF88), // Green
    const Color(0xFFFF6B9D), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF4CAF50), // Light Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFFC107), // Amber
    const Color(0xFFE91E63), // Pink Red
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFFFF9800), // Orange
    const Color(0xFF009688), // Teal
    const Color(0xFFCDDC39), // Lime
    const Color(0xFF673AB7), // Deep Purple
    const Color(0xFFFFC0CB), // Light Pink
    const Color(0xFF00FFFF), // Aqua
    const Color(0xFFFFFF00), // Yellow
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty || widget.series.isEmpty) {
      return _buildEmptyState();
    }

    return _buildChart();
  }

  Widget _buildChart() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1A2332), const Color(0xFF0F1419)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.show_chart, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Biểu đồ nhiệt độ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Handle more options
                },
              ),
            ],
          ),
          Row(
            children: [
              // Fixed Y-axis labels
              _buildYAxisLabels(),
              // Zoomable chart
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 5.0,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: 400,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: widget.showGrid,
                              drawVerticalLine: true,
                              horizontalInterval: 5,
                              verticalInterval: widget.categories.length / 10,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.white.withOpacity(0.1),
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Colors.white.withOpacity(0.05),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  interval: _calculateTimeInterval(),
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 ||
                                        index >= widget.categories.length) {
                                      return const Text('');
                                    }

                                    final timeStr = widget.categories[index];
                                    final displayText = _formatTimeLabel(
                                      timeStr,
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        displayText,
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: (widget.categories.length - 1).toDouble(),
                            minY: _getMinY(),
                            maxY: _getMaxY(),
                            lineBarsData: _buildLineBars(),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                tooltipMargin: 8,
                                getTooltipItems: (touchedSpots) {
                                  if (touchedSpots.isEmpty) return [];

                                  // Get the datetime from the first spot's x position
                                  final index = touchedSpots.first.x.toInt();
                                  final datetime =
                                      index >= 0 &&
                                          index < widget.categories.length
                                      ? widget.categories[index]
                                      : '';

                                  return touchedSpots.asMap().entries.map((
                                    entry,
                                  ) {
                                    final spotIndex = entry.key;
                                    final spot = entry.value;
                                    final series = widget.series[spot.barIndex];
                                    final temp = spot.y.toStringAsFixed(1);
                                    final color = _getColorForIndex(
                                      spot.barIndex,
                                    );

                                    // First item includes datetime header
                                    if (spotIndex == 0) {
                                      return LineTooltipItem(
                                        '$datetime\n',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '● ',
                                            style: TextStyle(color: color),
                                          ),
                                          TextSpan(
                                            text: '${series.name} : ${temp}°C',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    // Other items without datetime
                                    return LineTooltipItem(
                                      '',
                                      const TextStyle(fontSize: 11),
                                      children: [
                                        TextSpan(
                                          text: '● ',
                                          style: TextStyle(color: color),
                                        ),
                                        TextSpan(
                                          text: '${series.name} : ${temp}°C',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabels() {
    final minY = _getMinY();
    final maxY = _getMaxY();
    final interval = 5.0;
    final labelCount = ((maxY - minY) / interval).ceil() + 1;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 40,
        height: 370, // Chart height (400) - bottom axis space (30)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(labelCount, (index) {
            final value = maxY - (index * interval);
            return Text(
              '${value.toInt()}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
            );
          }),
        ),
      ),
    );
  }

  double _calculateTimeInterval() {
    // Show only key time markers (5-8 labels total)
    final dataPoints = widget.categories.length;

    // Target: Show approximately 6 major time markers
    return (dataPoints / 6).ceilToDouble().clamp(1, dataPoints.toDouble());
  }

  String _formatTimeLabel(String timeStr) {
    try {
      // Parse datetime string
      final DateTime dt = DateTime.parse(timeStr);

      // Calculate time span between first and last data point
      if (widget.categories.length < 2) {
        return timeStr.split(' ').length > 1
            ? timeStr.split(' ')[1].substring(0, 5)
            : timeStr;
      }

      final DateTime firstDt = DateTime.parse(widget.categories.first);
      final DateTime lastDt = DateTime.parse(widget.categories.last);
      final Duration span = lastDt.difference(firstDt);

      // Format based on time span
      if (span.inHours < 24) {
        // Less than 1 day: Show time only (HH:mm)
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (span.inDays <= 7) {
        // 1-7 days: Show day/month and time
        return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else {
        // More than 7 days: Show date only (dd/MM)
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Fallback to original format if parsing fails
      return timeStr.split(' ').length > 1
          ? timeStr.split(' ')[1].substring(0, 5)
          : timeStr;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  List<LineChartBarData> _buildLineBars() {
    return widget.series.asMap().entries.map((entry) {
      final index = entry.key;
      final series = entry.value;
      final color = _getColorForIndex(index);

      return LineChartBarData(
        spots: series.data.asMap().entries.map((dataEntry) {
          return FlSpot(dataEntry.key.toDouble(), dataEntry.value);
        }).toList(),
        isCurved: true,
        curveSmoothness: 0.35,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: false, // Hide dots for cleaner look like the image
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
          ),
        ),
      );
    }).toList();
  }

  Color _getColorForIndex(int index) {
    // Use predefined colors if available
    if (index < _seriesColors.length) {
      return _seriesColors[index];
    }

    // Generate dynamic colors using HSL for indices beyond predefined colors
    // This ensures unlimited series support with visually distinct colors
    final hue =
        (index * 137.5) % 360; // Golden angle for good color distribution
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  double _getMinY() {
    if (widget.series.isEmpty) return 0;

    double min = double.infinity;
    for (final series in widget.series) {
      if (series.data.isNotEmpty) {
        final seriesMin = series.data.reduce((a, b) => a < b ? a : b);
        if (seriesMin < min) min = seriesMin;
      }
    }

    // Add padding below min
    return (min - 5).floorToDouble();
  }

  double _getMaxY() {
    if (widget.series.isEmpty) return 100;

    double max = double.negativeInfinity;
    for (final series in widget.series) {
      if (series.data.isNotEmpty) {
        final seriesMax = series.data.reduce((a, b) => a > b ? a : b);
        if (seriesMax > max) max = seriesMax;
      }
    }

    // Add padding above max
    return (max + 5).ceilToDouble();
  }
}
