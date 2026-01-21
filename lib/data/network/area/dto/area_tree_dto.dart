import '../../camera/dto/camera_dto.dart';

/// DTO for Area Tree data from API
class AreaTreeDto {
  final String uniqueId;
  final int? parentId;
  final String name;
  final String code;
  final int id;
  final String mapType;
  final String? photoPath;
  final double longitude;
  final double latitude;
  final int zoom;
  final String? note;
  final String? levelName;
  final List<AreaTreeDto> children;
  final List<CameraDto> cameras;
  final String status;
  final String displayStatus;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const AreaTreeDto({
    required this.uniqueId,
    required this.parentId,
    required this.name,
    required this.code,
    required this.id,
    required this.mapType,
    required this.photoPath,
    required this.longitude,
    required this.latitude,
    required this.zoom,
    required this.note,
    required this.levelName,
    required this.children,
    required this.cameras,
    required this.status,
    required this.displayStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory AreaTreeDto.fromJson(Map<String, dynamic> json) {
    // Parse children list - contains both areas and cameras
    final childrenList = json['children'] as List? ?? [];
    final List<AreaTreeDto> areaChildren = [];
    final List<CameraDto> cameraChildren = [];
    
    for (final item in childrenList) {
      if (item is! Map<String, dynamic>) continue;
      
      // Check if item is a camera (has cameraType or streamUrl field)
      // Areas have mapType field, cameras have cameraType field
      if (item.containsKey('cameraType') || item.containsKey('streamUrl')) {
        cameraChildren.add(CameraDto.fromJson(item));
      } else {
        areaChildren.add(AreaTreeDto.fromJson(item));
      }
    }
    
    return AreaTreeDto(
      uniqueId: json['uniqueId']?.toString() ?? '',
      parentId: json['parentId'] as int?,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      id: json['id'] as int? ?? 0,
      mapType: json['mapType']?.toString() ?? '',
      photoPath: json['photoPath'] as String?,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      zoom: json['zoom'] as int? ?? 0,
      note: json['note'] as String?,
      levelName: json['levelName'] as String?,
      children: areaChildren,
      cameras: cameraChildren,
      status: json['status']?.toString() ?? '',
      displayStatus: json['displayStatus']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt'] as String?,
      deletedAt: json['deletedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uniqueId': uniqueId,
    'parentId': parentId,
    'name': name,
    'code': code,
    'id': id,
    'mapType': mapType,
    'photoPath': photoPath,
    'longitude': longitude,
    'latitude': latitude,
    'zoom': zoom,
    'note': note,
    'levelName': levelName,
    'children': [
      ...children.map((e) => e.toJson()),
      ...cameras.map((e) => e.toJson()),
    ],
    'status': status,
    'displayStatus': displayStatus,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deletedAt': deletedAt,
  };

  @override
  String toString() => 'AreaTreeDto(id: $id, name: $name, childCount: ${children.length}, cameraCount: ${cameras.length})';
}
