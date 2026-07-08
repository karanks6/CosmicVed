/// Base use case for synchronous operations
abstract class UseCase<Type, Params> {
  Type call(Params params);
}

/// Base use case for async operations
abstract class AsyncUseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// For use cases with no parameters
class NoParams {
  const NoParams();
}
