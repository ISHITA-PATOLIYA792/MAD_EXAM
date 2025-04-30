import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';

// service to manage offline access and caching
class OfflineService {
  // singleton instance
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const String _pendingChangesBoxName = 'pending_changes';
  static const String _imageCacheDir = 'cached_images';
  
  // initialize service
  Future<void> init() async {
    try {
      // ensure the cache directory exists
      final cacheDir = await _getCacheDirectory();
      final imageDir = Directory('${cacheDir.path}/$_imageCacheDir');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      // open pending changes box if not already open
      if (!Hive.isBoxOpen(_pendingChangesBoxName)) {
        await Hive.openBox<String>(_pendingChangesBoxName);
      }
    } catch (e) {
      debugPrint('Error initializing OfflineService: $e');
    }
  }
  
  // cache a card image for offline access
  Future<void> cacheCardImage(String cardId, String? imagePath) async {
    if (imagePath == null) return;
    
    try {
      final File sourceFile = File(imagePath);
      if (!await sourceFile.exists()) return;
      
      final cacheDir = await _getCacheDirectory();
      final cachedFile = File('${cacheDir.path}/$_imageCacheDir/$cardId.jpg');
      
      // copy the image to cache
      await sourceFile.copy(cachedFile.path);
    } catch (e) {
      debugPrint('Error caching card image: $e');
    }
  }
  
  // get cached image path for a card
  Future<String?> getCachedImagePath(String cardId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cachedFile = File('${cacheDir.path}/$_imageCacheDir/$cardId.jpg');
      
      if (await cachedFile.exists()) {
        return cachedFile.path;
      }
    } catch (e) {
      debugPrint('Error getting cached image: $e');
    }
    
    return null;
  }
  
  // cache barcode data
  Future<void> cacheBarcode(String cardId, String barcode, BarcodeType type) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final barcodeDataFile = File('${cacheDir.path}/$_imageCacheDir/$cardId.barcode');
      
      // create a map with barcode data
      final data = {
        'barcode': barcode,
        'type': type == BarcodeType.qrCode ? 'qrCode' : 'barcode',
      };
      
      // save as JSON
      await barcodeDataFile.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error caching barcode: $e');
    }
  }
  
  // queue a pending change to be synced later
  Future<void> queuePendingChange(String cardId, String operation) async {
    try {
      final box = await Hive.openBox<String>(_pendingChangesBoxName);
      await box.put(cardId, operation); // operations: 'add', 'update', 'delete'
    } catch (e) {
      debugPrint('Error queuing pending change: $e');
    }
  }
  
  // get all pending changes
  Future<Map<String, String>> getPendingChanges() async {
    try {
      final box = await Hive.openBox<String>(_pendingChangesBoxName);
      final Map<String, String> changes = {};
      
      for (final key in box.keys) {
        final value = box.get(key.toString());
        if (value != null) {
          changes[key.toString()] = value;
        }
      }
      
      return changes;
    } catch (e) {
      debugPrint('Error getting pending changes: $e');
      return {};
    }
  }
  
  // clear a pending change after it's been synced
  Future<void> clearPendingChange(String cardId) async {
    try {
      final box = await Hive.openBox<String>(_pendingChangesBoxName);
      await box.delete(cardId);
    } catch (e) {
      debugPrint('Error clearing pending change: $e');
    }
  }
  
  // check if device is in offline mode
  Future<bool> isOffline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isEmpty || result[0].rawAddress.isEmpty;
    } on SocketException catch (_) {
      return true;
    }
  }
  
  // helper to get cache directory
  Future<Directory> _getCacheDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }
} 