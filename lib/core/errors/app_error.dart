import 'package:equatable/equatable.dart';

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

/// Base error class for Avid Spend
abstract class AppError extends Equatable {
  const AppError({required this.message, this.details, this.stackTrace});

  final String message;
  final String? details;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, details, stackTrace];

  @override
  String toString() {
    if (details != null) {
      return '$runtimeType: $message\nDetails: $details';
    }
    return '$runtimeType: $message';
  }
}

/// Storage-related errors
class StorageReadError extends AppError {
  const StorageReadError({
    super.message = 'Failed to read from storage',
    super.details,
    super.stackTrace,
  });
}

class StorageWriteError extends AppError {
  const StorageWriteError({
    super.message = 'Failed to write to storage',
    super.details,
    super.stackTrace,
  });
}

/// Security-related errors
class EncryptionError extends AppError {
  const EncryptionError({
    super.message = 'Encryption operation failed',
    super.details,
    super.stackTrace,
  });
}

class KeychainError extends AppError {
  const KeychainError({
    super.message = 'Keychain operation failed',
    super.details,
    super.stackTrace,
  });
}

/// Validation errors
class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    super.details,
    super.stackTrace,
  });
}

/// Not found errors
class NotFoundError extends AppError {
  const NotFoundError({
    super.message = 'Item not found',
    super.details,
    super.stackTrace,
  });
}

/// Network errors (for future use)
class NetworkError extends AppError {
  const NetworkError({
    super.message = 'Network operation failed',
    super.details,
    super.stackTrace,
  });
}

/// Unknown errors
class UnknownError extends AppError {
  const UnknownError({
    super.message = 'An unknown error occurred',
    super.details,
    super.stackTrace,
  });
}
