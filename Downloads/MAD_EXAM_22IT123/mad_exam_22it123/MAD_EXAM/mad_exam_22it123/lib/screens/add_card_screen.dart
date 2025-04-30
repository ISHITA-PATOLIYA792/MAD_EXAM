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

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));
  File? _cardImage;
  bool _isLoading = false;
  
  final _dateFormat = DateFormat('MM/dd/yyyy');

  // pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imageFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
      );
      
      if (imageFile == null) return;
      
      setState(() {
        _cardImage = File(imageFile.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  // scan barcode
  Future<void> _scanBarcode() async {
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      
      // user canceled
      if (barcode == '-1') return;
      
      setState(() {
        _barcodeController.text = barcode;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning barcode: $e')),
      );
    }
  }
  
  // select expiration date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }
  
  // save the card
  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      String? imagePath;
      
      // save the image file if selected
      if (_cardImage != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await _cardImage!.copy('${appDir.path}/$fileName');
        imagePath = savedImage.path;
      }
      
      // create card
      final newCard = LoyaltyCard(
        name: _nameController.text.trim(),
        cardNumber: _cardNumberController.text.trim(),
        barcode: _barcodeController.text.trim(),
        expirationDate: _expirationDate,
        imagePath: imagePath,
      );
      
      // save card
      await Provider.of<CardProvider>(context, listen: false).addCard(newCard);
      
      // show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding card: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loyalty Card'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // card image
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Gallery'),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_camera),
                                  title: const Text('Camera'),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _cardImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _cardImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Card Image',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // card name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Card Name',
                        hintText: 'e.g. Starbucks, Target',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: Validators.validateCardName,
                    ),
                    const SizedBox(height: 16),
                    
                    // card number
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'Enter number on card',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      validator: Validators.validateCardNumber,
                    ),
                    const SizedBox(height: 16),
                    
                    // barcode
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barcode',
                        hintText: 'Enter barcode number',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.qr_code),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: _scanBarcode,
                          tooltip: 'Scan barcode',
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: Validators.validateBarcode,
                    ),
                    const SizedBox(height: 16),
                    
                    // expiration date
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Expiration Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: _dateFormat.format(_expirationDate),
                          ),
                          validator: (_) => Validators.validateExpirationDate(_expirationDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // save button
                    ElevatedButton(
                      onPressed: _saveCard,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Card',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 