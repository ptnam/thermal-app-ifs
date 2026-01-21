/// =============================================================================
/// Vision Notification API - Quick Reference
/// =============================================================================

/// USAGE EXAMPLE:
/// 
/// 1. Simple usage with default date range (last 7 days):
/// 
/// ```dart
/// final useCase = getIt<GetVisionNotificationsUseCase>();
/// 
/// final params = GetVisionNotificationsParams.defaultRange(
///   areaId: 5,
///   cameraId: 3,
///   warningEventId: 2,
/// );
/// 
/// final result = await useCase(params);
/// 
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (notifications) => print('Total: ${notifications.totalRow}'),
/// );
/// ```
/// 
/// 2. Custom date range:
/// 
/// ```dart
/// final params = GetVisionNotificationsParams(
///   fromTime: '2026-01-07 00:00:00',
///   toTime: '2026-01-14 00:00:00',
///   areaId: 5,
///   cameraId: 3,
///   warningEventId: 2,
///   page: 1,
///   pageSize: 50,
/// );
/// ```
/// 
/// 3. Pagination:
/// 
/// ```dart
/// // Load next page
/// final nextPageParams = params.copyWith(page: 2);
/// 
/// // Check if has more pages
/// if (notifications.hasNextPage) {
///   // Load more...
/// }
/// ```
/// 
/// PARAMETERS:
/// - fromTime (required): 'yyyy-MM-dd HH:mm:ss'
/// - toTime (optional): 'yyyy-MM-dd HH:mm:ss'
/// - areaId (optional): int
/// - cameraId (optional): int
/// - warningEventId (optional): int
/// - page (default: 1): int
/// - pageSize (default: 50): int
/// 
/// RESPONSE FIELDS:
/// - id: String
/// - alertTime: DateTime
/// - imagePath: String (URL to image)
/// - videoPath: String? (path to video)
/// - inArea: bool
/// - areaName: String
/// - cameraName: String
/// - warningEventName: String
/// - formattedDate: String ('yyyy/MM/dd HH:mm:ss')
/// - dateData: String ('yyyy-MM-dd')
/// - timeData: String ('HH:mm:ss')
