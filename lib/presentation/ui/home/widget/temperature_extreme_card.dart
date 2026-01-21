import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/domain/models/machine_thermal_entity.dart';
import 'package:thermal_mobile/presentation/bloc/machine_thermal/machine_thermal_bloc.dart';

class TemperatureExtremeCard extends StatefulWidget {
  final int? areaId;

  const TemperatureExtremeCard({super.key, this.areaId});

  @override
  State<TemperatureExtremeCard> createState() => _TemperatureExtremeCardState();
}

class _TemperatureExtremeCardState extends State<TemperatureExtremeCard> {
  Timer? _refreshTimer;
  MachineThermalBloc? _bloc;
  
  // Cache last successful data
  MachineThermalSummaryEntity? _lastHottest;
  MachineThermalSummaryEntity? _lastColdest;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void didUpdateWidget(TemperatureExtremeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.areaId != widget.areaId) {
      _restartAutoRefresh();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (widget.areaId != null) {
      // Refresh every 1 minute
      _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        print(
          '🔄 TemperatureExtremeCard: Auto-refreshing data for areaId=${widget.areaId}',
        );
        _bloc?.add(LoadAreaThermalOverview(widget.areaId!));
      });
    }
  }

  void _restartAutoRefresh() {
    _refreshTimer?.cancel();
    _startAutoRefresh();
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 TemperatureExtremeCard: build with areaId=${widget.areaId}');

    if (widget.areaId == null) {
      print('⚠️ TemperatureExtremeCard: areaId is null, showing placeholder');
      return const SizedBox.shrink();
    }

    print(
      '✅ TemperatureExtremeCard: Creating BLoC and dispatching LoadAreaThermalOverview(areaId=${widget.areaId})',
    );

    return BlocProvider(
      create: (_) {
        _bloc = getIt<MachineThermalBloc>()
          ..add(LoadAreaThermalOverview(widget.areaId!));
        return _bloc!;
      },
      child: BlocBuilder<MachineThermalBloc, MachineThermalState>(
        buildWhen: (previous, current) {
          // Only rebuild when we get new data (Loaded state)
          // Don't rebuild during Loading if we already have cached data
          if (current is MachineThermalLoading && _lastHottest != null) {
            return false;
          }
          return current is MachineThermalLoaded || current is MachineThermalError;
        },
        builder: (context, state) {
          // Update cached data when new data arrives
          if (state is MachineThermalLoaded) {
            _lastHottest = state.overview.hottestMachine;
            _lastColdest = state.overview.coldestMachine;
          }

          // Use cached data (always show last known data, no loading state)
          final hottest = _lastHottest;
          final coldest = _lastColdest;

          // Show nothing if no data at all (first load and no data)
          if (hottest == null && coldest == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (hottest != null)
                  Expanded(
                    child: _TemperatureItem(
                      icon: '🔥',
                      label: 'Cao nhất',
                      temperature: hottest.maxTemperature,
                      machineName: hottest.machine.name,
                      color: Colors.red,
                    ),
                  ),
                if (hottest != null && coldest != null)
                  const SizedBox(width: 12),
                if (coldest != null)
                  Expanded(
                    child: _TemperatureItem(
                      icon: '❄️',
                      label: 'Thấp nhất',
                      temperature: coldest.minTemperature,
                      machineName: coldest.machine.name,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TemperatureItem extends StatelessWidget {
  final String icon;
  final String label;
  final double? temperature;
  final String machineName;
  final Color color;

  const _TemperatureItem({
    required this.icon,
    required this.label,
    required this.temperature,
    required this.machineName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHot = icon == '🔥';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHot
              ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
              : [const Color(0xFF1E3A5F), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHot
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : const Color(0xFF3B82F6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isHot
                  ? const Color(0xFFEF4444).withOpacity(0.15)
                  : const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                isHot ? Icons.local_fire_department : Icons.ac_unit,
                color: isHot
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF3B82F6),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Temperature
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              key: ValueKey(temperature),
              temperature != null ? '${temperature!.toStringAsFixed(1)}°C' : '--°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          // Machine name
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              key: ValueKey(machineName),
              machineName,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
