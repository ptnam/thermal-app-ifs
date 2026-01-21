import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/core/constants/icons.dart';
import 'package:thermal_mobile/di/injection.dart';
import 'package:thermal_mobile/presentation/widgets/app_drawer_service.dart';

import '../../bloc/notification/notification_bloc.dart';

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

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
        // Send correct params matching web frontend: fromTime only (no toTime)
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
      child: Scaffold(
        appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 8 + 1,
        ), // toolbar height + spacing + border
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
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(16),
              child: SizedBox.shrink(),
            ),
          ),
        ),
      ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
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
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const NotificationCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(item.statusObject?.code);
    final statusBgColor = _getStatusBgColor(item.statusObject?.code);

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
                            item.warningEventName ?? 'Quá nhiệt',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.compareResultObject?.name ?? 'So với pha min toàn trạm',
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
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.statusObject?.name ?? 'Chưa xử lý',
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Temperature Values Row
                Row(
                  children: [
                    if (item.machineName != null) ...[
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
                              Icons.thermostat,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.machineName ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (item.componentValue != null) ...[
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
                              Icons.thermostat,
                              size: 14,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${item.componentValue?.toStringAsFixed(1)}°C',
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
                  ],
                ),
                const SizedBox(height: 12),

                // Additional temp value if exists
                if (item.compareValue != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.thermostat_outlined,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.compareValue?.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

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
                        item.areaName ?? 'N/A',
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
                      item.dataTime ?? item.formattedDate ?? 'N/A',
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

  Color _getStatusColor(String? code) {
    switch (code) {
      case 'Pending':
        return const Color(0xFFFBBF24);
      case 'Resolved':
        return const Color(0xFF10B981);
      case 'Rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color _getStatusBgColor(String? code) {
    switch (code) {
      case 'Pending':
        return const Color(0xFFFBBF24).withOpacity(0.15);
      case 'Resolved':
        return const Color(0xFF10B981).withOpacity(0.15);
      case 'Rejected':
        return const Color(0xFFEF4444).withOpacity(0.15);
      default:
        return const Color(0xFF94A3B8).withOpacity(0.15);
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationDetailPage extends StatelessWidget {
  final String id;
  final String? dataTime;

  const NotificationDetailPage({super.key, required this.id, this.dataTime});

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
        bloc.add(LoadNotificationDetailEvent(id: id, dataTime: dataTime ?? ''));
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết thông báo'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NotificationDetailLoaded) {
              final item = state.item;
              final statusColor = _getStatusColor(item.statusObject?.code);
              final resultColor = _getResultColor(
                item.compareResultObject?.code,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.1),
                            statusColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.warningEventName ?? 'Thông báo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.areaName ?? 'N/A',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.grey.shade700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.statusObject?.name ?? 'N/A',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main Details
                    _DetailCard(
                      title: 'Thông tin cơ bản',
                      children: [
                        _DetailRow(
                          label: 'Máy',
                          value: item.machineName ?? 'N/A',
                        ),
                        _DetailRow(
                          label: 'Thành phần',
                          value: item.machineComponentName ?? 'N/A',
                        ),
                        _DetailRow(
                          label: 'Điểm giám sát',
                          value: item.monitorPointCode ?? 'N/A',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Temperature Data
                    if (item.compareMinTemperature != null ||
                        item.compareMaxTemperature != null ||
                        item.compareAveTemperature != null)
                      _DetailCard(
                        title: 'Dữ liệu nhiệt độ',
                        children: [
                          if (item.compareMinTemperature != null)
                            _DetailRow(
                              label: 'Nhiệt độ tối thiểu',
                              value: '${item.compareMinTemperature}°C',
                            ),
                          if (item.compareMaxTemperature != null)
                            _DetailRow(
                              label: 'Nhiệt độ tối đa',
                              value: '${item.compareMaxTemperature}°C',
                            ),
                          if (item.compareAveTemperature != null)
                            _DetailRow(
                              label: 'Nhiệt độ trung bình',
                              value: '${item.compareAveTemperature}°C',
                            ),
                        ],
                      ),
                    if (item.compareMinTemperature != null ||
                        item.compareMaxTemperature != null ||
                        item.compareAveTemperature != null)
                      const SizedBox(height: 16),

                    // Comparison Data
                    _DetailCard(
                      title: 'So sánh',
                      children: [
                        _DetailRow(
                          label: 'Giá trị hiện tại',
                          value:
                              item.componentValue?.toStringAsFixed(2) ?? 'N/A',
                        ),
                        _DetailRow(
                          label: 'Giá trị so sánh',
                          value: item.compareValue?.toStringAsFixed(2) ?? 'N/A',
                        ),
                        _DetailRow(
                          label: 'Chênh lệch',
                          value: item.deltaValue?.toStringAsFixed(2) ?? 'N/A',
                        ),
                        _DetailRow(
                          label: 'Loại so sánh',
                          value: item.compareTypeObject?.name ?? 'N/A',
                        ),
                        _DetailRowWithBadge(
                          label: 'Kết quả',
                          value: item.compareResultObject?.name ?? 'N/A',
                          bgColor: resultColor.withOpacity(0.2),
                          textColor: resultColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Time Information
                    _DetailCard(
                      title: 'Thời gian',
                      children: [
                        _DetailRow(
                          label: 'Thời gian phát hiện',
                          value: item.formattedDate ?? 'N/A',
                        ),
                        _DetailRow(
                          label: 'Thời gian chi tiết',
                          value: item.dataTime ?? 'N/A',
                        ),
                        if (item.resolveTime != null)
                          _DetailRow(
                            label: 'Thời gian xử lý',
                            value: item.resolveTime!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Image
                    if (item.imagePath != null && item.imagePath!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hình ảnh',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imagePath!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Không thể tải hình ảnh',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }

  Color _getStatusColor(String? code) {
    switch (code) {
      case 'Pending':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getResultColor(String? code) {
    switch (code) {
      case 'Good':
        return Colors.green;
      case 'Bad':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children
              .expand((child) => [child, const SizedBox(height: 8)])
              .toList()
            ..removeLast(),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _DetailRowWithBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Color textColor;

  const _DetailRowWithBadge({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
