/// =============================================================================
/// File: paging_response.dart
/// Description: Generic paging response model for paginated API results
///
/// Purpose:
/// - Provides a standard structure for paginated data from backend
/// - Maps to backend's PagingObject<T> structure
/// - Supports generic type for different data types
/// =============================================================================

/// Generic pagination response wrapper
///
/// Maps to backend's PagingObject structure:
/// ```csharp
/// public class PagingObject<T> {
///   public int TotalRecords { get; set; }
///   public int TotalPages { get; set; }
///   public int CurrentPage { get; set; }
///   public int PageSize { get; set; }
///   public List<T> Data { get; set; }
/// }
/// ```
class PagingResponse<T> {
  /// Total number of records in database
  final int totalRecords;

  /// Total number of pages available
  final int totalPages;

  /// Current page number (1-indexed)
  final int currentPage;

  /// Number of items per page
  final int pageSize;

  /// Actual data items for current page
  final List<T> data;

  const PagingResponse({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.data,
  });

  /// Factory constructor to create from JSON with a mapper function
  ///
  /// [json] - The raw JSON map from API response
  /// [fromJson] - Function to convert each item in data array to type T
  ///
  /// Backend returns: totalRow, pageSize, pageIndex, items
  factory PagingResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PagingResponse<T>(
      totalRecords: json['totalRow'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['pageIndex'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      data:
          (json['items'] as List<dynamic>?)
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Check if there are more pages available
  bool get hasNextPage => currentPage < totalPages;

  /// Check if there is a previous page
  bool get hasPreviousPage => currentPage > 1;

  /// Check if data is empty
  bool get isEmpty => data.isEmpty;

  /// Check if data is not empty
  bool get isNotEmpty => data.isNotEmpty;

  /// Create a copy with different data
  PagingResponse<T> copyWith({
    int? totalRecords,
    int? totalPages,
    int? currentPage,
    int? pageSize,
    List<T>? data,
  }) {
    return PagingResponse<T>(
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'PagingResponse(page: $currentPage/$totalPages, '
        'records: ${data.length}/$totalRecords)';
  }
}
