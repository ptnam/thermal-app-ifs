import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/presentation/bloc/thermal_data/thermal_data_bloc.dart';
import 'package:thermal_mobile/presentation/bloc/thermal_data/thermal_data_state.dart';
import 'package:thermal_mobile/presentation/bloc/thermal_data/thermal_data_event.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/data/local/storage/config_storage.dart';

class EnvironmentTemperatureCard extends StatefulWidget {
  const EnvironmentTemperatureCard({super.key});

  @override
  State<EnvironmentTemperatureCard> createState() => _EnvironmentTemperatureCardState();
}

class _EnvironmentTemperatureCardState extends State<EnvironmentTemperatureCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Periodic refresh every 1 minute (no immediate duplicate fetch — initial load is driven by Home)
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshEnvironment();
    });
  }

  Future<void> _refreshEnvironment() async {
    try {
      final areaId = getIt<ConfigStorage>().getSelectedAreaId();
      debugPrint('EnvironmentTemperatureCard: refresh called - selectedAreaId=$areaId');
      if (areaId != null) {
        try {
          // prefer the bloc from the widget tree
          context.read<ThermalDataBloc>().add(LoadEnvironmentThermalEvent(areaId: areaId));
          debugPrint('EnvironmentTemperatureCard: dispatched via context bloc for area $areaId');
        } catch (e) {
          // fallback to global instance if provider not found
          debugPrint('EnvironmentTemperatureCard: context.read failed ($e), using getIt');
          getIt<ThermalDataBloc>().add(LoadEnvironmentThermalEvent(areaId: areaId));
        }
      } else {
        debugPrint('EnvironmentTemperatureCard: no selected area id available');
      }
    } catch (e) {
      debugPrint('EnvironmentTemperatureCard: exception in refresh: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThermalDataBloc, ThermalDataState>(
      builder: (context, state) {
        final temp = state.environmentData?.temperature;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.menuBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.red.shade700.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.thermostat, color: Colors.red, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nhiệt độ Môi trường',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
              // Optionally show a small indicator for frequency
              Text(
                temp != null
                    ? '${temp.toStringAsFixed(1)}°C'
                    : (state.environmentStatus == ThermalDataStatus.loading
                          ? 'Đang tải...'
                          : '—'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
