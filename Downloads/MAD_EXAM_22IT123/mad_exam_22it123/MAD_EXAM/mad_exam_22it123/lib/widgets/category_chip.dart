import 'package:flutter/material.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final CardCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.category,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[category] ?? Colors.grey;
    final categoryName = getCategoryName(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Chip(
          label: Text(
            categoryName,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
          backgroundColor: isSelected 
              ? color 
              : Colors.transparent,
          side: BorderSide(
            color: color,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final CardCategory category;
  final int cardCount;
  final VoidCallback onTap;

  const CategoryTile({
    Key? key,
    required this.category,
    required this.cardCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[category] ?? Colors.grey;
    final icon = categoryIcons[category] ?? Icons.credit_card;
    final categoryName = getCategoryName(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$cardCount cards",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 