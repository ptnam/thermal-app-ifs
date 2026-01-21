/// Domain entity for camera stream
class CameraStream {
  final String? rtspUrl;
  final String? hlsUrl;
  final String? dashUrl;
  final String? streamUrl;
  final int cameraId;
  final String cameraName;
  final String status;

  const CameraStream({
    this.rtspUrl,
    this.hlsUrl,
    this.dashUrl,
    this.streamUrl,
    required this.cameraId,
    required this.cameraName,
    required this.status,
  });

  CameraStream copyWith({
    String? rtspUrl,
    String? hlsUrl,
    String? dashUrl,
    String? streamUrl,
    int? cameraId,
    String? cameraName,
    String? status,
  }) {
    return CameraStream(
      rtspUrl: rtspUrl ?? this.rtspUrl,
      hlsUrl: hlsUrl ?? this.hlsUrl,
      dashUrl: dashUrl ?? this.dashUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      cameraId: cameraId ?? this.cameraId,
      cameraName: cameraName ?? this.cameraName,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'CameraStream(cameraId: $cameraId, cameraName: $cameraName, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraStream &&
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
