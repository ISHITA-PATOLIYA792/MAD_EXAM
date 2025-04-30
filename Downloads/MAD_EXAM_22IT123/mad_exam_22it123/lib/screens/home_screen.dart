import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';
import 'package:mad_exam_22it123/screens/add_card_screen.dart';
import 'package:mad_exam_22it123/screens/card_detail_screen.dart';
import 'package:mad_exam_22it123/screens/category_screen.dart';
import 'package:mad_exam_22it123/screens/merchant_screen.dart';
import 'package:mad_exam_22it123/utils/constants.dart';
import 'package:mad_exam_22it123/widgets/card_item.dart';
import 'package:mad_exam_22it123/widgets/colorful_card_item.dart';
import 'package:mad_exam_22it123/widgets/category_chip.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dateFormat = DateFormat('MM/dd/yyyy');
  bool _isInit = false;
  String _searchQuery = '';
  CardCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initialize once
    if (!_isInit) {
      _initializeProvider();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeProvider() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    await cardProvider.init();
  }

  Future<void> _refreshCards() async {
    await Provider.of<CardProvider>(context, listen: false).syncWithServer();
  }

  void _showCategoriesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const CategoryScreen(),
      ),
    );
  }

  void _addNewCard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddCardScreen(),
      ),
    );
  }

  // Mock point values for cards (in a real app, these would come from backend)
  int _getMockPointsForCard(LoyaltyCard card) {
    // Simple mock: use the hash of card ID to get semi-random points 
    // between 100 and 999
    final hash = card.id.hashCode.abs();
    return 100 + (hash % 900);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cards',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple.shade100,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Consumer<CardProvider>(
        builder: (ctx, cardProvider, child) {
          if (cardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cardProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${cardProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeProvider,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter cards based on search and category
          List<LoyaltyCard> filteredCards = cardProvider.cards;
          
          if (_searchQuery.isNotEmpty) {
            filteredCards = cardProvider.searchCards(_searchQuery);
          }
          
          if (_selectedCategory != null) {
            filteredCards = filteredCards
                .where((card) => card.category == _selectedCategory)
                .toList();
          }
          
          // Decrypt cards for display
          final decryptedCards = filteredCards
              .map((card) => cardProvider.getDecryptedCard(card))
              .toList();

          return Stack(
            children: [
              // Header with purple background and card count
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.deepPurple.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${decryptedCards.length} cards',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                children: [
                  SizedBox(height: 80), // Space for header
                  
                  // Colorful Card Grid
                  if (decryptedCards.isNotEmpty && _searchQuery.isEmpty)
                  Container(
                    height: 230,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: decryptedCards.length > 6 ? 6 : decryptedCards.length,
                      itemBuilder: (ctx, index) {
                        final card = decryptedCards[index];
                        final points = _getMockPointsForCard(card);
                        
                        return ColorfulCardItem(
                          card: card,
                          points: points,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => MerchantScreen(
                                  cardId: card.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, issuer, or card number',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  
                  // Category filter chips
                  if (_searchQuery.isEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // "All" option
                          CategoryChip(
                            category: CardCategory.retail,
                            isSelected: _selectedCategory == null,
                            onTap: () {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                          ),
                          ...CardCategory.values.map((category) {
                            // Only show categories that have cards
                            if (cardProvider.getCardCountByCategory(category) == 0) {
                              return const SizedBox.shrink();
                            }
                            
                            return CategoryChip(
                              category: category,
                              isSelected: _selectedCategory == category,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = 
                                      _selectedCategory == category ? null : category;
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  
                  // Card list heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'All Cards',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  
                  // Card list
                  Expanded(
                    child: decryptedCards.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _refreshCards,
                            child: ListView.builder(
                              itemCount: decryptedCards.length,
                              padding: const EdgeInsets.only(bottom: 80),
                              itemBuilder: (ctx, index) {
                                final card = decryptedCards[index];
                                
                                return CardItem(
                                  card: card,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => CardDetailScreen(
                                          cardId: card.id,
                                        ),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    cardProvider.deleteCard(card.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${card.name} card deleted'),
                                        action: SnackBarAction(
                                          label: 'UNDO',
                                          onPressed: () {
                                            // re-add the card
                                            cardProvider.addCard(card);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
              
              // Floating action button for adding cards
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: _addNewCard,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(Icons.add),
                ),
              ),
              
              // Sync indicator
              if (cardProvider.isSyncing)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Syncing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No loyalty cards yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first loyalty card by tapping the + button',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewCard,
            icon: const Icon(Icons.add),
            label: const Text('Add Card'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 