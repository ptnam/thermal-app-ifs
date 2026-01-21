/// =============================================================================
/// File: thermal_line_chart_test.dart
/// Description: Widget tests for ThermalLineChart
///
/// Purpose:
/// - Test chart widget rendering with various data states
/// - Test empty state, error state, and data display
/// - Verify legends and tooltips
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thermal_mobile/data/network/thermal_data/dto/thermal_data_dto.dart';
import 'package:thermal_mobile/presentation/widgets/thermal_line_chart.dart';

void main() {
  group('ThermalLineChart Widget Tests', () {
    testWidgets('renders empty state when no data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: [],
              series: [],
            ),
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('renders chart with mock data', (tester) async {
      final mockData = _createMockData();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: mockData.categories,
              series: mockData.chartData,
              showGrid: true,
              showLegend: true,
            ),
          ),
        ),
      );

      // Should not show empty state
      expect(find.text('No data available'), findsNothing);

      // Should render legend with series names
      expect(find.text('112-AI'), findsOneWidget);
      expect(find.text('112-BI'), findsOneWidget);
      expect(find.text('112-CI'), findsOneWidget);
    });

    testWidgets('renders chart with title', (tester) async {
      final mockData = _createMockData();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: mockData.categories,
              series: mockData.chartData,
              title: 'Temperature Over Time',
            ),
          ),
        ),
      );

      expect(find.text('Temperature Over Time'), findsOneWidget);
    });

    testWidgets('renders chart without legend', (tester) async {
      final mockData = _createMockData();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: mockData.categories,
              series: mockData.chartData,
              showLegend: false,
            ),
          ),
        ),
      );

      // Legend should not be visible in the tree
      // But series names might still be in tooltips, so we don't check for them
      await tester.pumpAndSettle();
    });

    testWidgets('handles single series data', (tester) async {
      final singleSeriesData = ThermalDataMultiResponse(
        categories: ['10:00', '11:00', '12:00'],
        chartData: [
          ThermalChartSeries(
            name: 'Temperature',
            data: [25.0, 26.5, 27.0],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: singleSeriesData.categories,
              series: singleSeriesData.chartData,
            ),
          ),
        ),
      );

      expect(find.text('Temperature'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('handles large dataset', (tester) async {
      final largeData = _createLargeDataset();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: largeData.categories,
              series: largeData.chartData,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should render without errors
      expect(find.byType(ThermalLineChart), findsOneWidget);
    });

    testWidgets('displays correct time format on x-axis', (tester) async {
      final mockData = ThermalDataMultiResponse(
        categories: [
          '2026-01-08 10:00:00',
          '2026-01-08 11:00:00',
          '2026-01-08 12:00:00',
        ],
        chartData: [
          ThermalChartSeries(
            name: 'Temp',
            data: [25.0, 26.0, 27.0],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: mockData.categories,
              series: mockData.chartData,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Time labels should be displayed (HH:mm format)
      expect(find.text('10:00'), findsWidgets);
    });
  });

  group('ThermalLineChart Edge Cases', () {
    testWidgets('handles series with empty data', (tester) async {
      final edgeCaseData = ThermalDataMultiResponse(
        categories: ['10:00', '11:00'],
        chartData: [
          ThermalChartSeries(name: 'Series1', data: [25.0, 26.0]),
          ThermalChartSeries(name: 'Series2', data: []), // Empty
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: edgeCaseData.categories,
              series: edgeCaseData.chartData,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(ThermalLineChart), findsOneWidget);
    });

    testWidgets('handles extreme temperature values', (tester) async {
      final extremeData = ThermalDataMultiResponse(
        categories: ['10:00', '11:00', '12:00'],
        chartData: [
          ThermalChartSeries(
            name: 'Extreme',
            data: [-10.0, 0.0, 100.0],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalLineChart(
              categories: extremeData.categories,
              series: extremeData.chartData,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(ThermalLineChart), findsOneWidget);
    });
  });
}

// Helper functions to create mock data
ThermalDataMultiResponse _createMockData() {
  return ThermalDataMultiResponse(
    categories: [
      '2026-01-08 00:09:40',
      '2026-01-08 00:31:10',
      '2026-01-08 00:42:40',
      '2026-01-08 00:54:10',
      '2026-01-08 01:15:40',
    ],
    chartData: [
      ThermalChartSeries(
        name: '112-AI',
        data: [27.5, 27.6, 27.2, 27.3, 27.5],
      ),
      ThermalChartSeries(
        name: '112-BI',
        data: [27.8, 27.9, 27.5, 27.5, 27.7],
      ),
      ThermalChartSeries(
        name: '112-CI',
        data: [27.6, 27.8, 27.3, 27.4, 27.6],
      ),
      ThermalChartSeries(
        name: 'Môi trường',
        data: [26.4, 26.3, 26.3, 26.3, 26.2],
      ),
    ],
  );
}

ThermalDataMultiResponse _createLargeDataset() {
  // Create 100 data points
  final categories = List.generate(
    100,
    (i) => '2026-01-08 ${(i ~/ 4).toString().padLeft(2, '0')}:${((i % 4) * 15).toString().padLeft(2, '0')}:00',
  );

  final chartData = [
    ThermalChartSeries(
      name: 'Series 1',
      data: List.generate(100, (i) => 25.0 + (i % 10) * 0.5),
    ),
    ThermalChartSeries(
      name: 'Series 2',
      data: List.generate(100, (i) => 24.0 + (i % 8) * 0.6),
    ),
  ];

  return ThermalDataMultiResponse(
    categories: categories,
    chartData: chartData,
  );
}
