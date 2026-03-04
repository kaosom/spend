import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import '../../core/errors/app_error.dart';

// Import specific pointycastle classes
import 'package:pointycastle/export.dart';

/// Cryptographic service for encryption/decryption operations
class CryptoService {
  static const int _keyLength = 32; // 256 bits for AES
  static const int _ivLength = 12; // 96 bits for GCM nonce
  static const int _tagLength = 16; // 128 bits for GCM tag

  /// Generate a random encryption key
  static Uint8List generateKey() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(_keyLength, (_) => random.nextInt(256)));
  }

  /// Encrypt data using AES-GCM
  static Result<String> encrypt(String data, String key) {
    try {
      final keyBytes = base64Decode(key);
      final dataBytes = utf8.encode(data);

      // Generate random nonce
      final nonce = _generateNonce();

      // Create AES-GCM cipher
      final cipher = GCMBlockCipher(AESEngine())
        ..init(true, AEADParameters(
          KeyParameter(keyBytes),
          _tagLength * 8, // tag length in bits
          nonce,
          Uint8List(0), // additional authenticated data (empty)
        ));

      // Encrypt
      final encrypted = cipher.process(dataBytes);

      // Combine nonce + encrypted data + tag
      final result = Uint8List(_ivLength + encrypted.length.toInt());
      result.setRange(0, _ivLength, nonce);
      result.setRange(_ivLength, result.length, encrypted);

      return Result.success(base64Encode(result));
    } catch (e, stackTrace) {
      return Result.failure(EncryptionError(
        message: 'Failed to encrypt data',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Decrypt data using AES-GCM
  static Result<String> decrypt(String encryptedData, String key) {
    try {
      final keyBytes = base64Decode(key);
      final encryptedBytes = base64Decode(encryptedData);

      if (encryptedBytes.length < _ivLength + _tagLength) {
        return Result.failure(EncryptionError(
          message: 'Invalid encrypted data format',
        ));
      }

      // Extract nonce, ciphertext, and tag
      final nonce = encryptedBytes.sublist(0, _ivLength);
      final ciphertext = encryptedBytes.sublist(_ivLength);

      // Create AES-GCM cipher
      final cipher = GCMBlockCipher(AESEngine())
        ..init(false, AEADParameters(
          KeyParameter(keyBytes),
          _tagLength * 8, // tag length in bits
          nonce,
          Uint8List(0), // additional authenticated data (empty)
        ));

      // Decrypt
      final decrypted = cipher.process(ciphertext);

      return Result.success(utf8.decode(decrypted));
    } catch (e, stackTrace) {
      return Result.failure(EncryptionError(
        message: 'Failed to decrypt data',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Validate encryption key format
  static bool isValidKey(String key) {
    try {
      final decoded = base64Decode(key);
      return decoded.length == _keyLength;
    } catch (e) {
      return false;
    }
  }

  /// Generate a random nonce for GCM
  static Uint8List _generateNonce() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(_ivLength, (_) => random.nextInt(256)));
  }

  /// Alternative implementation using encrypt package (for compatibility)
  static Result<String> encryptWithEncrypt(String data, String key) {
    try {
      final keyBytes = Key.fromBase64(key);
      final iv = IV.fromSecureRandom(16); // 128 bits

      final encrypter = Encrypter(AES(keyBytes, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(data, iv: iv);

      // Combine IV and encrypted data
      final result = '${iv.base64}:${encrypted.base64}';
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.failure(EncryptionError(
        message: 'Failed to encrypt data with encrypt package',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Alternative decryption using encrypt package
  static Result<String> decryptWithEncrypt(String encryptedData, String key) {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        return Result.failure(EncryptionError(
          message: 'Invalid encrypted data format',
        ));
      }

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      final keyBytes = Key.fromBase64(key);

      final encrypter = Encrypter(AES(keyBytes, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return Result.success(decrypted);
    } catch (e, stackTrace) {
      return Result.failure(EncryptionError(
        message: 'Failed to decrypt data with encrypt package',
        details: e.toString(),
        stackTrace: stackTrace,
      ));
    }
  }
}
