import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';
import 'package:mad_exam_22it123/utils/constants.dart';
import 'package:mad_exam_22it123/widgets/category_chip.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        elevation: 0,
      ),
      body: Consumer<CardProvider>(
        builder: (ctx, cardProvider, child) {
          if (cardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = CardCategory.values;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Browse by Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final cardCount = cardProvider.getCardCountByCategory(category);
                      
                      return CategoryTile(
                        category: category,
                        cardCount: cardCount,
                        onTap: () {
                          _showCardsForCategory(context, cardProvider, category);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCardsForCategory(
    BuildContext context, 
    CardProvider cardProvider, 
    CardCategory category
  ) {
    final cards = cardProvider.getCardsByCategory(category);
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No cards in ${getCategoryName(category)} category'),
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'category': category,
    });
  }
} 