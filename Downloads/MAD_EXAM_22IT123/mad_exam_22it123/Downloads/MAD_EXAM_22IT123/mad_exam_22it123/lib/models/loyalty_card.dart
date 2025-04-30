import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// Temporarily comment out the part directive since we don't have the generated file
// part 'loyalty_card.g.dart';

// Define card categories
enum CardCategory {
  retail,
  grocery,
  restaurant,
  travel,
  entertainment,
  healthBeauty,
  other
}

// Define barcode types
enum BarcodeType {
  barcode,
  qrCode
}

// Using HiveType annotation for documentation, but we'll implement a manual adapter
@HiveType(typeId: 0)
class LoyaltyCard {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String issuer;

  @HiveField(3)
  final String cardNumber;

  @HiveField(4)
  final String barcode;

  @HiveField(5)
  final BarcodeType barcodeType;

  @HiveField(6)
  final DateTime? expirationDate;

  @HiveField(7)
  final String? imagePath;

  @HiveField(8)
  final Color cardColor;

  @HiveField(9)
  final CardCategory category;

  @HiveField(10)
  final bool isSynced;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime lastModified;

  @HiveField(13)
  final DateTime? lastUsed;

  @HiveField(14)
  final String? notes;

  LoyaltyCard({
    String? id,
    required this.name,
    required this.issuer,
    required this.cardNumber,
    required this.barcode,
    this.barcodeType = BarcodeType.barcode,
    this.expirationDate,
    this.imagePath,
    this.cardColor = Colors.blue,
    this.category = CardCategory.retail,
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? lastModified,
    this.lastUsed,
    this.notes,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.lastModified = lastModified ?? DateTime.now();

  // copy with method for creating a new instance with some modified properties
  LoyaltyCard copyWith({
    String? name,
    String? issuer,
    String? cardNumber,
    String? barcode,
    BarcodeType? barcodeType,
    DateTime? expirationDate,
    String? imagePath,
    Color? cardColor,
    CardCategory? category,
    bool? isSynced,
    DateTime? lastModified,
    DateTime? lastUsed,
    String? notes,
  }) {
    return LoyaltyCard(
      id: this.id,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      cardNumber: cardNumber ?? this.cardNumber,
      barcode: barcode ?? this.barcode,
      barcodeType: barcodeType ?? this.barcodeType,
      expirationDate: expirationDate ?? this.expirationDate,
      imagePath: imagePath ?? this.imagePath,
      cardColor: cardColor ?? this.cardColor,
      category: category ?? this.category,
      isSynced: isSynced ?? this.isSynced,
      createdAt: this.createdAt,
      lastModified: lastModified ?? DateTime.now(),
      lastUsed: lastUsed ?? this.lastUsed,
      notes: notes ?? this.notes,
    );
  }

  // mark card as synced
  LoyaltyCard markAsSynced() {
    return copyWith(isSynced: true);
  }

  // mark card as used
  LoyaltyCard markAsUsed() {
    return copyWith(lastUsed: DateTime.now());
  }

  // check if card is expired
  bool get isExpired => expirationDate != null && expirationDate!.isBefore(DateTime.now());

  // check if card is expiring soon (within 7 days)
  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    final difference = expirationDate!.difference(now).inDays;
    return difference <= 7 && difference > 0;
  }

  // convert to map for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'cardNumber': cardNumber,
      'barcode': barcode,
      'barcodeType': barcodeType.toString(),
      'expirationDate': expirationDate?.toIso8601String(),
      'imagePath': imagePath,
      'cardColor': cardColor.value,
      'category': category.toString(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'notes': notes,
    };
  }

  // factory from json
  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'],
      name: json['name'],
      issuer: json['issuer'],
      cardNumber: json['cardNumber'],
      barcode: json['barcode'],
      barcodeType: json['barcodeType'] == 'BarcodeType.qrCode' ? BarcodeType.qrCode : BarcodeType.barcode,
      expirationDate: json['expirationDate'] != null ? DateTime.parse(json['expirationDate']) : null,
      imagePath: json['imagePath'],
      cardColor: Color(json['cardColor'] ?? Colors.blue.value),
      category: _categoryFromString(json['category']),
      isSynced: true,
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
      notes: json['notes'],
    );
  }
  
  // Helper method to convert string to category
  static CardCategory _categoryFromString(String? categoryStr) {
    if (categoryStr == null) return CardCategory.retail;
    
    try {
      if (categoryStr.contains('CardCategory.')) {
        final enumString = categoryStr.split('.')[1];
        return CardCategory.values.firstWhere(
          (e) => e.toString().split('.')[1] == enumString,
          orElse: () => CardCategory.retail,
        );
      }
      return CardCategory.retail;
    } catch (_) {
      return CardCategory.retail;
    }
  }
} 