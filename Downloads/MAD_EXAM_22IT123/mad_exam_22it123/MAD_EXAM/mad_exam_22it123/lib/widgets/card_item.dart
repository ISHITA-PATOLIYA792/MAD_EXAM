import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';

class CardItem extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CardItem({
    Key? key,
    required this.card,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd/yyyy');
    final cardColor = card.cardColor;
    
    return Dismissible(
      key: ValueKey(card.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        if (onDelete == null) return Future.value(false);
        
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Card?'),
            content: Text(
              'Are you sure you want to delete the ${card.name} card?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Left colored bar
              Container(
                width: 6,
                height: 90,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
              ),
              // Card content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Card logo/image
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: card.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(card.imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.card_membership,
                                color: Colors.grey.shade600,
                                size: 30,
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Card details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              card.issuer,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.cardNumber,
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Courier',
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Used date
                                if (card.lastUsed != null) ...[
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Used: ${dateFormat.format(card.lastUsed!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                                
                                // Expiry date
                                if (card.expirationDate != null) ...[
                                  const Spacer(),
                                  Icon(
                                    Icons.event,
                                    size: 14,
                                    color: card.isExpiringSoon ? Colors.orange : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Expires: ${dateFormat.format(card.expirationDate!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: card.isExpiringSoon ? Colors.orange : Colors.grey.shade600,
                                      fontWeight: card.isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 