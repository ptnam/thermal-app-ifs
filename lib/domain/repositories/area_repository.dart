import 'package:dartz/dartz.dart';
import 'package:thermal_mobile/data/network/api/base_dto.dart';
import 'package:thermal_mobile/data/network/api/paging_response.dart';
import 'package:thermal_mobile/data/network/area/dto/area_dto.dart';
import 'package:thermal_mobile/domain/models/area_tree.dart';

import '../../core/error/failure.dart';

/// Repository interface for Area operations
/// Abstracts data sources (remote API, local cache)
abstract class AreaRepository {
  /// Get complete area tree hierarchy with cameras
  Future<Either<Failure, List<AreaTree>>> getAreaAllTree();

  /// Get single area by ID
  Future<Either<Failure, AreaTree>> getAreaById(int id);

  /// get all areas in flat list
  Future<Either<Failure, List<ShortenBaseDto>>> getAllAreas();

  /// Get area list with pagination
  Future<Either<Failure, PagingResponse<AreaDto>>> getAreaList({
    int page = 1,
    int pageSize = 20,
    CommonStatus? status,
  });

  /// Create a new area
  Future<Either<Failure, AreaDto>> createArea(AreaDto area);

  /// Update area by ID
  Future<Either<Failure, AreaDto>> updateArea(AreaDto area);

  /// Delete area by ID
  Future<Either<Failure, void>> deleteArea(int id);
}
