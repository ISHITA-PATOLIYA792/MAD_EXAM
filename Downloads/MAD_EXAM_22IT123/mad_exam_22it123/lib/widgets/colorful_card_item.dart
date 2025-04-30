import 'package:flutter/material.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';

class ColorfulCardItem extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback onTap;
  final int points;

  const ColorfulCardItem({
    Key? key,
    required this.card,
    required this.onTap,
    required this.points,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine text color based on background brightness
    final Color textColor = _isColorBright(card.cardColor) 
        ? Colors.black87 
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 110,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: card.cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              card.name,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$points points',
              style: TextStyle(
                color: textColor.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to determine if a color is bright (for text contrast)
  bool _isColorBright(Color color) {
    return (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) > 186;
  }
} 