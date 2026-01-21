/// DTO for camera stream response from API
class CameraStreamDto {
  final String? rtspUrl;
  final String? hlsUrl;
  final String? dashUrl;
  final String? streamUrl;
  final int cameraId;
  final String cameraName;
  final String status;

  const CameraStreamDto({
    this.rtspUrl,
    this.hlsUrl,
    this.dashUrl,
    this.streamUrl,
    required this.cameraId,
    required this.cameraName,
    required this.status,
  });

  /// Parse from JSON response
  factory CameraStreamDto.fromJson(Map<String, dynamic> json) {
    return CameraStreamDto(
      rtspUrl: json['rtspUrl'] as String?,
      hlsUrl: json['hlsUrl'] as String?,
      dashUrl: json['dashUrl'] as String?,
      streamUrl: json['streamUrl'] as String?,
      cameraId: json['cameraId'] as int? ?? 0,
      cameraName: json['cameraName'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'rtspUrl': rtspUrl,
      'hlsUrl': hlsUrl,
      'dashUrl': dashUrl,
      'streamUrl': streamUrl,
      'cameraId': cameraId,
      'cameraName': cameraName,
      'status': status,
    };
  }

  @override
  String toString() => 'CameraStreamDto(cameraId: $cameraId, cameraName: $cameraName, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraStreamDto &&
          runtimeType == other.runtimeType &&
          rtspUrl == other.rtspUrl &&
          hlsUrl == other.hlsUrl &&
          dashUrl == other.dashUrl &&
          streamUrl == other.streamUrl &&
          cameraId == other.cameraId &&
          cameraName == other.cameraName &&
          status == other.status;

  @override
  int get hashCode =>
      rtspUrl.hashCode ^
      hlsUrl.hashCode ^
      dashUrl.hashCode ^
      streamUrl.hashCode ^
      cameraId.hashCode ^
      cameraName.hashCode ^
      status.hashCode;
}
