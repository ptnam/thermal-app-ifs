import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../models/vision_notification_entity.dart';

/// Repository interface for Vision Notification operations
abstract class VisionNotificationRepository {
  /// Get paginated list of vision notifications
  /// 
  /// Parameters:
  /// - fromTime: Required start time in format 'yyyy-MM-dd HH:mm:ss'
  /// - toTime: Optional end time in format 'yyyy-MM-dd HH:mm:ss'
  /// - areaId: Optional area filter
  /// - cameraId: Optional camera filter
  /// - warningEventId: Optional warning event filter
  /// - page: Page number (default: 1)
  /// - pageSize: Items per page (default: 50)
  Future<Either<Failure, VisionNotificationListEntity>> getVisionNotifications({
    required String fromTime,
    String? toTime,
    int? areaId,
    int? cameraId,
    int? warningEventId,
    int page = 1,
    int pageSize = 50,
  });
}
