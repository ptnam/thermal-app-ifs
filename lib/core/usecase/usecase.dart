import 'package:dartz/dartz.dart';

import '../error/failure.dart';

/// Base use case abstract class
/// All use cases must implement this to maintain consistency
abstract class UseCase<Type, Params> {
  /// Execute the use case with given parameters
  /// Returns Either<Failure, Type> to handle success and error cases
  Future<Either<Failure, Type>> call(Params params);
}

/// Marker class for use cases that don't require parameters
class NoParams {
  const NoParams();
}
