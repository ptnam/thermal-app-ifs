import 'package:thermal_mobile/data/network/area/area_api_service.dart';
import 'package:thermal_mobile/data/network/machine/machine_api_service.dart';
import 'package:thermal_mobile/data/network/camera/camera_api_service.dart';
import 'package:thermal_mobile/data/network/warning_event/warning_event_api_service.dart';
import 'package:thermal_mobile/data/network/warning_event/dto/warning_event_dto.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/camera/dto/camera_dto.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/constants/icons.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/domain/usecases/vision_notification_usecase.dart';
import 'package:thermal_mobile/presentation/bloc/notification/notification_bloc.dart';
import 'package:thermal_mobile/presentation/bloc/vision_notification/vision_notification_bloc.dart';
import 'package:thermal_mobile/presentation/widgets/app_drawer_service.dart';
import '../vision_notification/vision_notification_detail_screen.dart';
import 'notification_list_page.dart';

import 'package:thermal_mobile/presentation/notification/dialogs/temperature_filter_dialog.dart';
import 'package:thermal_mobile/presentation/notification/dialogs/ai_warning_filter_dialog.dart';
import 'package:thermal_mobile/presentation/models/filter_params.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<String> _getAccessToken() async {
    final getAccessToken = getIt<GetAccessToken>();
    return await getAccessToken();
  }

  Future<List<DropdownMenuItem<int>>> _getAreaItems() async {
    final accessToken = await _getAccessToken();
    final service = getIt<AreaApiService>();
    final result = await service.getAllAreas(accessToken: accessToken);
    final list = result.data ?? <ShortenBaseDto>[];
    return list
        .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
        .toList();
  }

  Future<List<DropdownMenuItem<int>>> _getMachineItems(int? areaId) async {
    final accessToken = await _getAccessToken();
    final service = getIt<MachineApiService>();
    final result = await service.getAll(
      accessToken: accessToken,
      areaId: areaId,
    );
    final list = result.data ?? <ShortenBaseDto>[];
    return list
        .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
        .toList();
  }

  Future<List<DropdownMenuItem<int>>> _getCameraItems(int? areaId) async {
    final accessToken = await _getAccessToken();
    final service = getIt<CameraApiService>();
    final result = await service.getAllShorten(
      accessToken: accessToken,
      areaId: areaId,
    );
    final list = result.data ?? <CameraShortenDto>[];
    return list
        .map(
          (e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name ?? '')),
        )
        .toList();
  }

  Future<List<DropdownMenuItem<int>>> _getWarningEventItems() async {
    final accessToken = await _getAccessToken();
    final service = getIt<WarningEventApiService>();
    final result = await service.getAllWarningEvents(
      accessToken: accessToken,
      warningType: 2,
    );
    final list = result.data?.data ?? <WarningEventDto>[];
    return list
        .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
        .toList();
  }

  TemperatureFilterParams _temperatureFilter =
      TemperatureFilterParams.defaultFilter();
  AIWarningFilterParams _aiWarningFilter =
      AIWarningFilterParams.defaultFilter();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48 + 8 + 1),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.line.withOpacity(0.32),
                  width: 1,
                ),
              ),
            ),
            child: AppBar(
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
                'Sự cố',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                Builder(
                  builder: (context) {
                    final tabIndex =
                        DefaultTabController.of(context)?.index ?? 0;
                    return IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () async {
                        if (tabIndex == 0) {
                          final areaItems = await _getAreaItems();
                          final machineItems = await _getMachineItems(
                            _temperatureFilter.areaId,
                          );
                          final result =
                              await showDialog<TemperatureFilterParams>(
                                context: context,
                                builder: (context) => TemperatureFilterDialog(
                                  initialParams: _temperatureFilter,
                                  areaItems: areaItems,
                                  machineItems: machineItems,
                                ),
                              );
                          if (result != null) {
                            setState(() => _temperatureFilter = result);
                            // Gửi sự kiện filter cho NotificationBloc
                            final bloc = context
                                .findAncestorWidgetOfExactType<
                                  _TemperatureThresholdTab
                                >()
                                ?.key;
                            // Nếu không tìm thấy bloc, dùng context.read
                            context.read<NotificationBloc>().add(
                              LoadNotificationsEvent(
                                queryParameters: {
                                  'fromTime': result.fromTime
                                      ?.toIso8601String(),
                                  'toTime': result.toTime?.toIso8601String(),
                                  'areaId': result.areaId,
                                  'machineId': result.machineId,
                                  'notificationStatus':
                                      result.notificationStatus,
                                  'page': 1,
                                  'pageSize': 20,
                                }..removeWhere((k, v) => v == null),
                              ),
                            );
                          }
                        } else {
                          final areaItems = await _getAreaItems();
                          final cameraItems = await _getCameraItems(
                            _aiWarningFilter.areaId,
                          );
                          final warningEventItems =
                              await _getWarningEventItems();
                          final result =
                              await showDialog<AIWarningFilterParams>(
                                context: context,
                                builder: (context) => AIWarningFilterDialog(
                                  initialParams: _aiWarningFilter,
                                  areaItems: areaItems,
                                  cameraItems: cameraItems,
                                  warningEventItems: warningEventItems,
                                ),
                              );
                          if (result != null) {
                            setState(() => _aiWarningFilter = result);
                            // Gửi sự kiện filter cho VisionNotificationBloc
                            context.read<VisionNotificationBloc>().add(
                              FetchVisionNotifications(
                                fromTime:
                                    result.fromTime?.toIso8601String() ?? '',
                                toTime: result.toTime?.toIso8601String(),
                                areaId: result.areaId,
                                cameraId: result.cameraId,
                                warningEventId: result.warningEventId,
                                page: 1,
                                pageSize: 20,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
              bottom: TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Nhiệt độ vượt ngưỡng'),
                  Tab(text: 'Cảnh báo AI'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [_TemperatureThresholdTab(), _AIWarningTab()],
        ),
      ),
    );
  }
}

/// Tab 1: Temperature Threshold (Notification List)
class _TemperatureThresholdTab extends StatelessWidget {
  const _TemperatureThresholdTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (_) {
        final bloc = NotificationBloc(
          getNotificationsUseCase: getIt(),
          getNotificationDetailUseCase: getIt(),
          getNotificationCountUseCase: getIt(),
          logger: getIt(),
        );
        final now = DateTime.now();
        bloc.add(
          LoadNotificationsEvent(
            queryParameters: {
              'page': 1,
              'pageSize': 20,
              'fromTime': now
                  .subtract(const Duration(days: 7))
                  .toIso8601String(),
            },
          ),
        );
        return bloc;
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationListLoaded) {
            final items = state.list.items;
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có thông báo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return NotificationCard(
                  item: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotificationDetailPage(
                          id: item.id,
                          dataTime: item.dataTime,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Tab 2: AI Warning (Vision Notification)
class _AIWarningTab extends StatefulWidget {
  const _AIWarningTab();

  @override
  State<_AIWarningTab> createState() => _AIWarningTabState();
}

class _AIWarningTabState extends State<_AIWarningTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<VisionNotificationBloc>().add(LoadMoreVisionNotifications());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VisionNotificationBloc(
            getVisionNotificationsUseCase:
                getIt<GetVisionNotificationsUseCase>(),
          )..add(
            FetchVisionNotifications(
              fromTime: _formatDateTime(
                DateTime.now().subtract(const Duration(days: 7)),
              ),
              toTime: _formatDateTime(DateTime.now()),
              areaId: 5,
              cameraId: 3,
              warningEventId: 2,
              page: 1,
              pageSize: 20,
            ),
          ),
      child: BlocBuilder<VisionNotificationBloc, VisionNotificationState>(
        builder: (context, state) {
          if (state is VisionNotificationInitial ||
              state is VisionNotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VisionNotificationLoaded) {
            final items = state.notifications.items;

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có cảnh báo AI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<VisionNotificationBloc>().add(
                  RefreshVisionNotifications(),
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount:
                    items.length +
                    (state is VisionNotificationLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final item = items[index];
                  return _VisionNotificationCard(
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisionNotificationDetailScreen(
                            notification: item,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          if (state is VisionNotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<VisionNotificationBloc>().add(
                        RefreshVisionNotifications(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}

class _VisionNotificationCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _VisionNotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getWarningColor(
                        item.warningEventName,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.warningEventName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getWarningColor(item.warningEventName),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location and Machine
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.areaName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.camera_alt, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.cameraName,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Preview Image
              if (item.imagePath.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imagePath,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getWarningColor(String? warningName) {
    if (warningName == null) return Colors.grey;
    if (warningName.contains('Quá nhiệt') ||
        warningName.contains('Nguy hiểm')) {
      return Colors.red;
    }
    if (warningName.contains('Cảnh báo')) {
      return Colors.orange;
    }
    return Colors.blue;
  }
}
