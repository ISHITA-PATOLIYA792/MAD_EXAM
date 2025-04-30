import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';
import 'package:mad_exam_22it123/utils/validators.dart';
import 'package:mad_exam_22it123/utils/constants.dart';
import 'package:mad_exam_22it123/widgets/category_chip.dart';

class AddCardScreen extends StatefulWidget {
  final LoyaltyCard? existingCard;

  const AddCardScreen({
    Key? key,
    this.existingCard,
  }) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedExpiryDate;
  File? _selectedImage;
  String? _selectedImagePath;
  Color _selectedColor = Colors.blue;
  CardCategory _selectedCategory = CardCategory.retail;
  BarcodeType _selectedBarcodeType = BarcodeType.barcode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing an existing card, populate the form
    if (widget.existingCard != null) {
      final card = widget.existingCard!;
      _nameController.text = card.name;
      _issuerController.text = card.issuer;
      _cardNumberController.text = card.cardNumber;
      _selectedExpiryDate = card.expirationDate;
      if (_selectedExpiryDate != null) {
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(_selectedExpiryDate!);
      }
      if (card.imagePath != null) {
        _selectedImagePath = card.imagePath;
        _selectedImage = File(card.imagePath!);
      }
      _selectedColor = card.cardColor;
      _selectedCategory = card.category;
      _selectedBarcodeType = card.barcodeType;
      if (card.notes != null) {
        _notesController.text = card.notes!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );

      if (pickedImage == null) return;

      setState(() {
        _selectedImage = File(pickedImage.path);
        _selectedImagePath = pickedImage.path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        _selectedBarcodeType == BarcodeType.qrCode 
            ? ScanMode.QR 
            : ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1') {
        setState(() {
          _cardNumberController.text = barcodeScanRes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 365));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedExpiryDate = pickedDate;
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);

      final newCard = LoyaltyCard(
        id: widget.existingCard?.id,
        name: _nameController.text,
        issuer: _issuerController.text,
        cardNumber: _cardNumberController.text,
        barcode: _cardNumberController.text, // For simplicity, using card number as barcode
        barcodeType: _selectedBarcodeType,
        expirationDate: _selectedExpiryDate,
        imagePath: _selectedImagePath,
        cardColor: _selectedColor,
        category: _selectedCategory,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.existingCard?.createdAt,
      );

      if (widget.existingCard != null) {
        await cardProvider.updateCard(newCard);
      } else {
        await cardProvider.addCard(newCard);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving card: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCard == null ? 'Add New Card' : 'Edit Card'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Card Information Section
                  const Text(
                    'Card Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Card Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Card Name *',
                      hintText: 'e.g. Starbucks Rewards',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a card name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Issuer
                  TextFormField(
                    controller: _issuerController,
                    decoration: const InputDecoration(
                      labelText: 'Issuer *',
                      hintText: 'e.g. Starbucks',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the card issuer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Card Number with Scan Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Card Number *',
                            hintText: 'Enter card number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the card number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 59,
                        child: ElevatedButton(
                          onPressed: _scanBarcode,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Barcode Type Selector
                  const Text(
                    'Barcode Type',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedBarcodeType = BarcodeType.barcode;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedBarcodeType == BarcodeType.barcode
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade200,
                            foregroundColor: _selectedBarcodeType == BarcodeType.barcode
                                ? Colors.white
                                : Colors.black,
                            elevation: _selectedBarcodeType == BarcodeType.barcode ? 2 : 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text('Barcode'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedBarcodeType = BarcodeType.qrCode;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedBarcodeType == BarcodeType.qrCode
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade200,
                            foregroundColor: _selectedBarcodeType == BarcodeType.qrCode
                                ? Colors.white
                                : Colors.black,
                            elevation: _selectedBarcodeType == BarcodeType.qrCode ? 2 : 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code, size: 16),
                              const SizedBox(width: 4),
                              const Text('QR Code'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Appearance Section
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Logo/Image Selector
                  const Text('Logo'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select Image',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Card Color Selector
                  const Text('Card Color'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: cardColorOptions.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: _selectedColor == color
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Selector
                  const Text('Category'),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: CardCategory.values.map((category) {
                        return CategoryChip(
                          category: category,
                          isSelected: _selectedCategory == category,
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Additional Details Section
                  const Text(
                    'Additional Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Expiry Date
                  TextFormField(
                    controller: _expiryDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Add any additional information about this card',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveCard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Save Card'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
} 