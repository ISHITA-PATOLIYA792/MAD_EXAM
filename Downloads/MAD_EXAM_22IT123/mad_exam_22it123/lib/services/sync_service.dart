import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/services/encryption_service.dart';
import 'package:mad_exam_22it123/services/offline_service.dart';
import 'package:flutter/foundation.dart';

// service to handle synchronization with server
class SyncService {
  final Random _random = Random();
  
  // singleton instance
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // use a mock API endpoint (in a real app, use a real API)
  static const String _baseUrl = 'https://mockapi.example.com/api';
  
  final _encryptionService = EncryptionService();
  final _offlineService = OfflineService();
  final _sensitiveFields = ['cardNumber', 'barcode'];
  
  // Stream to notify listeners about sync status
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  // check if device is connected to the internet
  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  // initialize sync service and listen for connectivity changes
  Future<void> init() async {
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // We're back online, attempt to sync pending changes
        _syncPendingChanges();
      }
    });
  }
  
  // push a single card to the server with retry mechanism
  Future<bool> pushCard(LoyaltyCard card, {int maxRetries = 3}) async {
    // Check if we're offline
    if (!await isConnected()) {
      // Queue change for later sync
      await _offlineService.queuePendingChange(card.id, 'update');
      return false;
    }
    
    // Cache card data for offline access
    await _cacheCardData(card);
    
    // Encrypt sensitive fields for API transmission
    final cardData = card.toJson();
    final encryptedData = _encryptionService.encryptMap(cardData, _sensitiveFields);
    
    int retryCount = 0;
    bool success = false;
    
    while (retryCount < maxRetries && !success) {
      try {
        // Simulate API request with delay
        await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
        
        // Generate request signature for security
        final signature = await _encryptionService.generateHMAC(
          jsonEncode(encryptedData), 
          '/cards/${card.id}'
        );
        
        // Simulate HTTP request (in a real app, this would be a real API call)
        // http.post(
        //   Uri.parse('$_baseUrl/cards'),
        //   headers: {
        //     'Content-Type': 'application/json',
        //     'X-API-Signature': signature,
        //   },
        //   body: jsonEncode(encryptedData),
        // );
        
        // Simulate occasional failure (10% chance on first try, less on retries)
        if (_random.nextInt(10 + retryCount * 3) == 0) {
          throw Exception('Simulated network error');
        }
        
        success = true;
      } catch (e) {
        retryCount++;
        // Wait longer between retries
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: retryCount)); 
        }
      }
    }
    
    if (!success) {
      // If failed after retries, queue for later sync
      await _offlineService.queuePendingChange(card.id, 'update');
    }
    
    return success;
  }
  
  // cache card data for offline access
  Future<void> _cacheCardData(LoyaltyCard card) async {
    // Cache card image if it has one
    if (card.imagePath != null) {
      await _offlineService.cacheCardImage(card.id, card.imagePath);
    }
    
    // Cache barcode data
    await _offlineService.cacheBarcode(card.id, card.barcode, card.barcodeType);
  }
  
  // sync all pending changes when back online
  Future<void> _syncPendingChanges() async {
    if (!await isConnected()) return;
    
    _syncStatusController.add(SyncStatus(isActive: true, message: 'Syncing pending changes...'));
    
    try {
      // Get all pending changes
      final pendingChanges = await _offlineService.getPendingChanges();
      
      if (pendingChanges.isEmpty) {
        _syncStatusController.add(SyncStatus(isActive: false, message: 'No pending changes'));
        return;
      }
      
      // Process each pending change
      for (final entry in pendingChanges.entries) {
        final cardId = entry.key;
        final operation = entry.value;
        
        bool success = false;
        
        // Simulate API call based on operation type
        switch (operation) {
          case 'add':
          case 'update':
            // In a real app, you would get the card from local storage and push it
            await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));
            success = _random.nextInt(10) != 0; // 90% success rate
            break;
          case 'delete':
            await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));
            success = _random.nextInt(10) != 0; // 90% success rate
            break;
        }
        
        // If successful, clear the pending change
        if (success) {
          await _offlineService.clearPendingChange(cardId);
        }
      }
      
      _syncStatusController.add(SyncStatus(isActive: false, message: 'Sync completed'));
    } catch (e) {
      _syncStatusController.add(SyncStatus(isActive: false, message: 'Sync failed: $e'));
      debugPrint('Error syncing pending changes: $e');
    }
  }
  
  // simulate fetching all cards from the server
  Future<List<LoyaltyCard>> fetchCards() async {
    // simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    
    // in a real app, this would fetch cards from a server
    // for demo purposes, return an empty list
    return [];
  }
  
  // sync offline changes to the server with conflict resolution
  Future<List<String>> syncOfflineChanges(List<LoyaltyCard> cards) async {
    if (!await isConnected()) {
      return [];
    }
    
    _syncStatusController.add(SyncStatus(isActive: true, message: 'Syncing changes to server...'));
    
    try {
      // Get unsynced cards
      final unsyncedCards = cards.where((card) => !card.isSynced).toList();
      
      if (unsyncedCards.isEmpty) {
        _syncStatusController.add(SyncStatus(isActive: false, message: 'No changes to sync'));
        return [];
      }
      
      // Pretend we successfully synced most of them
      final syncedIds = <String>[];
      for (final card in unsyncedCards) {
        // Cache for offline access first
        await _cacheCardData(card);
        
        // Simulate occasional failure (10% chance)
        if (_random.nextInt(10) != 0) {
          syncedIds.add(card.id);
          
          // Remove from pending changes if successful
          await _offlineService.clearPendingChange(card.id);
        } else {
          // If sync fails, queue for later
          await _offlineService.queuePendingChange(card.id, 'update');
        }
        
        // Simulate network delay between cards
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      _syncStatusController.add(SyncStatus(isActive: false, message: 'Synced ${syncedIds.length} of ${unsyncedCards.length} cards'));
      return syncedIds;
    } catch (e) {
      _syncStatusController.add(SyncStatus(isActive: false, message: 'Sync failed: $e'));
      debugPrint('Error syncing offline changes: $e');
      return [];
    }
  }

  // sync card data between local and remote with conflict resolution
  Future<Map<String, List<LoyaltyCard>>> synchronize(List<LoyaltyCard> localCards) async {
    if (!await isConnected()) {
      return {
        'updatedCards': [],
        'newCards': [],
      };
    }

    _syncStatusController.add(SyncStatus(isActive: true, message: 'Syncing with server...'));
    
    try {
      // Get cards from server
      final remoteCards = await fetchCards();
      
      // Identify new remote cards (not in local)
      final localCardIds = localCards.map((c) => c.id).toSet();
      final newCards = remoteCards.where((c) => !localCardIds.contains(c.id)).toList();
      
      // Cache new cards for offline access
      for (final card in newCards) {
        await _cacheCardData(card);
      }
      
      // Identify cards that need updating with conflict resolution
      final updatedCards = <LoyaltyCard>[];
      final remoteCardMap = {for (var c in remoteCards) c.id: c};
      
      for (final localCard in localCards) {
        if (remoteCardMap.containsKey(localCard.id)) {
          final remoteCard = remoteCardMap[localCard.id]!;
          
          // Get pending changes
          final pendingChanges = await _offlineService.getPendingChanges();
          
          // If card has pending changes, prioritize local version
          if (pendingChanges.containsKey(localCard.id)) {
            continue; // Skip this card, will be synced later
          }
          
          // Compare last modified to determine which is newer
          if (remoteCard.lastModified.isAfter(localCard.lastModified)) {
            // Cache remote card data
            await _cacheCardData(remoteCard);
            updatedCards.add(remoteCard);
          }
        }
      }
      
      _syncStatusController.add(SyncStatus(
        isActive: false, 
        message: 'Sync completed: ${newCards.length} new, ${updatedCards.length} updated'
      ));
      
      return {
        'updatedCards': updatedCards,
        'newCards': newCards,
      };
    } catch (e) {
      _syncStatusController.add(SyncStatus(isActive: false, message: 'Sync failed: $e'));
      debugPrint('Error during synchronization: $e');
      return {
        'updatedCards': [],
        'newCards': [],
      };
    }
  }
  
  // Dispose resources
  void dispose() {
    _syncStatusController.close();
  }
}

// Class to represent sync status
class SyncStatus {
  final bool isActive;
  final String message;
  
  SyncStatus({required this.isActive, required this.message});
} 