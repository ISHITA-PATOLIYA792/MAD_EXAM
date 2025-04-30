import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class EncryptionService {
  // singleton instance
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // encryption key - in production, store securely or derive from user credentials
  final _key = Key.fromLength(32); // 256 bit key for AES
  final _iv = IV.fromLength(16); // initialization vector

  // encrypt a string value
  String encrypt(String plainText) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  // decrypt a string value
  String decrypt(String encryptedText) {
    try {
      final encrypter = Encrypter(AES(_key));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      print('Error during decryption: $e');
      return '';
    }
  }

  // encrypt a map of values
  Map<String, dynamic> encryptMap(Map<String, dynamic> data, List<String> fieldsToEncrypt) {
    final encryptedData = Map<String, dynamic>.from(data);
    
    for (final field in fieldsToEncrypt) {
      if (encryptedData.containsKey(field) && encryptedData[field] is String) {
        encryptedData[field] = encrypt(encryptedData[field]);
      }
    }
    
    return encryptedData;
  }

  // decrypt a map of values
  Map<String, dynamic> decryptMap(Map<String, dynamic> data, List<String> fieldsToDecrypt) {
    final decryptedData = Map<String, dynamic>.from(data);
    
    for (final field in fieldsToDecrypt) {
      if (decryptedData.containsKey(field) && decryptedData[field] is String) {
        decryptedData[field] = decrypt(decryptedData[field]);
      }
    }
    
    return decryptedData;
  }
} 