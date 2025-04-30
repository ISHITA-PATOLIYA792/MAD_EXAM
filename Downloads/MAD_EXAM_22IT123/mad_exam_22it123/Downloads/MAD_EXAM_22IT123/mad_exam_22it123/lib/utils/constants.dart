import 'package:flutter/material.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';

// Category colors
final Map<CardCategory, Color> categoryColors = {
  CardCategory.retail: Colors.blue,
  CardCategory.grocery: Colors.green,
  CardCategory.restaurant: Colors.red,
  CardCategory.travel: Colors.orange,
  CardCategory.entertainment: Colors.purple,
  CardCategory.healthBeauty: Colors.pink,
  CardCategory.other: Colors.blueGrey,
};

// Category icons
final Map<CardCategory, IconData> categoryIcons = {
  CardCategory.retail: Icons.shopping_bag,
  CardCategory.grocery: Icons.shopping_cart,
  CardCategory.restaurant: Icons.restaurant,
  CardCategory.travel: Icons.airplanemode_active,
  CardCategory.entertainment: Icons.movie,
  CardCategory.healthBeauty: Icons.favorite,
  CardCategory.other: Icons.star,
};

// Card color options
final List<Color> cardColorOptions = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.blueGrey,
  Colors.black,
];

// Format helpers
String getCategoryName(CardCategory category) {
  switch (category) {
    case CardCategory.retail:
      return 'Retail';
    case CardCategory.grocery:
      return 'Grocery';
    case CardCategory.restaurant:
      return 'Restaurant';
    case CardCategory.travel:
      return 'Travel';
    case CardCategory.entertainment:
      return 'Entertainment';
    case CardCategory.healthBeauty:
      return 'Health & Beauty';
    case CardCategory.other:
      return 'Other';
  }
} 