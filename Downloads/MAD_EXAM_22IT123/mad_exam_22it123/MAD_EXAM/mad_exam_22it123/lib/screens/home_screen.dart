import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mad_exam_22it123/models/loyalty_card.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';
import 'package:mad_exam_22it123/screens/add_card_screen.dart';
import 'package:mad_exam_22it123/screens/card_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dateFormat = DateFormat('MM/dd/yyyy');
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initialize once
    if (!_isInit) {
      _initializeProvider();
      _isInit = true;
    }
  }

  Future<void> _initializeProvider() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    await cardProvider.init();
  }

  Future<void> _refreshCards() async {
    await Provider.of<CardProvider>(context, listen: false).syncWithServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _refreshCards,
            tooltip: 'Sync with cloud',
          ),
        ],
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

          if (cardProvider.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No loyalty cards yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const AddCardScreen(),
                        ),
                      );
                    },
                    child: const Text('Add Your First Card'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshCards,
                child: ListView.builder(
                  itemCount: cardProvider.cards.length,
                  itemBuilder: (ctx, index) {
                    final card = cardProvider.cards[index];
                    // decrypt card for display
                    final decryptedCard = cardProvider.getDecryptedCard(card);
                    
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
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Card?'),
                            content: Text(
                              'Are you sure you want to delete the ${decryptedCard.name} card?'
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
                        cardProvider.deleteCard(card.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${decryptedCard.name} card deleted'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                // re-add the card
                                cardProvider.addCard(decryptedCard);
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => CardDetailScreen(
                                  cardId: card.id,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Card image or placeholder
                                Container(
                                  width: 60,
                                  height: 60,
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
                                        decryptedCard.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Expires: ${_dateFormat.format(decryptedCard.expirationDate)}',
                                        style: TextStyle(
                                          color: decryptedCard.isExpiringSoon
                                              ? Colors.orange
                                              : Colors.grey.shade600,
                                          fontWeight: decryptedCard.isExpiringSoon
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            decryptedCard.isSynced
                                                ? Icons.cloud_done
                                                : Icons.cloud_off,
                                            size: 16,
                                            color: decryptedCard.isSynced
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            decryptedCard.isSynced
                                                ? 'Synced'
                                                : 'Not synced',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Show alert for expiring cards
                                if (decryptedCard.isExpiringSoon)
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                  ),
                                // Navigation arrow
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Syncing indicator
              if (cardProvider.isSyncing)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.orange.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Syncing...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const AddCardScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 