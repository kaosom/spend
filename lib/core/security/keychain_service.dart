import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'crypto_service.dart';
import '../../core/errors/app_error.dart';
import '../../core/constants/constants.dart';

/// Secure storage service for iOS Keychain operations
class KeychainService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      groupId: null, // Use default group
    ),
  );

  /// Store encryption key in secure storage
  static Future<Result<void>> storeEncryptionKey(String key) async {
    try {
      await _storage.write(
        key: AppConstants.encryptionKeyKeychainKey,
        value: key,
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(KeychainError(
        message: 'Failed to store encryption key',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Retrieve encryption key from secure storage
  static Future<Result<String?>> getEncryptionKey() async {
    try {
      final key = await _storage.read(
        key: AppConstants.encryptionKeyKeychainKey,
      );
      return Result.success(key);
    } catch (e, stackTrace) {
      return Result.failure(KeychainError(
        message: 'Failed to retrieve encryption key',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Check if encryption key exists
  static Future<Result<bool>> hasEncryptionKey() async {
    try {
      final key = await _storage.read(
        key: AppConstants.encryptionKeyKeychainKey,
      );
      return Result.success(key != null);
    } catch (e, stackTrace) {
      return Result.failure(KeychainError(
        message: 'Failed to check encryption key existence',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Delete encryption key from secure storage
  static Future<Result<void>> deleteEncryptionKey() async {
    try {
      await _storage.delete(
        key: AppConstants.encryptionKeyKeychainKey,
      );
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(KeychainError(
        message: 'Failed to delete encryption key',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Generate and store a new encryption key
  static Future<Result<String>> generateAndStoreKey() async {
    try {
      final key = base64Encode(CryptoService.generateKey());

      final storeResult = await storeEncryptionKey(key);
      if (storeResult.isFailure) {
        return Result.failure(storeResult.error!);
      }

      return Result.success(key);
    } catch (e, stackTrace) {
      return Result.failure(KeychainError(
        message: 'Failed to generate and store encryption key',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Get or create encryption key (creates if doesn't exist)
  static Future<Result<String>> getOrCreateEncryptionKey() async {
    // Try to get existing key
    final existingKeyResult = await getEncryptionKey();
    if (existingKeyResult.isSuccess && existingKeyResult.data != null) {
      return Result.success(existingKeyResult.data!);
    }

    // Key doesn't exist, generate a new one
    return await generateAndStoreKey();
  }

  /// Clear all secure storage (for reset/debugging)
  static Future<Result<void>> clearAll() async {
    try {
      await _storage.deleteAll();
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(KeychainError(
        message: 'Failed to clear secure storage',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }
}
