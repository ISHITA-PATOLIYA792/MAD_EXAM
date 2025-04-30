import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';

class Offer {
  final String title;
  final String description;
  final String cardId;
  final Color color;
  final String? imageUrl;
  final DateTime expiryDate;

  Offer({
    required this.title,
    required this.description,
    required this.cardId,
    required this.color,
    this.imageUrl,
    required this.expiryDate,
  });
}

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  // mock offers for demo
  final List<Offer> _mockOffers = [
    Offer(
      title: 'CURABITUR SEMPER TINCIDUNT SAGITTIS',
      description: 'Lorem Ipsum Dolor Sit Amet',
      cardId: '1',
      color: Colors.amber,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
    ),
    Offer(
      title: 'HELLO DEAR',
      description: 'Morumque 10, vlakkem 7',
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      cardId: '2',
      color: Colors.pink.shade100,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
    ),
    Offer(
      title: '20% OFF All Products',
      description: 'Use your loyalty card for an extra 5% discount',
      cardId: '3',
      color: Colors.blue.shade100,
      expiryDate: DateTime.now().add(const Duration(days: 3)),
    ),
    Offer(
      title: 'Buy One Get One Free',
      description: 'On all coffee purchases this weekend',
      cardId: '4',
      color: Colors.brown.shade100,
      expiryDate: DateTime.now().add(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink.shade100,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Offers header
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.pink.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '10 offers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Offers list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockOffers.length,
              itemBuilder: (context, index) {
                final offer = _mockOffers[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Offer header with color
                      Container(
                        height: 100,
                        width: double.infinity,
                        color: offer.color,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              offer.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Offer details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (offer.imageUrl != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  offer.imageUrl!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Expiry date
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'Expires in ${_getDaysLeft(offer.expiryDate)} days',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Redeem button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _redeemOffer(offer),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: offer.color,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Redeem Offer'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  int _getDaysLeft(DateTime expiryDate) {
    return expiryDate.difference(DateTime.now()).inDays;
  }
  
  void _redeemOffer(Offer offer) {
    // This would normally connect to a backend to redeem the offer
    // For now, just show a dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redeem Offer'),
        content: Text('You\'ve redeemed: ${offer.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 