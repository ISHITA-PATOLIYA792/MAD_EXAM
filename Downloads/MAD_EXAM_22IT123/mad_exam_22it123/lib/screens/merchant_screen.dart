import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';

class MerchantScreen extends StatefulWidget {
  final String cardId;
  
  const MerchantScreen({
    Key? key, 
    required this.cardId,
  }) : super(key: key);

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  LoyaltyCard? _card;
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Card', 'History', 'Notes'];
  
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
  
  void _copyBarcodeToClipboard() {
    if (_card == null) return;
    
    Clipboard.setData(ClipboardData(text: _card!.barcode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barcode copied to clipboard')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Merchant')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Merchant')),
        body: const Center(child: Text('Card not found')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade200,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {
              // Show options menu
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Card'),
                      onTap: () {
                        Navigator.pop(ctx);
                        // Add edit functionality
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.copy),
                      title: const Text('Copy Barcode'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _copyBarcodeToClipboard();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('Share Card'),
                      onTap: () {
                        Navigator.pop(ctx);
                        // Add share functionality
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with merchant name
          Container(
            color: Colors.amber.shade200,
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 20,
            ),
            child: Text(
              'Merchant',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          
          // Tabs
          Container(
            color: Colors.amber.shade200,
            child: Row(
              children: List.generate(
                _tabs.length,
                (index) => Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: _selectedTabIndex == index 
                                  ? Colors.black 
                                  : Colors.black54,
                              fontWeight: _selectedTabIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        // Indicator line
                        Container(
                          height: 3,
                          color: _selectedTabIndex == index
                              ? Colors.black
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Card content
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                // Card tab
                _buildCardTab(),
                
                // History tab
                Center(child: Text('Transaction History Coming Soon')),
                
                // Notes tab
                Center(child: Text('Notes Coming Soon')),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCardTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Card Box
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade200,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Points Display
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'points',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1,234',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Barcode/QR Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Card number display
                Text(
                  _card!.cardNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Barcode display
                _card!.barcodeType == BarcodeType.qrCode
                    ? QrImageView(
                        data: _card!.barcode,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                      )
                    : Column(
                        children: [
                          Container(
                            width: 240,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomPaint(
                              painter: BarcodePainter(data: _card!.barcode),
                              size: const Size(240, 100),
                            ),
                          ),
                        ],
                      ),
                      
                const SizedBox(height: 16),
                Text(
                  _card!.barcode,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Copy button
                OutlinedButton.icon(
                  onPressed: _copyBarcodeToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Code'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ),
          
          // Additional information
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About Customer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Customer since: Jan 2023'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.redeem, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Available Rewards: 2'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    const Text('Total Purchases: 12'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to draw a simple barcode
class BarcodePainter extends CustomPainter {
  final String data;
  
  BarcodePainter({required this.data});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    
    final double barWidth = size.width / (data.length * 2 + 2);
    double currentX = barWidth;
    
    // Draw start guard
    canvas.drawRect(
      Rect.fromLTWH(0, 0, barWidth, size.height), 
      paint
    );
    
    // Draw bars based on data
    for (int i = 0; i < data.length; i++) {
      // Use character code to determine bar thickness
      final charCode = data.codeUnitAt(i);
      final isThick = charCode % 2 == 0;
      
      // Skip every other position for white space
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            currentX, 
            0, 
            isThick ? barWidth * 1.5 : barWidth,
            isThick ? size.height : size.height * 0.7
          ),
          paint
        );
      }
      
      currentX += barWidth * 2;
    }
    
    // Draw end guard
    canvas.drawRect(
      Rect.fromLTWH(size.width - barWidth, 0, barWidth, size.height),
      paint
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 