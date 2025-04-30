import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/services/encryption_service.dart';

class SyncService {
  // singleton instance
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // use a mock API endpoint (in a real app, use a real API)
  static const String _baseUrl = 'https://mockapi.example.com/api';
  
  final _encryptionService = EncryptionService();
  final _sensitiveFields = ['cardNumber', 'barcode'];

  // check internet connectivity
  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // pull all cards from server
  Future<List<LoyaltyCard>> fetchCards() async {
    if (!await isConnected()) {
      throw Exception('No internet connection');
    }

    try {
      // simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));
      
      // mock response for simulation
      final mockResponse = {
        'status': 'success',
        'data': [
          {
            'id': '1',
            'name': 'Starbucks',
            'cardNumber': 'SB1234567890',
            'barcode': '987654321',
            'expirationDate': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
            'imagePath': null,
            'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            'lastModified': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          },
          {
            'id': '2',
            'name': 'Target',
            'cardNumber': 'TG0987654321',
            'barcode': '123456789',
            'expirationDate': DateTime.now().add(const Duration(days: 180)).toIso8601String(),
            'imagePath': null,
            'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
            'lastModified': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
          }
        ]
      };

      // in real app, make actual http request
      // final response = await http.get(Uri.parse('$_baseUrl/cards'));
      // if (response.statusCode != 200) {
      //   throw Exception('Failed to fetch cards: ${response.statusCode}');
      // }
      // final data = json.decode(response.body);

      final List<dynamic> cardsJson = mockResponse['data'] as List;
      return cardsJson.map((cardJson) {
        final decryptedData = _encryptionService.decryptMap(cardJson, _sensitiveFields);
        return LoyaltyCard.fromJson(decryptedData);
      }).toList();
    } catch (e) {
      print('Error fetching cards: $e');
      throw Exception('Failed to fetch cards: $e');
    }
  }

  // push a new card to server
  Future<bool> pushCard(LoyaltyCard card) async {
    if (!await isConnected()) {
      return false; // can't sync without connection
    }

    try {
      // encrypt sensitive fields before sending
      final cardJson = card.toJson();
      final encryptedData = _encryptionService.encryptMap(cardJson, _sensitiveFields);
      
      // simulate API call with delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // in real app, make actual http request
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/cards'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(encryptedData),
      // );
      // return response.statusCode == 201;
      
      // mock successful response
      return true;
    } catch (e) {
      print('Error pushing card: $e');
      return false;
    }
  }

  // sync offline changes with server
  Future<List<String>> syncOfflineChanges(List<LoyaltyCard> offlineCards) async {
    if (!await isConnected()) {
      return []; // can't sync without connection
    }

    final List<String> syncedCardIds = [];
    
    for (final card in offlineCards) {
      if (!card.isSynced) {
        final success = await pushCard(card);
        if (success) {
          syncedCardIds.add(card.id);
        }
      }
    }
    
    return syncedCardIds;
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