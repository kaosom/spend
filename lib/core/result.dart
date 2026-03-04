import 'errors/app_error.dart';

/// Extension methods for Result type
extension ResultExtensions<T> on Result<T> {
  /// Transform the success value using the given function
  Result<R> map<R>(R Function(T) transform) {
    if (isSuccess) {
      return Result.success(transform(data as T));
    }
    return Result.failure(error!);
  }

  /// Transform the success value using an async function
  Future<Result<R>> mapAsync<R>(Future<R> Function(T) transform) async {
    if (isSuccess) {
      final transformed = await transform(data as T);
      return Result.success(transformed);
    }
    return Result.failure(error!);
  }

  /// Chain operations that return Results
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    if (isSuccess) {
      return transform(data as T);
    }
    return Result.failure(error!);
  }

  /// Chain async operations that return Results
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T) transform,
  ) async {
    if (isSuccess) {
      return await transform(data as T);
    }
    return Result.failure(error!);
  }

  /// Execute a side effect on success
  Result<T> onSuccess(void Function(T) action) {
    if (isSuccess) {
      action(data as T);
    }
    return this;
  }

  /// Execute a side effect on failure
  Result<T> onFailure(void Function(AppError) action) {
    if (isFailure) {
      action(error!);
    }
    return this;
  }

  /// Get the value or throw the error
  T getOrThrow() {
    if (isSuccess) {
      return data as T;
    }
    throw error!;
  }

  /// Get the value or a default value
  T getOrDefault(T defaultValue) {
    if (isSuccess) {
      return data as T;
    }
    return defaultValue;
  }

  /// Get the value or compute a default value
  T getOrElse(T Function() defaultValueFn) {
    if (isSuccess) {
      return data as T;
    }
    return defaultValueFn();
  }
}

/// Utility functions for working with Results
class ResultUtils {
  /// Combine multiple Results into a single Result with a List
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final values = <T>[];
    for (final result in results) {
      if (result.isFailure) {
        return Result.failure(result.error!);
      }
      values.add(result.data as T);
    }
    return Result.success(values);
  }

  /// Combine multiple Results into a single Result with a tuple-like structure
  static Result<(T1, T2)> combine2<T1, T2>(
    Result<T1> result1,
    Result<T2> result2,
  ) {
    if (result1.isFailure) return Result.failure(result1.error!);
    if (result2.isFailure) return Result.failure(result2.error!);
    return Result.success((result1.data as T1, result2.data as T2));
  }

  /// Combine multiple Results into a single Result with a tuple-like structure
  static Result<(T1, T2, T3)> combine3<T1, T2, T3>(
    Result<T1> result1,
    Result<T2> result2,
    Result<T3> result3,
  ) {
    if (result1.isFailure) return Result.failure(result1.error!);
    if (result2.isFailure) return Result.failure(result2.error!);
    if (result3.isFailure) return Result.failure(result3.error!);
    return Result.success((
      result1.data as T1,
      result2.data as T2,
      result3.data as T3,
    ));
  }

  /// Execute an operation and return a Result, catching exceptions
  static Result<T> tryCatch<T>(T Function() operation, {String? errorMessage}) {
    try {
      return Result.success(operation());
    } catch (e, stackTrace) {
      final error = UnknownError(
        message: errorMessage ?? 'Operation failed',
        details: e.toString(),
        stackTrace: stackTrace,
      );
      return Result.failure(error);
    }
  }

  /// Execute an async operation and return a Result, catching exceptions
  static Future<Result<T>> tryCatchAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (e, stackTrace) {
      final error = UnknownError(
        message: errorMessage ?? 'Operation failed',
        details: e.toString(),
        stackTrace: stackTrace,
      );
      return Result.failure(error);
    }
  }
}
