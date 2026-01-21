import 'package:thermal_mobile/domain/models/camera_stream.dart';
import 'camera_stream_dto.dart';

/// Mapper giữa CameraStreamDto và CameraStream entity
class CameraStreamDtoMapper {
  /// Convert DTO to Domain Entity
  static CameraStream toDomain(CameraStreamDto dto) {
    return CameraStream(
      rtspUrl: dto.rtspUrl,
      hlsUrl: dto.hlsUrl,
      dashUrl: dto.dashUrl,
      streamUrl: dto.streamUrl,
      cameraId: dto.cameraId,
      cameraName: dto.cameraName,
      status: dto.status,
    );
  }

  /// Convert Domain Entity to DTO
  static CameraStreamDto fromDomain(CameraStream entity) {
    return CameraStreamDto(
      rtspUrl: entity.rtspUrl,
      hlsUrl: entity.hlsUrl,
      dashUrl: entity.dashUrl,
      streamUrl: entity.streamUrl,
      cameraId: entity.cameraId,
      cameraName: entity.cameraName,
      status: entity.status,
    );
  }
}
