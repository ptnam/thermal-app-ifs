/// =============================================================================
/// File: role_entity.dart
/// Description: Role domain entity
/// 
/// Purpose:
/// - Pure domain model for role and feature business logic
/// - Used for role-based access control
/// =============================================================================

/// Domain entity representing a Feature (permission)
class FeatureEntity {
  final int id;
  final String code;
  final String? name;
  final String? description;
  final int? parentId;
  final List<FeatureEntity>? children;

  const FeatureEntity({
    required this.id,
    required this.code,
    this.name,
    this.description,
    this.parentId,
    this.children,
  });

  /// Check if feature has children
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Get all feature codes including children
  List<String> get allCodes {
    final codes = <String>[code];
    if (hasChildren) {
      for (final child in children!) {
        codes.addAll(child.allCodes);
      }
    }
    return codes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Domain entity representing a Role
class RoleEntity {
  final int id;
  final String name;
  final String? description;
  final List<FeatureEntity>? features;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleEntity({
    required this.id,
    required this.name,
    this.description,
    this.features,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if role has specific feature code
  bool hasFeature(String featureCode) {
    if (features == null) return false;
    for (final feature in features!) {
      if (feature.allCodes.contains(featureCode)) return true;
    }
    return false;
  }

  /// Check if role has any of the given feature codes
  bool hasAnyFeature(List<String> featureCodes) {
    return featureCodes.any(hasFeature);
  }

  /// Get all feature codes for this role
  List<String> get allFeatureCodes {
    if (features == null) return [];
    return features!.expand((f) => f.allCodes).toList();
  }

  RoleEntity copyWith({
    int? id,
    String? name,
    String? description,
    List<FeatureEntity>? features,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoleEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RoleEntity(id: $id, name: $name)';
}
