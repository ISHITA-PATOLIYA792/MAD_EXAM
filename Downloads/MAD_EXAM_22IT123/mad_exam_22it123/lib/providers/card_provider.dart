import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/services/encryption_service.dart';
import 'package:mad_exam_22it123/services/sync_service.dart';
import 'package:mad_exam_22it123/services/notification_service.dart';
import 'package:mad_exam_22it123/services/mock_data_service.dart';
import 'package:mad_exam_22it123/services/offline_service.dart';

// Manual Hive adapter for LoyaltyCard
class LoyaltyCardAdapter extends TypeAdapter<LoyaltyCard> {
  @override
  final int typeId = 0;

  @override
  LoyaltyCard read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final issuer = reader.readString();
    final cardNumber = reader.readString();
    final barcode = reader.readString();
    final barcodeType = reader.readInt() == 1 ? BarcodeType.qrCode : BarcodeType.barcode;
    
    final hasExpDate = reader.readBool();
    final expirationDate = hasExpDate ? DateTime.parse(reader.readString()) : null;
    
    final imagePath = reader.readBool() ? reader.readString() : null;
    final cardColor = Color(reader.readInt());
    final categoryIndex = reader.readInt();
    final category = CardCategory.values[categoryIndex];
    
    final isSynced = reader.readBool();
    final createdAt = DateTime.parse(reader.readString());
    final lastModified = DateTime.parse(reader.readString());
    
    final hasLastUsed = reader.readBool();
    final lastUsed = hasLastUsed ? DateTime.parse(reader.readString()) : null;
    
    final hasNotes = reader.readBool();
    final notes = hasNotes ? reader.readString() : null;

    return LoyaltyCard(
      id: id,
      name: name,
      issuer: issuer,
      cardNumber: cardNumber,
      barcode: barcode,
      barcodeType: barcodeType,
      expirationDate: expirationDate,
      imagePath: imagePath,
      cardColor: cardColor,
      category: category,
      isSynced: isSynced,
      createdAt: createdAt,
      lastModified: lastModified,
      lastUsed: lastUsed,
      notes: notes,
    );
  }

  @override
  void write(BinaryWriter writer, LoyaltyCard obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.issuer);
    writer.writeString(obj.cardNumber);
    writer.writeString(obj.barcode);
    writer.writeInt(obj.barcodeType == BarcodeType.qrCode ? 1 : 0);
    
    writer.writeBool(obj.expirationDate != null);
    if (obj.expirationDate != null) {
      writer.writeString(obj.expirationDate!.toIso8601String());
    }
    
    writer.writeBool(obj.imagePath != null);
    if (obj.imagePath != null) {
      writer.writeString(obj.imagePath!);
    }
    
    writer.writeInt(obj.cardColor.value);
    writer.writeInt(obj.category.index);
    
    writer.writeBool(obj.isSynced);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.lastModified.toIso8601String());
    
    writer.writeBool(obj.lastUsed != null);
    if (obj.lastUsed != null) {
      writer.writeString(obj.lastUsed!.toIso8601String());
    }
    
    writer.writeBool(obj.notes != null);
    if (obj.notes != null) {
      writer.writeString(obj.notes!);
    }
  }
}

class CardProvider with ChangeNotifier {
  static const String _boxName = 'loyalty_cards';
  
  final EncryptionService _encryptionService = EncryptionService();
  final SyncService _syncService = SyncService();
  final NotificationService _notificationService = NotificationService();
  final OfflineService _offlineService = OfflineService();
  
  List<LoyaltyCard> _cards = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  
  // getters
  List<LoyaltyCard> get cards => _cards;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  
  // get cards by category
  List<LoyaltyCard> getCardsByCategory(CardCategory category) {
    return _cards.where((card) => card.category == category).toList();
  }
  
  // get count of cards by category
  int getCardCountByCategory(CardCategory category) {
    return getCardsByCategory(category).length;
  }
  
  // get all categories with at least one card
  List<CardCategory> get categories {
    final Set<CardCategory> result = {};
    for (final card in _cards) {
      result.add(card.category);
    }
    return result.toList();
  }
  
  // search cards by query
  List<LoyaltyCard> searchCards(String query) {
    if (query.isEmpty) return _cards;
    
    query = query.toLowerCase();
    return _cards.where((card) {
      final decryptedCard = getDecryptedCard(card);
      return 
        decryptedCard.name.toLowerCase().contains(query) ||
        decryptedCard.issuer.toLowerCase().contains(query) ||
        decryptedCard.cardNumber.toLowerCase().contains(query);
    }).toList();
  }
  
  // initialize hive and load cards
  Future<void> init() async {
    try {
      _setLoading(true);
      
      // Initialize services
      await _encryptionService.init();
      await _offlineService.init();
      await _syncService.init();
      
      // Subscribe to sync status updates
      _syncService.syncStatusStream.listen((status) {
        _isSyncing = status.isActive;
        notifyListeners();
      });
      
      // initialize Hive
      await Hive.initFlutter();
      
      // register adapter
      if (!Hive.isAdapterRegistered(0)) {
        // Register our manual adapter
        Hive.registerAdapter(LoyaltyCardAdapter());
      }
      
      // open the box
      final box = await Hive.openBox<LoyaltyCard>(_boxName);
      
      // load cards from box
      _cards = box.values.toList();
      
      // If no cards exist, add sample cards (for demo purposes)
      if (_cards.isEmpty) {
        final sampleCards = MockDataService.getSampleCards();
        for (final card in sampleCards) {
          // Cards will be encrypted when added
          await addCard(card);
        }
        // Reload cards from box after adding samples
        _cards = box.values.toList();
      }
      
      // Check all cards for expiration and set up reminders
      for (final card in _cards) {
        if (card.expirationDate != null) {
          await _notificationService.scheduleExpirationReminder(card);
        }
      }
      
      // check for expiring cards for immediate notifications
      _notificationService.checkForExpiringCards(_cards);
      
      // sync with server if online
      syncWithServer();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize: $e');
    }
  }
  
  // add a new card
  Future<void> addCard(LoyaltyCard card) async {
    try {
      // encrypt sensitive data
      final encryptedCardNumber = _encryptionService.encrypt(card.cardNumber);
      final encryptedBarcode = _encryptionService.encrypt(card.barcode);
      
      // create card with encrypted data
      final encryptedCard = card.copyWith(
        cardNumber: encryptedCardNumber,
        barcode: encryptedBarcode,
      );
      
      // save to local storage
      final box = await Hive.openBox<LoyaltyCard>(_boxName);
      await box.put(card.id, encryptedCard);
      
      // add to cards list
      _cards.add(encryptedCard);
      notifyListeners();
      
      // Cache card data for offline access
      if (card.imagePath != null) {
        await _offlineService.cacheCardImage(card.id, card.imagePath);
      }
      await _offlineService.cacheBarcode(card.id, card.barcode, card.barcodeType);
      
      // Schedule expiration reminders if applicable
      if (card.expirationDate != null) {
        await _notificationService.scheduleExpirationReminder(card);
      }
      
      // try to sync with server
      final syncSuccess = await _syncService.pushCard(encryptedCard);
      
      if (!syncSuccess) {
        // If sync fails, queue for later syncing
        await _offlineService.queuePendingChange(card.id, 'add');
      } else {
        // Mark as synced if successful
        final syncedCard = encryptedCard.markAsSynced();
        await box.put(card.id, syncedCard);
        
        // Update in-memory list
        final index = _cards.indexWhere((c) => c.id == card.id);
        if (index != -1) {
          _cards[index] = syncedCard;
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to add card: $e');
    }
  }
  
  // update an existing card
  Future<void> updateCard(LoyaltyCard updatedCard) async {
    try {
      // encrypt sensitive data if not already encrypted
      String cardNumber = updatedCard.cardNumber;
      String barcode = updatedCard.barcode;
      
      // assume data is not encrypted if it doesn't look like base64
      final base64Regex = RegExp(r'^[A-Za-z0-9+/=]+$');
      if (!base64Regex.hasMatch(cardNumber)) {
        cardNumber = _encryptionService.encrypt(cardNumber);
      }
      
      if (!base64Regex.hasMatch(barcode)) {
        barcode = _encryptionService.encrypt(barcode);
      }
      
      // create card with encrypted data
      final encryptedCard = updatedCard.copyWith(
        cardNumber: cardNumber,
        barcode: barcode,
        lastModified: DateTime.now(),
        isSynced: false,
      );
      
      // update in local storage
      final box = await Hive.openBox<LoyaltyCard>(_boxName);
      await box.put(updatedCard.id, encryptedCard);
      
      // update in cards list
      final index = _cards.indexWhere((c) => c.id == updatedCard.id);
      if (index != -1) {
        _cards[index] = encryptedCard;
        notifyListeners();
      }
      
      // Check if expiration date changed and update reminders
      final oldCard = getCardById(updatedCard.id);
      if (oldCard != null && 
          oldCard.expirationDate != updatedCard.expirationDate &&
          updatedCard.expirationDate != null) {
        await _notificationService.scheduleExpirationReminder(updatedCard);
      }
      
      // Cache for offline access
      if (updatedCard.imagePath != null) {
        await _offlineService.cacheCardImage(updatedCard.id, updatedCard.imagePath);
      }
      await _offlineService.cacheBarcode(updatedCard.id, updatedCard.barcode, updatedCard.barcodeType);
      
      // try to sync with server
      final syncSuccess = await _syncService.pushCard(encryptedCard);
      
      if (!syncSuccess) {
        // If sync fails, queue for later syncing
        await _offlineService.queuePendingChange(updatedCard.id, 'update');
      } else {
        // Mark as synced if successful
        final syncedCard = encryptedCard.markAsSynced();
        await box.put(updatedCard.id, syncedCard);
        
        // Update in-memory list
        final index = _cards.indexWhere((c) => c.id == updatedCard.id);
        if (index != -1) {
          _cards[index] = syncedCard;
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to update card: $e');
    }
  }
  
  // delete a card
  Future<void> deleteCard(String id) async {
    try {
      // Queue delete operation in case we're offline
      await _offlineService.queuePendingChange(id, 'delete');
      
      // delete from local storage
      final box = await Hive.openBox<LoyaltyCard>(_boxName);
      await box.delete(id);
      
      // delete from cards list
      _cards.removeWhere((card) => card.id == id);
      notifyListeners();
      
      // Try to sync deletion with server
      if (await _syncService.isConnected()) {
        bool success = await _syncService.pushCard(
          LoyaltyCard(
            id: id,
            name: 'deleted',
            issuer: 'deleted',
            cardNumber: 'deleted',
            barcode: 'deleted',
            isSynced: false,
            lastModified: DateTime.now(),
          )
        );
        
        if (success) {
          // Remove from pending changes
          await _offlineService.clearPendingChange(id);
        }
      }
    } catch (e) {
      _setError('Failed to delete card: $e');
    }
  }
  
  // reset database and reload sample cards
  Future<void> resetAndLoadSampleCards() async {
    try {
      _setLoading(true);
      
      // clear local storage
      final box = await Hive.openBox<LoyaltyCard>(_boxName);
      await box.clear();
      
      // clear cards list
      _cards = [];
      
      // add sample cards
      final sampleCards = MockDataService.getSampleCards();
      for (final card in sampleCards) {
        await addCard(card);
      }
      
      // reload cards from box
      _cards = box.values.toList();
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset database: $e');
    }
  }
  
  // get a card by id
  LoyaltyCard? getCardById(String id) {
    try {
      return _cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // get decrypted card data (for display)
  LoyaltyCard getDecryptedCard(LoyaltyCard card) {
    try {
      final decryptedCardNumber = _encryptionService.decrypt(card.cardNumber);
      final decryptedBarcode = _encryptionService.decrypt(card.barcode);
      
      return card.copyWith(
        cardNumber: decryptedCardNumber,
        barcode: decryptedBarcode,
      );
    } catch (e) {
      _setError('Failed to decrypt card: $e');
      return card;
    }
  }
  
  // sync all cards with server
  Future<void> syncWithServer() async {
    try {
      _setSyncing(true);
      
      // First, check if we're online
      if (!await _syncService.isConnected()) {
        _setSyncing(false);
        return;
      }
      
      // sync offline changes to server
      final syncedIds = await _syncService.syncOfflineChanges(_cards);
      
      if (syncedIds.isNotEmpty) {
        // update sync status for synced cards
        final box = await Hive.openBox<LoyaltyCard>(_boxName);
        
        for (final id in syncedIds) {
          final card = getCardById(id);
          if (card != null) {
            final syncedCard = card.markAsSynced();
            await box.put(id, syncedCard);
            
            // Clear from pending changes
            await _offlineService.clearPendingChange(id);
            
            // update in cards list
            final index = _cards.indexWhere((c) => c.id == id);
            if (index != -1) {
              _cards[index] = syncedCard;
            }
          }
        }
        
        notifyListeners();
      }
      
      // get updates from server
      final syncResult = await _syncService.synchronize(_cards);
      final updatedCards = syncResult['updatedCards'] ?? [];
      final newCards = syncResult['newCards'] ?? [];
      
      if (updatedCards.isNotEmpty || newCards.isNotEmpty) {
        final box = await Hive.openBox<LoyaltyCard>(_boxName);
        
        // update existing cards
        for (final updatedCard in updatedCards) {
          // encrypt sensitive data before storing
          final encryptedCardNumber = _encryptionService.encrypt(updatedCard.cardNumber);
          final encryptedBarcode = _encryptionService.encrypt(updatedCard.barcode);
          
          final encryptedCard = updatedCard.copyWith(
            cardNumber: encryptedCardNumber,
            barcode: encryptedBarcode,
            isSynced: true,
          );
          
          await box.put(updatedCard.id, encryptedCard);
          
          // update in cards list
          final index = _cards.indexWhere((c) => c.id == updatedCard.id);
          if (index != -1) {
            _cards[index] = encryptedCard;
          }
          
          // Set up expiration reminders
          if (encryptedCard.expirationDate != null) {
            await _notificationService.scheduleExpirationReminder(encryptedCard);
          }
          
          // Cache for offline access
          await _offlineService.cacheBarcode(
            encryptedCard.id, 
            updatedCard.barcode, 
            encryptedCard.barcodeType
          );
        }
        
        // add new cards
        for (final newCard in newCards) {
          // encrypt sensitive data before storing
          final encryptedCardNumber = _encryptionService.encrypt(newCard.cardNumber);
          final encryptedBarcode = _encryptionService.encrypt(newCard.barcode);
          
          final encryptedCard = newCard.copyWith(
            cardNumber: encryptedCardNumber,
            barcode: encryptedBarcode,
            isSynced: true,
          );
          
          await box.put(newCard.id, encryptedCard);
          
          // add to cards list
          _cards.add(encryptedCard);
          
          // Set up expiration reminders
          if (encryptedCard.expirationDate != null) {
            await _notificationService.scheduleExpirationReminder(encryptedCard);
          }
          
          // Cache for offline access
          await _offlineService.cacheBarcode(
            encryptedCard.id, 
            newCard.barcode, 
            encryptedCard.barcodeType
          );
        }
        
        // notify listeners if any changes
        if (updatedCards.isNotEmpty || newCards.isNotEmpty) {
          notifyListeners();
        }
      }
      
      _setSyncing(false);
    } catch (e) {
      _setError('Failed to sync with server: $e');
      _setSyncing(false);
    }
  }
  
  // utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setSyncing(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }
  
  void _setError(String? errorMsg) {
    _error = errorMsg;
    _isLoading = false;
    _isSyncing = false;
    notifyListeners();
  }
} 