import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';
import 'package:mad_exam_22it123/screens/add_card_screen.dart';

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
  LoyaltyCard? _card;
  bool _isLoading = true;
  final _dateFormat = DateFormat('MM/dd/yyyy');
  bool _isFullScreen = false;
  
  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final card = cardProvider.getCardById(widget.cardId);
      if (card != null) {
        _card = cardProvider.getDecryptedCard(card);
        
        // Mark card as used
        if (_card != null) {
          await cardProvider.updateCard(_card!.markAsUsed());
          _card = cardProvider.getDecryptedCard(
            cardProvider.getCardById(widget.cardId)!
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading card: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCard() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Card?'),
            content: Text('Are you sure you want to delete the ${_card!.name} card?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      await Provider.of<CardProvider>(context, listen: false)
          .deleteCard(_card!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting card: $e')),
      );
    }
  }

  void _editCard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddCardScreen(existingCard: _card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Card Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Card Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('The requested card could not be found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final card = _card!;
    final issuer = card.issuer;
    final category = card.category;
    final isSynced = card.isSynced;
    final cardNumber = card.cardNumber;
    final barcode = card.barcode;
    final barcodeType = card.barcodeType;
    final expiryDate = card.expirationDate;
    final lastUsed = card.lastUsed;
    final notes = card.notes;

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
                    card.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cardNumber,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 32),
                  // generate QR code for barcode value
                  QrImageView(
                    data: barcode,
                    version: QrVersions.auto,
                    size: 280,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    barcode,
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
        title: Text(card.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCard,
            tooltip: 'Edit Card',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCard,
            tooltip: 'Delete Card',
          ),
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
            // Card header with color and image
            Container(
              height: 150,
              color: card.cardColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card image or placeholder
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
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
                        : Center(
                            child: Icon(
                              Icons.card_membership,
                              color: Colors.grey.shade600,
                              size: 50,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Card details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          issuer,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const Spacer(),
                        // Sync status
                        Row(
                          children: [
                            Icon(
                              isSynced ? Icons.cloud_done : Icons.cloud_off,
                              size: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isSynced ? 'Synced to cloud' : 'Not synced',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Card number and barcode
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Card number displayed prominently
                    Column(
                      children: [
                        const Text(
                          'Card Number',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cardNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Barcode or QR Code
                    if (barcodeType == BarcodeType.qrCode)
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: QrImageView(
                          data: barcode,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                      )
                    else
                      SizedBox(
                        height: 100,
                        child: Center(
                          child: Text(
                            'Barcode Display Placeholder',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    
                    // Last used date
                    if (lastUsed != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last used: ${_dateFormat.format(lastUsed)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Additional details
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Expiry date if available
                    if (expiryDate != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.event, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Expiry Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _dateFormat.format(expiryDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: card.isExpiringSoon || card.isExpired
                                      ? Colors.red
                                      : null,
                                  fontWeight: card.isExpiringSoon || card.isExpired
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                    ],
                    
                    // Notes if available
                    if (notes != null && notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.note, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  notes,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Usage tips
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 1,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Show the barcode to the cashier at checkout. '
                      'The card will automatically be marked as used when you view it.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 