import 'package:flutter/material.dart';
import 'package:thermal_mobile/core/constants/colors.dart';
import 'package:thermal_mobile/domain/models/vision_notification_entity.dart';

/// Vision Notification Detail Screen
class VisionNotificationDetailScreen extends StatelessWidget {
  final VisionNotificationItemEntity notification;

  const VisionNotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Detail'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (notification.imagePath.isNotEmpty)
              Hero(
                tag: 'notification_image_${notification.id}',
                child: Image.network(
                  notification.imagePath,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey[300],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Event
                  _buildSectionTitle(context, 'Warning Event'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notification.warningEventName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Time Information
                  _buildSectionTitle(context, 'Time Information'),
                  const SizedBox(height: 8),
                  _buildInfoCard(context, [
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      notification.dateData,
                    ),
                    _buildInfoRow(
                      Icons.access_time,
                      'Time',
                      notification.timeData,
                    ),
                    _buildInfoRow(
                      Icons.event,
                      'Formatted',
                      notification.formattedDate,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Location Information
                  _buildSectionTitle(context, 'Location Information'),
                  const SizedBox(height: 8),
                  _buildInfoCard(context, [
                    _buildInfoRow(
                      Icons.location_on,
                      'Area',
                      notification.areaName,
                    ),
                    _buildInfoRow(
                      Icons.videocam,
                      'Camera',
                      notification.cameraName,
                    ),
                    _buildInfoRow(
                      Icons.check_circle,
                      'In Area',
                      notification.inArea ? 'Yes' : 'No',
                      valueColor:
                          notification.inArea ? Colors.green : Colors.red,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Media Information
                  _buildSectionTitle(context, 'Media Information'),
                  const SizedBox(height: 8),
                  _buildInfoCard(context, [
                    _buildInfoRow(
                      Icons.image,
                      'Image Path',
                      notification.imagePath,
                      isUrl: true,
                    ),
                    if (notification.videoPath != null)
                      _buildInfoRow(
                        Icons.video_library,
                        'Video Path',
                        notification.videoPath!,
                      ),
                  ]),

                  const SizedBox(height: 24),

                  // ID
                  _buildSectionTitle(context, 'Notification ID'),
                  const SizedBox(height: 8),
                  _buildInfoCard(context, [
                    _buildInfoRow(
                      Icons.fingerprint,
                      'ID',
                      notification.id,
                      monospace: true,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement view image in browser
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feature not implemented yet'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('View Image'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement share
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feature not implemented yet'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isUrl = false,
    bool monospace = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontFamily: monospace ? 'monospace' : null,
                fontSize: isUrl ? 12 : 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
