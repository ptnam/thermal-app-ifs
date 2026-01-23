import 'package:flutter/material.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/domain/models/vision_notification_entity.dart';

/// Vision Notification Detail Screen
class VisionNotificationDetailScreen extends StatelessWidget {
  final VisionNotificationItemEntity notification;

  const VisionNotificationDetailScreen({super.key, required this.notification});

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

  @override
  Widget build(BuildContext context) {
    final warningColor = _getWarningColor(notification.warningEventName);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Chi tiết cảnh báo AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            if (notification.imagePath.isNotEmpty)
              Stack(
                children: [
                  Hero(
                    tag: 'notification_image_${notification.id}',
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(color: const Color(0xFF1A2332)),
                      child: Image.network(
                        notification.imagePath,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 280,
                            color: const Color(0xFF1A2332),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 64,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Không thể tải hình ảnh',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.backgroundDark.withOpacity(0.8),
                            AppColors.backgroundDark,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Warning badge on image
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: warningColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: warningColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            notification.warningEventName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Warning Info
                  _buildHeaderCard(context, warningColor),
                  const SizedBox(height: 16),

                  // Time Information Card
                  _buildDetailCard(
                    context: context,
                    title: 'Thông tin thời gian',
                    icon: Icons.schedule,
                    iconColor: const Color(0xFF60A5FA),
                    children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Ngày',
                        value: notification.dateData,
                      ),
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Giờ',
                        value: notification.timeData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Information Card
                  _buildDetailCard(
                    context: context,
                    title: 'Thông tin vị trí',
                    icon: Icons.location_on,
                    iconColor: const Color(0xFFEF4444),
                    children: [
                      _buildDetailRow(
                        icon: Icons.business,
                        label: 'Khu vực',
                        value: notification.areaName,
                      ),
                      _buildDetailRow(
                        icon: Icons.videocam,
                        label: 'Camera',
                        value: notification.cameraName,
                      ),
                      _buildDetailRow(
                        icon: Icons.check_circle,
                        label: 'Trong vùng',
                        value: notification.inArea ? 'Có' : 'Không',
                        valueColor: notification.inArea
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Color warningColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            warningColor.withOpacity(0.15),
            warningColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warningColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: warningColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.warningEventName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: warningColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildInfoChip(
                  icon: Icons.location_on,
                  label: notification.areaName,
                  color: const Color(0xFFEF4444),
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.videocam,
                  label: notification.cameraName,
                  color: const Color(0xFF60A5FA),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children
              .expand((child) => [child, const SizedBox(height: 12)])
              .toList()
            ..removeLast(),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
