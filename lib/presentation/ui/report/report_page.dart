import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:thermal_mobile/core/constants/icons.dart';
import 'package:thermal_mobile/data/network/thermal_data/dto/thermal_data_dto.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/presentation/bloc/machine/machine_settings_bloc.dart';
import 'package:thermal_mobile/presentation/bloc/machine/machine_settings_event.dart';
import 'package:thermal_mobile/presentation/bloc/machine/machine_settings_state.dart';
import 'package:thermal_mobile/presentation/bloc/thermal_data/thermal_data_bloc.dart';
import 'package:thermal_mobile/presentation/bloc/thermal_data/thermal_data_event.dart';
import 'package:thermal_mobile/presentation/bloc/thermal_data/thermal_data_state.dart';
import 'package:thermal_mobile/presentation/widgets/app_drawer_service.dart';
import 'package:thermal_mobile/presentation/widgets/thermal_line_chart.dart';
import 'package:thermal_mobile/presentation/widgets/notification_count_chart.dart';
import 'package:thermal_mobile/presentation/bloc/notification/notification_bloc.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  late final MachineSettingsBloc _machineSettingsBloc;
  late final ThermalDataBloc _thermalDataBloc;
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _machineSettingsBloc = getIt<MachineSettingsBloc>()
      ..add(LoadMachineSettingsEvent());
    _thermalDataBloc = getIt<ThermalDataBloc>();
    _notificationBloc = getIt<NotificationBloc>();

    // Load notification count for last 7 days
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    _notificationBloc.add(
      LoadNotificationCountEvent(startDate: sevenDaysAgo, endDate: now),
    );
  }

  @override
  void dispose() {
    _machineSettingsBloc.close();
    _thermalDataBloc.close();
    _notificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _machineSettingsBloc),
        BlocProvider.value(value: _thermalDataBloc),
        BlocProvider.value(value: _notificationBloc),
      ],
      child: BlocListener<MachineSettingsBloc, MachineSettingsState>(
        listener: (context, settingsState) {
          // When machine settings loaded, fetch thermal data
          if (settingsState.status == MachineSettingsStatus.success &&
              settingsState.settings != null) {
            final settings = settingsState.settings!;
            final now = DateTime.now();
            final twoDaysAgo = now.subtract(const Duration(days: 2));

            // Format dates
            final dateFormat = DateFormat('yyyy-MM-dd');
            final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
            final reportDate = dateFormat.format(now);
            final startDate = dateTimeFormat.format(twoDaysAgo);
            final endDate = dateTimeFormat.format(now);

            // Load multi thermal data with settings
            _thermalDataBloc.add(
              LoadDetailThermalDataMultiEvent(
                areaId: settings.areaId ?? 0,
                machineIds: settings.machineIds ?? [],
                machineComponentIds: settings.machineComponentIds ?? [],
                reportDate: reportDate,
                startDate: startDate,
                endDate: endDate,
                userId: settings.userId ?? 0,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                AppDrawerService.openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset(
                  AppIcons.icMenu,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            title: Text(
              'Báo cáo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            // bottom: const PreferredSize(
            //   preferredSize: Size.fromHeight(16),
            //   child: SizedBox.shrink(),
            // ),
          ),

          body: BlocBuilder<ThermalDataBloc, ThermalDataState>(
            builder: (context, thermalState) {
              return BlocBuilder<MachineSettingsBloc, MachineSettingsState>(
                builder: (context, settingsState) {
                  if (thermalState.multiDataStatus ==
                          ThermalDataStatus.success &&
                      thermalState.multiThermalData != null) {
                    final data = thermalState.multiThermalData!;

                    if (data.categories.isEmpty || data.chartData.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.insert_chart_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có dữ liệu',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chưa có dữ liệu nhiệt độ trong khoảng thời gian này',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Notification count chart

                            // Thermal line chart
                            ThermalLineChart(
                              categories: data.categories,
                              series: data.chartData
                                  .map(
                                    (s) => ThermalChartSeries(
                                      name: s.name,
                                      data: s.data,
                                    ),
                                  )
                                  .toList(),
                              showGrid: true,
                              showLegend: true,
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<NotificationBloc, NotificationState>(
                              builder: (context, notificationState) {
                                if (notificationState
                                    is NotificationCountLoaded) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: NotificationCountChart(
                                      counts: notificationState.counts,
                                      title: 'Tổng số cảnh báo',
                                      subtitle: '7 ngày qua',
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  // Show loading state
                  if (settingsState.status == MachineSettingsStatus.loading ||
                      thermalState.multiDataStatus ==
                          ThermalDataStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                      ),
                    );
                  }

                  // Show error state
                  if (settingsState.status == MachineSettingsStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Lỗi tải cài đặt máy',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            settingsState.errorMessage ?? 'Vui lòng thử lại',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _machineSettingsBloc.add(
                                LoadMachineSettingsEvent(),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (thermalState.multiDataStatus ==
                      ThermalDataStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Lỗi tải dữ liệu nhiệt độ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            thermalState.errorMessage ?? 'Vui lòng thử lại',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show chart when data is available

                  // Initial state - waiting for settings
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Đang tải cài đặt...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
