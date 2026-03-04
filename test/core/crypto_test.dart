import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:avid_spend/core/security/crypto_service.dart';

void main() {
  group('CryptoService', () {
    final testKey = 'VGhpcyBpcyBhIDMyLWJ5dGUgdGVzdCBrZXkh'; // Base64 encoded 32-byte key
    final testData = 'Hello, World!';
    final largeTestData = 'A'.padRight(1000, 'A'); // 1000 character string

    test('generateKey creates valid key', () {
      final key = CryptoService.generateKey();
      expect(key.length, 32);
      expect(CryptoService.isValidKey(base64Encode(key)), true);
    });

    test('isValidKey validates correct keys', () {
      expect(CryptoService.isValidKey(testKey), true);
      expect(CryptoService.isValidKey('invalid'), false);
      expect(CryptoService.isValidKey(''), false);
      expect(CryptoService.isValidKey(base64Encode(Uint8List(16))), false); // Too short
    });

    test('encrypt/decrypt roundtrip works', () {
      final encryptResult = CryptoService.encrypt(testData, testKey);
      expect(encryptResult.isSuccess, true);

      final encrypted = encryptResult.data!;
      final decryptResult = CryptoService.decrypt(encrypted, testKey);
      expect(decryptResult.isSuccess, true);
      expect(decryptResult.data, testData);
    });

    test('encrypt/decrypt roundtrip works with large data', () {
      final encryptResult = CryptoService.encrypt(largeTestData, testKey);
      expect(encryptResult.isSuccess, true);

      final encrypted = encryptResult.data!;
      final decryptResult = CryptoService.decrypt(encrypted, testKey);
      expect(decryptResult.isSuccess, true);
      expect(decryptResult.data, largeTestData);
    });

    test('decrypt fails with wrong key', () {
      final wrongKey = base64Encode(Uint8List(32)..[0] = 1);

      final encryptResult = CryptoService.encrypt(testData, testKey);
      expect(encryptResult.isSuccess, true);

      final encrypted = encryptResult.data!;
      final decryptResult = CryptoService.decrypt(encrypted, wrongKey);
      expect(decryptResult.isFailure, true);
    });

    test('decrypt fails with corrupted data', () {
      final encryptResult = CryptoService.encrypt(testData, testKey);
      expect(encryptResult.isSuccess, true);

      final encrypted = encryptResult.data!;
      final corrupted = '${encrypted.substring(0, encrypted.length - 5)}xxxxx';

      final decryptResult = CryptoService.decrypt(corrupted, testKey);
      expect(decryptResult.isFailure, true);
    });

    test('encrypt fails with invalid key', () {
      final result = CryptoService.encrypt(testData, 'invalid-key');
      expect(result.isFailure, true);
    });

    test('decrypt fails with invalid key', () {
      final result = CryptoService.decrypt('invalid-data', 'invalid-key');
      expect(result.isFailure, true);
    });

    test('encryptWithEncrypt roundtrip works', () {
      final encryptResult = CryptoService.encryptWithEncrypt(testData, testKey);
      expect(encryptResult.isSuccess, true);

      final encrypted = encryptResult.data!;
      final decryptResult = CryptoService.decryptWithEncrypt(encrypted, testKey);
      expect(decryptResult.isSuccess, true);
      expect(decryptResult.data, testData);
    });
  });
}
