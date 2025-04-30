import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;
  
  const CardDetailScreen({
    Key? key,
    required this.cardId,
  }) : super(key: key);

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final _dateFormat = DateFormat('MMMM dd, yyyy');
  bool _isFullScreen = false;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (ctx, cardProvider, child) {
        final card = cardProvider.getCardById(widget.cardId);
        
        if (card == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Card Details'),
            ),
            body: const Center(
              child: Text('Card not found'),
            ),
          );
        }
        
        // decrypt card for display
        final decryptedCard = cardProvider.getDecryptedCard(card);
        
        // full screen barcode view
        if (_isFullScreen) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              onTap: () {
                setState(() {
                  _isFullScreen = false;
                });
              },
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Text(
                        decryptedCard.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        decryptedCard.cardNumber,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 32),
                      // generate QR code for barcode value
                      QrImageView(
                        data: decryptedCard.barcode,
                        version: QrVersions.auto,
                        size: 280,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        decryptedCard.barcode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 32),
                        child: Text(
                          'Tap anywhere to exit fullscreen',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        
        // normal detail view
        return Scaffold(
          appBar: AppBar(
            title: Text(decryptedCard.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: () {
                  setState(() {
                    _isFullScreen = true;
                  });
                },
                tooltip: 'Show fullscreen barcode',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card image
                if (decryptedCard.imagePath != null)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(decryptedCard.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 24),
                
                // Card details
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Card Name',
                          decryptedCard.name,
                          Icons.business,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Card Number',
                          decryptedCard.cardNumber,
                          Icons.credit_card,
                          canCopy: true,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Barcode',
                          decryptedCard.barcode,
                          Icons.qr_code,
                          canCopy: true,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Expiration Date',
                          _dateFormat.format(decryptedCard.expirationDate),
                          Icons.calendar_today,
                          isWarning: decryptedCard.isExpiringSoon,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          'Sync Status',
                          decryptedCard.isSynced ? 'Synced' : 'Not synced',
                          decryptedCard.isSynced
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          textColor: decryptedCard.isSynced
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Barcode/QR code
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Scan this code at checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        QrImageView(
                          data: decryptedCard.barcode,
                          version: QrVersions.auto,
                          size: 200,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          decryptedCard.barcode,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isFullScreen = true;
                            });
                          },
                          icon: const Icon(Icons.fullscreen),
                          label: const Text('Show Fullscreen'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // build a detail row with label and value
  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool canCopy = false,
    bool isWarning = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isWarning ? Colors.orange : Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                    color: textColor ?? (isWarning ? Colors.orange : null),
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label copied to clipboard')),
                );
              },
              tooltip: 'Copy to clipboard',
            ),
        ],
      ),
    );
  }
} 