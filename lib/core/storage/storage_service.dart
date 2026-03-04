import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/crypto_service.dart';
import '../security/keychain_service.dart';
import '../../core/errors/app_error.dart';

/// Encrypted storage service using SharedPreferences with AES-GCM encryption
class StorageService {
  static SharedPreferences? _prefs;
  static String? _encryptionKey;
  static const String _keyPrefix = 'app_state_';

  /// Initialize the storage service
  static Future<Result<void>> initialize() async {
    try {
      // Get or create encryption key
      final keyResult = await KeychainService.getOrCreateEncryptionKey();
      if (keyResult.isFailure) {
        return Result.failure(keyResult.error!);
      }

      _encryptionKey = keyResult.data!;

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        StorageReadError(
          message: 'Failed to initialize storage',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Store encrypted value
  static Future<Result<void>> store(
    String key,
    Map<String, dynamic> value,
  ) async {
    try {
      if (_prefs == null) {
        return Result.failure(
          StorageWriteError(message: 'Storage not initialized'),
        );
      }

      final jsonString = jsonEncode(value);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Encrypt the data
      final encryptResult = CryptoService.encrypt(jsonString, _encryptionKey!);
      if (encryptResult.isFailure) {
        return Result.failure(encryptResult.error!);
      }

      final storageValue = {
        'encrypted_value': encryptResult.data!,
        'created_at': timestamp,
        'updated_at': timestamp,
      };

      await _prefs!.setString('$_keyPrefix$key', jsonEncode(storageValue));

      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        StorageWriteError(
          message: 'Failed to store data',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Retrieve and decrypt value
  static Future<Result<Map<String, dynamic>?>> retrieve(String key) async {
    try {
      if (_prefs == null) {
        return Result.failure(
          StorageReadError(message: 'Storage not initialized'),
        );
      }

      final storedString = _prefs!.getString('$_keyPrefix$key');
      if (storedString == null) {
        return const Result.success(null);
      }

      final storedData = jsonDecode(storedString) as Map<String, dynamic>;
      final encryptedValue = storedData['encrypted_value'] as String?;
      if (encryptedValue == null) {
        return const Result.success(null);
      }

      // Decrypt the data
      final decryptResult = CryptoService.decrypt(
        encryptedValue,
        _encryptionKey!,
      );
      if (decryptResult.isFailure) {
        return Result.failure(decryptResult.error!);
      }

      final jsonData = jsonDecode(decryptResult.data!) as Map<String, dynamic>;
      return Result.success(jsonData);
    } catch (e, stackTrace) {
      return Result.failure(
        StorageReadError(
          message: 'Failed to retrieve data',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Delete stored value
  static Future<Result<void>> delete(String key) async {
    try {
      if (_prefs == null) {
        return Result.failure(
          StorageWriteError(message: 'Storage not initialized'),
        );
      }

      await _prefs!.remove('$_keyPrefix$key');
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        StorageWriteError(
          message: 'Failed to delete data',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Clear all stored data (for reset)
  static Future<Result<void>> clearAll() async {
    try {
      if (_prefs == null) {
        return Result.failure(
          StorageWriteError(message: 'Storage not initialized'),
        );
      }

      final keys = _prefs!
          .getKeys()
          .where((k) => k.startsWith(_keyPrefix))
          .toList();
      for (final k in keys) {
        await _prefs!.remove(k);
      }

      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        StorageWriteError(
          message: 'Failed to clear data',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Check if key exists
  static Future<Result<bool>> exists(String key) async {
    try {
      if (_prefs == null) {
        return Result.failure(
          StorageReadError(message: 'Storage not initialized'),
        );
      }

      return Result.success(_prefs!.containsKey('$_keyPrefix$key'));
    } catch (e, stackTrace) {
      return Result.failure(
        StorageReadError(
          message: 'Failed to check key existence',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get all stored keys
  static Future<Result<List<String>>> getAllKeys() async {
    try {
      if (_prefs == null) {
        return Result.failure(
          StorageReadError(message: 'Storage not initialized'),
        );
      }

      final keys = _prefs!
          .getKeys()
          .where((k) => k.startsWith(_keyPrefix))
          .map((k) => k.substring(_keyPrefix.length))
          .toList();

      return Result.success(keys);
    } catch (e, stackTrace) {
      return Result.failure(
        StorageReadError(
          message: 'Failed to get all keys',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Close database connection (No-op for SharedPreferences)
  static Future<Result<void>> close() async {
    return const Result.success(null);
  }

  /// Reset storage (delete all and key) - for debugging/testing
  static Future<Result<void>> reset() async {
    try {
      await clearAll();

      // Delete encryption key
      await KeychainService.deleteEncryptionKey();

      // Reset state
      _encryptionKey = null;

      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        StorageWriteError(
          message: 'Failed to reset storage',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
