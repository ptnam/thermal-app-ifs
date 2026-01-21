import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/models/area_tree.dart';
import '../repositories/area_repository.dart';

/// Use case: Get area tree with cameras
/// Orchestrates the business logic for fetching area hierarchy
class GetAreaAllTreeUseCase
    implements UseCase<List<AreaTree>, NoParams> {
  final AreaRepository _repository;

  GetAreaAllTreeUseCase(this._repository);
  @override
  Future<Either<Failure, List<AreaTree>>> call(NoParams params) {
    return _repository.getAreaAllTree();
  }
}

/// Use case: Get single area by ID
class GetAreaByIdUseCase implements UseCase<AreaTree, GetAreaByIdParams> {
  final AreaRepository _repository;

  GetAreaByIdUseCase(this._repository);

  @override
  Future<Either<Failure, AreaTree>> call(GetAreaByIdParams params) {
    return _repository.getAreaById(params.id);
  }
}

class GetAreaByIdParams {
  final int id;

  const GetAreaByIdParams({required this.id});
}
