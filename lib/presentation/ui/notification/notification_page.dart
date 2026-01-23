import 'package:thermal_mobile/data/network/area/area_api_service.dart';
import 'package:thermal_mobile/data/network/machine/machine_api_service.dart';
import 'package:thermal_mobile/data/network/camera/camera_api_service.dart';
import 'package:thermal_mobile/data/network/warning_event/warning_event_api_service.dart';
import 'package:thermal_mobile/data/network/warning_event/dto/warning_event_dto.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/camera/dto/camera_dto.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:thermal_mobile/data/local/storage/config_storage.dart';
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
  late final NotificationBloc _notificationBloc;
  late final VisionNotificationBloc _visionNotificationBloc;
  int? _savedAreaId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    
    // Load saved area from home screen
    _savedAreaId = getIt<ConfigStorage>().getSelectedAreaId();

    _notificationBloc =
        NotificationBloc(
          getNotificationsUseCase: getIt(),
          getNotificationDetailUseCase: getIt(),
          getNotificationCountUseCase: getIt(),
          logger: getIt(),
        )..add(
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

    _visionNotificationBloc =
        VisionNotificationBloc(
          getVisionNotificationsUseCase: getIt<GetVisionNotificationsUseCase>(),
        )..add(
          FetchVisionNotifications(
            fromTime: _formatDateTime(now.subtract(const Duration(days: 7))),
            toTime: _formatDateTime(now),
            page: 1,
            pageSize: 20,
          ),
        );
    
    // Initialize filters with saved area from home screen
    _initFiltersWithSavedArea();
  }

  @override
  void dispose() {
    _notificationBloc.close();
    _visionNotificationBloc.close();
    super.dispose();
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

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

  late TemperatureFilterParams _temperatureFilter;
  late AIWarningFilterParams _aiWarningFilter;
  
  void _initFiltersWithSavedArea() {
    _temperatureFilter = TemperatureFilterParams(
      fromTime: DateTime.now().subtract(const Duration(days: 7)),
      toTime: DateTime.now(),
      areaId: _savedAreaId,
    );
    _aiWarningFilter = AIWarningFilterParams(
      fromTime: DateTime.now().subtract(const Duration(days: 7)),
      toTime: DateTime.now(),
      areaId: _savedAreaId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationBloc>.value(value: _notificationBloc),
        BlocProvider<VisionNotificationBloc>.value(
          value: _visionNotificationBloc,
        ),
      ],
      child: DefaultTabController(
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
                      return IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          // Lấy tabIndex tại thời điểm nhấn button
                          final tabIndex = DefaultTabController.of(
                            context,
                          ).index;
                          if (tabIndex == 0) {
                            final areaItems = await _getAreaItems();
                            final machineItems = await _getMachineItems(
                              _temperatureFilter.areaId,
                            );
                            final result = await TemperatureFilterDialog.show(
                              context: context,
                              initialParams: _temperatureFilter,
                              areaItems: areaItems,
                              machineItems: machineItems,
                              onAreaChanged: _getMachineItems,
                            );
                            if (result != null) {
                              setState(() => _temperatureFilter = result);
                              // Gửi sự kiện filter cho NotificationBloc
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
                            final result = await AIWarningFilterDialog.show(
                              context: context,
                              initialParams: _aiWarningFilter,
                              areaItems: areaItems,
                              cameraItems: cameraItems,
                              warningEventItems: warningEventItems,
                              onAreaChanged: _getCameraItems,
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
      ),
    );
  }
}

/// Tab 1: Temperature Threshold (Notification List)
class _TemperatureThresholdTab extends StatefulWidget {
  const _TemperatureThresholdTab();

  @override
  State<_TemperatureThresholdTab> createState() =>
      _TemperatureThresholdTabState();
}

class _TemperatureThresholdTabState extends State<_TemperatureThresholdTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      final bloc = context.read<NotificationBloc>();
      final state = bloc.state;
      // Only load more if currently loaded and has more pages
      if (state is NotificationListLoaded && state.list.hasNextPage) {
        _isLoadingMore = true;
        bloc.add(LoadMoreNotifications());
      }
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
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (context, state) {
        // Reset loading flag when load more completes
        if (state is NotificationListLoaded || state is NotificationError) {
          _isLoadingMore = false;
        }
      },
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle both NotificationListLoaded and NotificationLoadingMore
        if (state is NotificationListLoaded ||
            state is NotificationLoadingMore) {
          final bool isLoadingMore = state is NotificationLoadingMore;
          final items = isLoadingMore
              ? (state as NotificationLoadingMore).currentList.items
              : (state as NotificationListLoaded).list.items;

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

          return RefreshIndicator(
            onRefresh: () async {
              final now = DateTime.now();
              context.read<NotificationBloc>().add(
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
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: items.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

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
            ),
          );
        }

        if (state is NotificationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final now = DateTime.now();
                    context.read<NotificationBloc>().add(
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
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      final bloc = context.read<VisionNotificationBloc>();
      final state = bloc.state;
      // Only load more if currently loaded and not at max
      if (state is VisionNotificationLoaded && !state.hasReachedMax) {
        _isLoadingMore = true;
        bloc.add(LoadMoreVisionNotifications());
      }
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
    return BlocConsumer<VisionNotificationBloc, VisionNotificationState>(
      listener: (context, state) {
        // Reset loading flag when load more completes
        if (state is VisionNotificationLoaded ||
            state is VisionNotificationError) {
          _isLoadingMore = false;
        }
      },
      builder: (context, state) {
        if (state is VisionNotificationInitial ||
            state is VisionNotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle both VisionNotificationLoaded and VisionNotificationLoadingMore
        if (state is VisionNotificationLoaded ||
            state is VisionNotificationLoadingMore) {
          final bool isLoadingMore = state is VisionNotificationLoadingMore;
          final items = isLoadingMore
              ? (state as VisionNotificationLoadingMore)
                    .currentNotifications
                    .items
              : (state as VisionNotificationLoaded).notifications.items;

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
              itemCount: items.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
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
                        builder: (context) =>
                            VisionNotificationDetailScreen(notification: item),
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
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
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
    );
  }
}

class _VisionNotificationCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _VisionNotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final warningColor = _getWarningColor(item.warningEventName);
    final warningBgColor = warningColor.withOpacity(0.15);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2332), Color(0xFF0F1419)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2D3748).withOpacity(0.5),
                width: 1,
              ),
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
                // Header: Warning Event and Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.warningEventName ?? 'Cảnh báo AI',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.formattedDate ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Warning Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: warningBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 11,
                              color: warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info Chips Row
                Row(
                  children: [
                    // Area Chip
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item.areaName ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Camera Chip
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.videocam,
                              size: 14,
                              color: Color(0xFF60A5FA),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item.cameraName ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Preview Image
                if (item.imagePath != null && item.imagePath.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.imagePath,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Color(0xFF64748B),
                              size: 32,
                            ),
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
      ),
    );
  }

  Color _getWarningColor(String? warningName) {
    if (warningName == null) return const Color(0xFF64748B);
    if (warningName.contains('Quá nhiệt') ||
        warningName.contains('Nguy hiểm') ||
        warningName.contains('Cháy')) {
      return const Color(0xFFEF4444);
    }
    if (warningName.contains('Cảnh báo')) {
      return const Color(0xFFFBBF24);
    }
    return const Color(0xFF0088FF);
  }
}
