import 'errors/app_error.dart';

/// Result type for operations that can fail
class Result<T> {
  const Result.success(this.data) : error = null, _isSuccess = true;
  const Result.failure(this.error) : data = null, _isSuccess = false;

  final T? data;
  final AppError? error;
  final bool _isSuccess;

  bool get isSuccess => _isSuccess;
  bool get isFailure => !_isSuccess;

  /// Execute a function and wrap the result in a Result
  static Result<T> guard<T>(T Function() operation) {
    try {
      return Result.success(operation());
    } catch (e, stackTrace) {
      final error = _mapExceptionToError(e, stackTrace);
      return Result.failure(error);
    }
  }

  /// Execute an async function and wrap the result in a Result
  static Future<Result<T>> guardAsync<T>(Future<T> Function() operation) async {
    try {
      final data = await operation();
      return Result.success(data);
    } catch (e, stackTrace) {
      final error = _mapExceptionToError(e, stackTrace);
      return Result.failure(error);
    }
  }

  static AppError _mapExceptionToError(Object e, StackTrace stackTrace) {
    if (e is AppError) {
      return e;
    }

    // Map common exceptions to AppError types
    if (e is FormatException || e is ArgumentError) {
      return ValidationError(
        message: 'Invalid data format',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }

    if (e.toString().contains('storage') || e.toString().contains('database')) {
      return StorageReadError(
        message: 'Storage operation failed',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }

    return UnknownError(
      message: 'An unexpected error occurred',
      details: e.toString(),
      stackTrace: stackTrace,
    );
  }
}

/// Async Result type for operations that can fail
typedef AsyncResult<T> = Future<Result<T>>;
