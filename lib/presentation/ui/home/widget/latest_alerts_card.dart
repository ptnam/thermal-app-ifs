import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/presentation/bloc/notification/notification_bloc.dart';
import 'package:thermal_mobile/presentation/bloc/vision_notification/vision_notification_bloc.dart';
import 'package:thermal_mobile/presentation/ui/notification/notification_list_page.dart';
import 'package:thermal_mobile/presentation/ui/vision_notification/vision_notification_list_screen.dart';

class LatestAlertsCard extends StatefulWidget {
  final int? areaId;

  const LatestAlertsCard({super.key, this.areaId});

  @override
  State<LatestAlertsCard> createState() => _LatestAlertsCardState();
}

class _LatestAlertsCardState extends State<LatestAlertsCard> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fromTime = now.subtract(const Duration(days: 7)).toIso8601String();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom Tab Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Text(
                  'Vượt ngưỡng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 0
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Text(
                  'Cảnh báo AI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _selectedTab == 1
                        ? const Color(0xFF64B5F6)
                        : const Color(0xFF64B5F6).withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _selectedTab == 0
              ? BlocProvider<NotificationBloc>(
                  create: (_) {
                    final queryParams = <String, dynamic>{
                      'page': 1,
                      'pageSize': 20,
                      'fromTime': fromTime,
                    };
                    if (widget.areaId != null) {
                      queryParams['areaId'] = widget.areaId;
                    }
                    return getIt<NotificationBloc>()..add(
                      LoadNotificationsEvent(queryParameters: queryParams),
                    );
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
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.areaId != null
                                      ? 'Không có cảnh báo vượt ngưỡng\ncho khu vực này'
                                      : 'Chưa chọn khu vực',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _AlertItem(
                              icon: '🔥',
                              title: item.warningEventName ?? 'Thông báo',
                              subtitle: item.areaName ?? 'N/A',
                              time: _formatRelativeTime(item.dataTime),
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                        );
                      }

                      if (state is NotificationError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                )
              : BlocProvider<VisionNotificationBloc>(
                  create: (_) =>
                      VisionNotificationBloc(
                        getVisionNotificationsUseCase: getIt(),
                      )..add(
                        FetchVisionNotifications(
                          fromTime: _formatDateTime(
                            now.subtract(const Duration(days: 7)),
                          ),
                          toTime: _formatDateTime(now),
                          areaId: widget.areaId,
                          page: 1,
                          pageSize: 20,
                        ),
                      ),
                  child: BlocBuilder<VisionNotificationBloc, VisionNotificationState>(
                    builder: (context, state) {
                      if (state is VisionNotificationLoading) {
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
                                  Icons.camera_alt_outlined,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.areaId != null
                                      ? 'Không có cảnh báo AI\ncho khu vực này'
                                      : 'Chưa chọn khu vực',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _AlertItem(
                              icon: '🚶',
                              title: item.warningEventName,
                              subtitle: item.areaName,
                              time: _formatRelativeTimeFromDateTime(
                                item.alertTime,
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const VisionNotificationListScreen(),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                        );
                      }

                      if (state is VisionNotificationLoadingMore) {
                        final items = state.currentNotifications.items;
                        if (items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.areaId != null
                                      ? 'Không có cảnh báo AI\ncho khu vực này'
                                      : 'Chưa chọn khu vực',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _AlertItem(
                              icon: '🚶',
                              title: item.warningEventName,
                              subtitle: item.areaName,
                              time: _formatRelativeTimeFromDateTime(
                                item.alertTime,
                              ),
                              onTap: () {},
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                        );
                      }

                      if (state is VisionNotificationError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
        ),
      ],
    );
  }

  String _formatRelativeTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}ph';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else {
        return '${difference.inDays}d';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatRelativeTimeFromDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}ph';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
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

class _AlertItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback onTap;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Time
              Text(
                time,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
