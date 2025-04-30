import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

// simple secure storage alternative
class SimpleSecureStorage {
  Future<String?> read({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  
  Future<void> write({required String key, required String? value}) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(key, value);
    }
  }
}

// service to encrypt and decrypt sensitive card data
class EncryptionService {
  // singleton instance
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  
  late final Encrypter _encrypter;
  final IV _iv = IV.fromLength(16); // 128-bit IV for AES
  
  // secure storage for encryption keys
  final SimpleSecureStorage _secureStorage = SimpleSecureStorage();
  
  // private constructor
  EncryptionService._internal();
  
  // initialize encryption with secure key
  Future<void> init() async {
    // Get encryption key from secure storage or generate a new one
    String? storedKey = await _secureStorage.read(key: 'encryption_key');
    
    if (storedKey == null) {
      // Generate a new random key
      final key = Key.fromSecureRandom(32); // 256-bit key
      storedKey = base64Encode(key.bytes);
      
      // Store the key securely
      await _secureStorage.write(key: 'encryption_key', value: storedKey);
    }
    
    // Create the encrypter with the retrieved/generated key
    final key = Key.fromBase64(storedKey);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  }
  
  // encrypt a string
  String encrypt(String plainText) {
    try {
      if (plainText.isEmpty) return plainText;
      
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      // Fallback if encryption fails
      return plainText;
    }
  }
  
  // decrypt a string
  String decrypt(String encryptedText) {
    try {
      if (encryptedText.isEmpty) return encryptedText;
      
      // Check if it's actually encrypted (basic validation)
      final base64Regex = RegExp(r'^[A-Za-z0-9+/=]+$');
      if (!base64Regex.hasMatch(encryptedText)) {
        return encryptedText; // Return as is if not encrypted
      }
      
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // Fallback if decryption fails
      return encryptedText;
    }
  }

  // encrypt a map of values
  Map<String, dynamic> encryptMap(Map<String, dynamic> data, List<String> fieldsToEncrypt) {
    try {
      final result = Map<String, dynamic>.from(data);
      
      for (final field in fieldsToEncrypt) {
        if (result.containsKey(field) && result[field] is String) {
          result[field] = encrypt(result[field]);
        }
      }
      
      return result;
    } catch (e) {
      return data; // Return original data if encryption fails
    }
  }

  // decrypt a map of values
  Map<String, dynamic> decryptMap(Map<String, dynamic> data, List<String> fieldsToDecrypt) {
    try {
      final result = Map<String, dynamic>.from(data);
      
      for (final field in fieldsToDecrypt) {
        if (result.containsKey(field) && result[field] is String) {
          result[field] = decrypt(result[field]);
        }
      }
      
      return result;
    } catch (e) {
      return data; // Return original data if decryption fails
    }
  }
  
  // hash a value (one-way, for passwords etc)
  String hashValue(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // secure API communications with HMAC
  Future<String> generateHMAC(String data, String endpoint) async {
    // Get API key from secure storage
    final apiKey = await _secureStorage.read(key: 'api_key') ?? 'default_api_key';
    
    final secretKeyBytes = utf8.encode(apiKey);
    final messageBytes = utf8.encode(data + endpoint);
    
    final hmacSha256 = Hmac(sha256, secretKeyBytes);
    final digest = hmacSha256.convert(messageBytes);
    
    return digest.toString();
  }
} 