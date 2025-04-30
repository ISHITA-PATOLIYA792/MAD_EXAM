import 'package:flutter/material.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';

// service to provide mock data for testing and demo
class MockDataService {
  // get a list of sample loyalty cards
  static List<LoyaltyCard> getSampleCards() {
    final now = DateTime.now();
    
    return [
      // RETAIL CARDS
      
      // Target card
      LoyaltyCard(
        name: 'Target Circle',
        issuer: 'Target',
        cardNumber: '8392 0475 61',
        barcode: '8392047561',
        cardColor: Colors.red,
        category: CardCategory.retail,
        barcodeType: BarcodeType.barcode,
        lastUsed: DateTime(now.year, now.month - 1, 2), // used a month ago
        isSynced: true,
      ),
      
      // Walmart card
      LoyaltyCard(
        name: 'Walmart+',
        issuer: 'Walmart',
        cardNumber: '4982 3610 75',
        barcode: '4982361075',
        cardColor: Colors.blue.shade700,
        category: CardCategory.retail,
        barcodeType: BarcodeType.barcode,
        lastUsed: DateTime(now.year, now.month, 5), // used recently
        notes: 'Free delivery on orders over $35',
        isSynced: true,
      ),
      
      // Best Buy card
      LoyaltyCard(
        name: 'Best Buy Rewards',
        issuer: 'Best Buy',
        cardNumber: '7291 0465 38',
        barcode: '7291046538',
        cardColor: Colors.yellow.shade700,
        category: CardCategory.retail,
        barcodeType: BarcodeType.qrCode,
        expirationDate: DateTime(now.year, now.month + 5, 15), // expires in 5 months
        lastUsed: DateTime(now.year, now.month - 2, 18), // used 2 months ago
        notes: '5% back on purchases',
        isSynced: false,
      ),
      
      // IKEA card
      LoyaltyCard(
        name: 'IKEA Family',
        issuer: 'IKEA',
        cardNumber: '5128 7693 04',
        barcode: '5128769304',
        cardColor: Colors.blue.shade900,
        category: CardCategory.retail,
        barcodeType: BarcodeType.barcode,
        isSynced: true,
      ),
      
      // ENTERTAINMENT CARDS
      
      // AMC Theatres
      LoyaltyCard(
        name: 'AMC Stubs',
        issuer: 'AMC Theatres',
        cardNumber: '5647 3829 10',
        barcode: '5647382910',
        cardColor: Colors.black,
        category: CardCategory.entertainment,
        barcodeType: BarcodeType.qrCode,
        expirationDate: DateTime(now.year, now.month + 2, 20), // expires in 2 months
        lastUsed: DateTime(now.year, now.month - 2, 28), // used 2 months ago
        isSynced: true,
      ),
      
      // Cinemark card
      LoyaltyCard(
        name: 'Cinemark Movie Club',
        issuer: 'Cinemark',
        cardNumber: '6329 0175 42',
        barcode: '6329017542',
        cardColor: Colors.amber.shade900,
        category: CardCategory.entertainment,
        barcodeType: BarcodeType.qrCode,
        lastUsed: DateTime(now.year, now.month - 1, 10), // used last month
        notes: '1 free ticket per month',
        isSynced: true,
      ),
      
      // Dave & Buster's card
      LoyaltyCard(
        name: 'Dave & Buster\'s Power Card',
        issuer: 'Dave & Buster\'s',
        cardNumber: '9317 2864 50',
        barcode: '9317286450',
        cardColor: Colors.blue.shade500,
        category: CardCategory.entertainment,
        barcodeType: BarcodeType.barcode,
        lastUsed: DateTime(now.year, now.month - 3, 24), // used 3 months ago
        isSynced: false,
      ),
      
      // RESTAURANT CARDS
      
      // Starbucks card
      LoyaltyCard(
        name: 'Starbucks Rewards',
        issuer: 'Starbucks',
        cardNumber: '6374 8291 03',
        barcode: '6374829103',
        cardColor: Colors.green,
        category: CardCategory.restaurant,
        barcodeType: BarcodeType.qrCode,
        expirationDate: DateTime(now.year + 1, 12, 31), // expires end of next year
        lastUsed: DateTime(now.year, now.month - 1, 15), // used a month ago
        notes: 'Free drink on birthday!',
        isSynced: true,
      ),
      
      // Chipotle card
      LoyaltyCard(
        name: 'Chipotle Rewards',
        issuer: 'Chipotle',
        cardNumber: '8126 4937 20',
        barcode: '8126493720',
        cardColor: Colors.red.shade800,
        category: CardCategory.restaurant,
        barcodeType: BarcodeType.qrCode,
        lastUsed: DateTime(now.year, now.month, 3), // used recently
        notes: '1250 points for free entrée',
        isSynced: true,
      ),
      
      // Panera card
      LoyaltyCard(
        name: 'Panera Bread MyPanera',
        issuer: 'Panera Bread',
        cardNumber: '7592 0183 46',
        barcode: '7592018346',
        cardColor: Colors.brown.shade300,
        category: CardCategory.restaurant,
        barcodeType: BarcodeType.barcode,
        expirationDate: DateTime(now.year + 1, 6, 30), // expires next year
        lastUsed: DateTime(now.year, now.month - 2, 5), // used 2 months ago
        isSynced: true,
      ),
      
      // Domino's card
      LoyaltyCard(
        name: 'Domino\'s Rewards',
        issuer: 'Domino\'s Pizza',
        cardNumber: '3649 5082 71',
        barcode: '3649508271',
        cardColor: Colors.blue.shade800,
        category: CardCategory.restaurant,
        barcodeType: BarcodeType.qrCode,
        lastUsed: DateTime(now.year, now.month - 1, 22), // used last month
        notes: '60 points = free medium pizza',
        isSynced: false,
      ),
      
      // HEALTH & BEAUTY CARDS
      
      // Sephora card
      LoyaltyCard(
        name: 'Sephora Beauty Insider',
        issuer: 'Sephora',
        cardNumber: '9283 7456 12',
        barcode: '9283745612',
        cardColor: Colors.purple,
        category: CardCategory.healthBeauty,
        barcodeType: BarcodeType.barcode,
        lastUsed: DateTime(now.year, now.month - 3, 5), // used 3 months ago
        notes: 'Currently at VIB status',
        isSynced: false,
      ),
      
      // Ulta card
      LoyaltyCard(
        name: 'Ulta Beauty Ultamate Rewards',
        issuer: 'Ulta Beauty',
        cardNumber: '5739 8621 04',
        barcode: '5739862104',
        cardColor: Colors.purple.shade200,
        category: CardCategory.healthBeauty,
        barcodeType: BarcodeType.barcode,
        lastUsed: DateTime(now.year, now.month - 1, 18), // used last month
        notes: 'Birthday gift in month of birth',
        isSynced: true,
      ),
      
      // GNC card
      LoyaltyCard(
        name: 'GNC myGNC Rewards',
        issuer: 'GNC',
        cardNumber: '4063 8275 19',
        barcode: '4063827519',
        cardColor: Colors.red.shade900,
        category: CardCategory.healthBeauty,
        barcodeType: BarcodeType.qrCode,
        lastUsed: DateTime(now.year, now.month, 1), // used recently
        isSynced: true,
      ),
      
      // CVS card
      LoyaltyCard(
        name: 'CVS ExtraCare',
        issuer: 'CVS Pharmacy',
        cardNumber: '9984 1236 70',
        barcode: '9984123670',
        cardColor: Colors.red.shade400,
        category: CardCategory.healthBeauty,
        barcodeType: BarcodeType.barcode,
        expirationDate: DateTime(now.year, now.month + 8, 15), // expires in 8 months
        lastUsed: DateTime(now.year, now.month - 2, 10), // used 2 months ago
        notes: '2% back in ExtraBucks',
        isSynced: true,
      ),
      
      // TRAVEL CARDS
      
      // Airline card
      LoyaltyCard(
        name: 'Delta SkyMiles',
        issuer: 'Delta Airlines',
        cardNumber: '2735 9184 23',
        barcode: '2735918423',
        cardColor: Colors.blue,
        category: CardCategory.travel,
        barcodeType: BarcodeType.barcode,
        lastUsed: DateTime(now.year, now.month - 4, 12), // used 4 months ago
        expirationDate: DateTime(now.year + 2, now.month, now.day), // expires in 2 years
        notes: 'Silver Medallion status, 25,000 miles',
        isSynced: true,
      ),
      
      // Southwest card
      LoyaltyCard(
        name: 'Southwest Rapid Rewards',
        issuer: 'Southwest Airlines',
        cardNumber: '8432 1670 95',
        barcode: '8432167095',
        cardColor: Colors.blue.shade800,
        category: CardCategory.travel,
        barcodeType: BarcodeType.qrCode,
        lastUsed: DateTime(now.year, now.month - 2, 20), // used 2 months ago
        notes: 'A-List status, 35,000 miles',
        isSynced: true,
      ),
      
      // Marriott card
      LoyaltyCard(
        name: 'Marriott Bonvoy',
        issuer: 'Marriott Hotels',
        cardNumber: '6182 9735 40',
        barcode: '6182973540',
        cardColor: Colors.grey.shade800,
        category: CardCategory.travel,
        barcodeType: BarcodeType.barcode,
        expirationDate: DateTime(now.year + 1, 8, 31), // expires next year
        lastUsed: DateTime(now.year, now.month - 5, 7), // used 5 months ago
        notes: 'Gold Elite status',
        isSynced: false,
      ),
      
      // Hertz card
      LoyaltyCard(
        name: 'Hertz Gold Plus Rewards',
        issuer: 'Hertz',
        cardNumber: '7298 5401 36',
        barcode: '7298540136',
        cardColor: Colors.yellow.shade800,
        category: CardCategory.travel,
        barcodeType: BarcodeType.qrCode,
        lastUsed: DateTime(now.year, now.month - 3, 15), // used 3 months ago
        isSynced: true,
      ),
      
      // GROCERY CARDS
      
      // Kroger card
      LoyaltyCard(
        name: 'Kroger Plus Card',
        issuer: 'Kroger',
        cardNumber: '3927 6054 81',
        barcode: '3927605481',
        cardColor: Colors.blue.shade400,
        category: CardCategory.grocery,
        barcodeType: BarcodeType.barcode,
        lastUsed: DateTime(now.year, now.month, 8), // used recently
        isSynced: true,
      ),
      
      // Whole Foods card
      LoyaltyCard(
        name: 'Amazon Prime @ Whole Foods',
        issuer: 'Whole Foods Market',
        cardNumber: '8137 2946 05',
        barcode: '8137294605',
        cardColor: Colors.green.shade600,
        category: CardCategory.grocery,
        barcodeType: BarcodeType.qrCode,
        lastUsed: DateTime(now.year, now.month, 2), // used recently
        notes: '10% off sale items with Prime',
        isSynced: true,
      ),
      
      // Safeway card
      LoyaltyCard(
        name: 'Safeway for U',
        issuer: 'Safeway',
        cardNumber: '5019 7382 64',
        barcode: '5019738264',
        cardColor: Colors.red.shade600,
        category: CardCategory.grocery,
        barcodeType: BarcodeType.barcode,
        lastUsed: DateTime(now.year, now.month - 1, 25), // used last month
        isSynced: false,
      ),
      
      // OTHER CARDS
      
      // Library card
      LoyaltyCard(
        name: 'Public Library Card',
        issuer: 'City Public Library',
        cardNumber: '2175 8493 06',
        barcode: '2175849306',
        cardColor: Colors.teal,
        category: CardCategory.other,
        barcodeType: BarcodeType.barcode,
        expirationDate: DateTime(now.year + 3, 4, 30), // expires in 3 years
        lastUsed: DateTime(now.year, now.month - 2, 12), // used 2 months ago
        isSynced: true,
      ),
      
      // Gym membership
      LoyaltyCard(
        name: 'Fitness Club Membership',
        issuer: 'Fitness Club',
        cardNumber: '6294 0158 73',
        barcode: '6294015873',
        cardColor: Colors.orange.shade800,
        category: CardCategory.other,
        barcodeType: BarcodeType.qrCode,
        expirationDate: DateTime(now.year + 1, 2, 28), // expires next year
        lastUsed: DateTime(now.year, now.month, 6), // used recently
        notes: 'Includes free guest passes',
        isSynced: true,
      ),
    ];
  }
} 