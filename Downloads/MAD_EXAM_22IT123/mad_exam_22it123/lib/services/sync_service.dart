import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/services/encryption_service.dart';

// mock service to simulate sync with a server
class SyncService {
  final Random _random = Random();
  
  // singleton instance
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // use a mock API endpoint (in a real app, use a real API)
  static const String _baseUrl = 'https://mockapi.example.com/api';
  
  final _encryptionService = EncryptionService();
  final _sensitiveFields = ['cardNumber', 'barcode'];

  // check if device is connected to the internet
  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  // simulate pushing a single card to the server
  Future<bool> pushCard(LoyaltyCard card) async {
    // simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
    
    // simulate occasional failure (10% chance)
    if (_random.nextInt(10) == 0) {
      return false;
    }
    
    return true;
  }
  
  // simulate fetching all cards from the server
  Future<List<LoyaltyCard>> fetchCards() async {
    // simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    
    // in a real app, this would fetch cards from a server
    // for demo purposes, return an empty list
    return [];
  }
  
  // simulate syncing offline changes to the server
  Future<List<String>> syncOfflineChanges(List<LoyaltyCard> cards) async {
    // simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    
    // get unsynced cards
    final unsyncedCards = cards.where((card) => !card.isSynced).toList();
    
    // pretend we successfully synced most of them
    final syncedIds = <String>[];
    for (final card in unsyncedCards) {
      // simulate occasional failure (10% chance)
      if (_random.nextInt(10) != 0) {
        syncedIds.add(card.id);
      }
      
      // simulate network delay between cards
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    return syncedIds;
  }

  // sync card data between local and remote
  Future<Map<String, List<LoyaltyCard>>> synchronize(List<LoyaltyCard> localCards) async {
    if (!await isConnected()) {
      return {
        'updatedCards': [],
        'newCards': [],
      };
    }

    try {
      // get cards from server
      final remoteCards = await fetchCards();
      
      // identify new remote cards (not in local)
      final localCardIds = localCards.map((c) => c.id).toSet();
      final newCards = remoteCards.where((c) => !localCardIds.contains(c.id)).toList();
      
      // identify cards that need updating
      final updatedCards = <LoyaltyCard>[];
      final remoteCardMap = {for (var c in remoteCards) c.id: c};
      
      for (final localCard in localCards) {
        if (remoteCardMap.containsKey(localCard.id)) {
          final remoteCard = remoteCardMap[localCard.id]!;
          // compare last modified to determine which is newer
          if (remoteCard.lastModified.isAfter(localCard.lastModified)) {
            updatedCards.add(remoteCard);
          }
        }
      }
      
      return {
        'updatedCards': updatedCards,
        'newCards': newCards,
      };
    } catch (e) {
      print('Error during synchronization: $e');
      return {
        'updatedCards': [],
        'newCards': [],
      };
    }
  }
} 