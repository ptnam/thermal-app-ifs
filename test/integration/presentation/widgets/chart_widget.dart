/// =============================================================================
/// File: chart_widget.dart
/// Description: Live Preview cho Thermal Chart Widget
///
/// Purpose:
/// - Test chart widget với data thật từ API
/// - Tự động login và fetch data
/// - Hot reload support
///
/// Chạy: flutter run -t test/integration/presentation/widgets/chart_widget.dart
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:thermal_mobile/data/network/thermal_data/thermal_data_api_service.dart';
import 'package:thermal_mobile/data/network/thermal_data/dto/thermal_data_dto.dart';
import 'package:thermal_mobile/presentation/widgets/thermal_line_chart.dart';
import '../../config/test_client_factory.dart';
import '../../helpers/auth_helper.dart';

void main() {
  runApp(const ThermalChartPreviewApp());
}

class ThermalChartPreviewApp extends StatelessWidget {
  const ThermalChartPreviewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🔥 Thermal Chart Live Preview',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const ThermalChartPreviewPage(),
    );
  }
}

class ThermalChartPreviewPage extends StatefulWidget {
  const ThermalChartPreviewPage({Key? key}) : super(key: key);

  @override
  State<ThermalChartPreviewPage> createState() =>
      _ThermalChartPreviewPageState();
}

class _ThermalChartPreviewPageState extends State<ThermalChartPreviewPage> {
  late ThermalDataApiService _service;
  String? _accessToken;
  bool _isLoading = false;
  String? _error;
  ThermalDataMultiResponse? _chartData;

  // Test parameters từ integration test
  final int _areaId = 5;
  final List<int> _machineIds = [3];
  final List<int> _componentIds = [14, 15, 16];
  final String _reportDate = '2026-01-10';
  final String _startDate = '2026-01-08 00:00:00';
  final String _endDate = '2026-01-10 23:59:59';

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Initialize service
      _service = ThermalDataApiService(
        TestClientFactory.createApiClient(),
        TestClientFactory.createBaseUrlProvider(),
      );

      // Get access token
      _accessToken = await AuthHelper.getAccessToken();

      // Fetch data
      await _fetchData();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    if (_accessToken == null) {
      setState(() {
        _error = 'No access token';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getDetailThermalDataMulti(
        areaId: _areaId,
        machineIds: _machineIds,
        machineComponentIds: _componentIds,
        reportDate: _reportDate,
        startDate: _startDate,
        endDate: _endDate,
        userId: 1,
        accessToken: _accessToken!,
      );

      result.fold(
        onSuccess: (data) {
          setState(() {
            _chartData = data;
            _isLoading = false;
          });
        },
        onFailure: (error) {
          setState(() {
            _error = error.message ?? 'Unknown error';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Thermal Chart Live Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading data from API...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_chartData == null ||
        _chartData!.categories.isEmpty ||
        _chartData!.chartData.isEmpty) {
      return _buildNoDataState();
    }

    return _buildChartView();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No thermal data found for the selected period',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(),
        const SizedBox(height: 16),
        _buildDataSummary(),
        const SizedBox(height: 16),
        _buildChartCard(),
        const SizedBox(height: 16),
        _buildSeriesDetails(),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Test Parameters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Area ID', _areaId.toString()),
            _buildInfoRow('Machine IDs', _machineIds.toString()),
            _buildInfoRow('Component IDs', _componentIds.toString()),
            _buildInfoRow('Report Date', _reportDate),
            _buildInfoRow('Period', '$_startDate → $_endDate'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSummary() {
    final data = _chartData!;
    return Card(
      color: Colors.green.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Data Loaded Successfully',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildSummaryRow(
              '📅 Timestamps',
              '${data.categories.length}',
              data.categories.isNotEmpty
                  ? '${data.categories.first} → ${data.categories.last}'
                  : 'No data',
            ),
            _buildSummaryRow(
              '📈 Series',
              '${data.chartData.length}',
              data.chartData.map((s) => s.name).join(', '),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, String? detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                detail,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
              child: ThermalLineChart(
                categories: _chartData!.categories,
                series: _chartData!.chartData,
                showGrid: false,
                showLegend: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesDetails() {
    final data = _chartData!;
    if (data.chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Series Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            ...data.chartData.map((series) => _buildSeriesCard(series)),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesCard(ThermalChartSeries series) {
    if (series.data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('${series.name}: No data'),
      );
    }

    final min = series.data.reduce((a, b) => a < b ? a : b);
    final max = series.data.reduce((a, b) => a > b ? a : b);
    final avg = series.data.reduce((a, b) => a + b) / series.data.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            series.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip('📊 Points', '${series.data.length}'),
              _buildStatChip('❄️ Min', '${min.toStringAsFixed(1)}°C'),
              _buildStatChip('🔥 Max', '${max.toStringAsFixed(1)}°C'),
              _buildStatChip('📊 Avg', '${avg.toStringAsFixed(1)}°C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Chip(
      label: Text('$label: $value', style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
