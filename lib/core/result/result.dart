/// Result type for error handling throughout CosmicVed
sealed class Result<T> {
  const Result();

  /// Pattern-match success/failure
  R when<R>({
    required R Function(T value) success,
    required R Function(CosmicFailure failure) failure,
  }) {
    return switch (this) {
      Success<T>(:final value) => success(value),
      Failure<T>(failure: final f) => failure(f),
    };
  }

  /// Map the value if success
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => Success(transform(value)),
      Failure<T>(:final failure) => Failure(failure),
    };
  }

  /// Get value or null
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final CosmicFailure failure;
  const Failure(this.failure);
}

// ─── Failure Hierarchy ────────────────────────────────────────────────────────

sealed class CosmicFailure {
  final String message;
  const CosmicFailure(this.message);
}

final class DatabaseFailure extends CosmicFailure {
  const DatabaseFailure(super.message);
}

final class NetworkFailure extends CosmicFailure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});
}

final class CalculationFailure extends CosmicFailure {
  const CalculationFailure(super.message);
}

final class ValidationFailure extends CosmicFailure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends CosmicFailure {
  const NotFoundFailure(super.message);
}

final class CacheFailure extends CosmicFailure {
  const CacheFailure(super.message);
}

final class BackupFailure extends CosmicFailure {
  const BackupFailure(super.message);
}

final class PermissionFailure extends CosmicFailure {
  const PermissionFailure(super.message);
}

final class UnknownFailure extends CosmicFailure {
  const UnknownFailure(super.message);
}
