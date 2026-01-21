import 'package:thermal_mobile/domain/models/area_tree.dart';
import 'area_tree_dto.dart';

/// Mapper to convert AreaTreeDto (API response) to AreaTree (domain entity)
extension AreaTreeDtoMapper on AreaTreeDto {
  /// Convert DTO to domain entity
  AreaTree toDomain() {
    return AreaTree(
      uniqueId: uniqueId,
      parentId: parentId,
      name: name,
      code: code,
      id: id,
      mapType: mapType,
      photoPath: photoPath,
      longitude: longitude,
      latitude: latitude,
      zoom: zoom,
      note: note,
      levelName: levelName,
      children: children.map((e) => e.toDomain()).toList(),
      status: status,
      displayStatus: displayStatus,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      deletedAt: deletedAt != null ? DateTime.tryParse(deletedAt!) : null,
    );
  }
}

/// Extension to convert list of DTOs
extension AreaTreeDtoListMapper on List<AreaTreeDto> {
  /// Convert list of DTOs to domain entities
  List<AreaTree> toDomain() {
    return map((e) => e.toDomain()).toList();
  }
}
