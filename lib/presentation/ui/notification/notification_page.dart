import 'package:thermal_mobile/data/network/area/area_api_service.dart';
import 'package:thermal_mobile/data/network/machine/machine_api_service.dart';
import 'package:thermal_mobile/data/network/camera/camera_api_service.dart';
import 'package:thermal_mobile/data/network/warning_event/warning_event_api_service.dart';
import 'package:thermal_mobile/core/types/get_access_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:intl/intl.dart';

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
    final list = (result.data as List?) ?? [];
    return list
        .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
        .toList();
  }

  TemperatureFilterParams _temperatureFilter =
      TemperatureFilterParams.defaultFilter();
  AIWarningFilterParams _aiWarningFilter =
      AIWarningFilterParams.defaultFilter();

  Future<List<DropdownMenuItem<int>>> _getMachineItems(int? areaId) async {
    final accessToken = await _getAccessToken();
    final service = getIt<MachineApiService>();
    final result = await service.getAll(
      accessToken: accessToken,
      areaId: areaId,
    );
    final list = (result.data as List?) ?? [];
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
    final list = (result.data as List?) ?? [];
    return list
        .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
        .toList();
  }

  Future<List<DropdownMenuItem<int>>> _getWarningEventItems() async {
    final accessToken = await _getAccessToken();
    final service = getIt<WarningEventApiService>();
    final result = await service.getAllWarningEvents(
      accessToken: accessToken,
      warningType: 2,
    );
    final list = (result.data as List?) ?? [];
    return list
        .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
        .toList();
  }

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
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight + 48 + 8 + 1),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFBDBDBD).withOpacity(0.32),
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
                      AnimatedBuilder(
                        animation: tabController,
                        builder: (context, child) {
                          return IconButton(
                            icon: const Icon(Icons.filter_list, color: Colors.white),
                            onPressed: () => _handleFilter(context, tabController.index),
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
          body: TabBarView(
            children: [
              _TemperatureThresholdTab(
                getAreaItems: _getAreaItems,
                getMachineItems: _getMachineItems,
                temperatureFilter: _temperatureFilter,
                onFilterChanged: (params) {
                  setState(() => _temperatureFilter = params);
                },
              ),
              BlocProvider<VisionNotificationBloc>(
                create: (context) =>
                    VisionNotificationBloc(
                      getVisionNotificationsUseCase:
                          getIt<GetVisionNotificationsUseCase>(),
                    )..add(
                      FetchVisionNotifications(
                        fromTime: _AIWarningTabState._formatDateTime(
                          DateTime.now().subtract(const Duration(days: 7)),
                        ),
                        toTime: _AIWarningTabState._formatDateTime(
                          DateTime.now(),
                        ),
                        areaId: null,
                        cameraId: null,
                        warningEventId: null,
                        page: 1,
                        pageSize: 20,
                      ),
                    ),
                child: _AIWarningTab(
                  getAreaItems: _getAreaItems,
                  getCameraItems: _getCameraItems,
                  getWarningEventItems: _getWarningEventItems,
                  aiWarningFilter: _aiWarningFilter,
                  onFilterChanged: (params) {
                    setState(() => _aiWarningFilter = params);
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
    ));
  }

  Future<void> _handleFilter(BuildContext context, int tabIndex) async {
    if (tabIndex == 0) {
      // Temperature filter
      final areaItems = await _getAreaItems();
      final initialMachineItems = _temperatureFilter.areaId != null
          ? await _getMachineItems(_temperatureFilter.areaId)
          : <DropdownMenuItem<int>>[];
      final result = await showDialog<TemperatureFilterParams>(
        context: context,
        builder: (context) => TemperatureFilterDialog(
          initialParams: _temperatureFilter,
          areaItems: areaItems,
          machineItems: initialMachineItems,
          getMachineItems: _getMachineItems,
        ),
      );
      if (result != null) {
        setState(() => _temperatureFilter = result);
        if (context.mounted) {
          BlocProvider.of<NotificationBloc>(context).add(
            LoadNotificationsEvent(
              queryParameters: {
                'fromTime': result.fromTime?.toIso8601String(),
                'toTime': result.toTime?.toIso8601String(),
                'areaId': result.areaId,
                'machineId': result.machineId,
                'notificationStatus': result.notificationStatus,
                'page': 1,
                'pageSize': 20,
              }..removeWhere((k, v) => v == null),
            ),
          );
        }
      }
    } else {
      // AI Warning filter
      final areaItems = await _getAreaItems();
      final warningEventItems = await _getWarningEventItems();
      final initialCameraItems = _aiWarningFilter.areaId != null
          ? await _getCameraItems(_aiWarningFilter.areaId)
          : <DropdownMenuItem<int>>[];
      final result = await showDialog<AIWarningFilterParams>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AIWarningFilterDialog(
          initialParams: _aiWarningFilter,
          areaItems: areaItems,
          cameraItems: initialCameraItems,
          getCameraItems: _getCameraItems,
          warningEventItems: warningEventItems,
        ),
      );
      if (result != null) {
        setState(() => _aiWarningFilter = result);
        if (context.mounted) {
          context.read<VisionNotificationBloc>().add(
            FetchVisionNotifications(
              fromTime: result.fromTime?.toIso8601String() ?? '',
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
    }
  }
}

/// Tab 1: Temperature Threshold (Notification List)

class _TemperatureThresholdTab extends StatefulWidget {
  final Future<List<DropdownMenuItem<int>>> Function() getAreaItems;
  final Future<List<DropdownMenuItem<int>>> Function(int?) getMachineItems;
  final TemperatureFilterParams temperatureFilter;
  final ValueChanged<TemperatureFilterParams> onFilterChanged;

  const _TemperatureThresholdTab({
    required this.getAreaItems,
    required this.getMachineItems,
    required this.temperatureFilter,
    required this.onFilterChanged,
  });

  @override
  State<_TemperatureThresholdTab> createState() => _TemperatureThresholdTabState();
}

class _TemperatureThresholdTabState extends State<_TemperatureThresholdTab> {
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
    if (!_isBottom) return;
    final state = BlocProvider.of<NotificationBloc>(context).state;
    if (state is NotificationListLoaded && state.list.hasNextPage) {
      BlocProvider.of<NotificationBloc>(context).add(LoadMoreNotifications());
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
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NotificationLoadingMore) {
                final items = state.currentList.items;
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index < items.length) {
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
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                );
              }

              if (state is NotificationListLoaded) {
                debugPrint(
                  'NotificationListLoaded (UI): total=${state.list.totalRow}, items=${state.list.items.length}',
                );
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: items.length + (state.list.hasNextPage ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < items.length) {
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
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
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
          );
  }
}

/// Tab 2: AI Warning (Vision Notification)
class _AIWarningTab extends StatefulWidget {
  final Future<List<DropdownMenuItem<int>>> Function() getAreaItems;
  final Future<List<DropdownMenuItem<int>>> Function(int?) getCameraItems;
  final Future<List<DropdownMenuItem<int>>> Function() getWarningEventItems;
  final AIWarningFilterParams aiWarningFilter;
  final ValueChanged<AIWarningFilterParams> onFilterChanged;

  const _AIWarningTab({
    required this.getAreaItems,
    required this.getCameraItems,
    required this.getWarningEventItems,
    required this.aiWarningFilter,
    required this.onFilterChanged,
  });

  @override
  State<_AIWarningTab> createState() => _AIWarningTabState();
}

class _AIWarningTabState extends State<_AIWarningTab> {
  final ScrollController _scrollController = ScrollController();
  late VisionNotificationBloc _visionBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visionBloc = BlocProvider.of<VisionNotificationBloc>(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isBottom) return;
    final state = _visionBloc.state;
    if (state is VisionNotificationLoaded && !state.hasReachedMax) {
      _visionBloc.add(LoadMoreVisionNotifications());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  static String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisionNotificationBloc, VisionNotificationState>(
      builder: (context, state) {
        if (state is VisionNotificationInitial ||
            state is VisionNotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

              if (state is VisionNotificationLoadingMore) {
                final items = state.currentNotifications.items;

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
                          'Không có cảnh báo',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final listView = ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index < items.length) {
                      final item = items[index];
                      return _VisionNotificationCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VisionNotificationDetailScreen(
                                    notification: item,
                                  ),
                            ),
                          );
                        },
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                );

                return RefreshIndicator(
                  onRefresh: () async {
                    _visionBloc.add(RefreshVisionNotifications());
                  },
                  child: listView,
                );
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
                          'Không có cảnh báo',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final listView = ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: items.length + (state.hasReachedMax ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index < items.length) {
                      final item = items[index];
                      return _VisionNotificationCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VisionNotificationDetailScreen(
                                    notification: item,
                                  ),
                            ),
                          );
                        },
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                );

                return RefreshIndicator(
                  onRefresh: () async {
                    _visionBloc.add(RefreshVisionNotifications());
                  },
                  child: listView,
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
                        state.message,
                        style: Theme.of(context).textTheme.titleMedium,
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

  const _VisionNotificationCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getWarningColor(item?.warningEventName);
    
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
                colors: [
                  Color(0xFF1A2332),
                  Color(0xFF0F1419),
                ],
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
                // Header: Title and Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item?.warningEventName ?? 'Xâm nhập',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Vùng bảo vệ Layer 1',
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
                    // Status Badge - always show "Đã xử lý" for AI warnings
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Đã xử lý',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info Row (Human, Công số 2, etc.)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF334155),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Human',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF334155),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sensors,
                            size: 14,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item?.cameraName ?? 'Công số 2',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location Row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item?.areaName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Time Row
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item?.formattedDate ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
