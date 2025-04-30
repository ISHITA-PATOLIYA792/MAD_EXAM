import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';
import 'package:mad_exam_22it123/services/notification_service.dart';
import 'package:mad_exam_22it123/services/sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isOnline = true;
  bool _isSyncing = false;
  
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }
  
  // check internet connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
    
    // listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (!mounted) return;
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      
      // trigger sync when coming back online
      if (_isOnline) {
        _syncData();
      }
    });
  }
  
  // sync data with server
  Future<void> _syncData() async {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are offline')),
      );
      return;
    }
    
    setState(() {
      _isSyncing = true;
    });
    
    try {
      await Provider.of<CardProvider>(context, listen: false).syncWithServer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
  
  // simulate a promotion notification
  void _simulatePromotion() {
    final notificationService = NotificationService();
    notificationService.showPromotion(
      'Starbucks',
      'Get 50% off on your next purchase with your loyalty card!',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Promotion notification sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // sync status
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isOnline ? Icons.cloud_done : Icons.cloud_off,
                          color: _isOnline ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your loyalty cards are always available offline. When connected, they will automatically sync with the cloud.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isOnline && !_isSyncing ? _syncData : null,
                        child: _isSyncing
                            ? const Row(
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
                                  Text('Syncing...'),
                                ],
                              )
                            : const Text('Sync Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // notifications
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text(
                        'Get alerts for expiring cards and special offers',
                      ),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    // simulated promotion button (for demo)
                    OutlinedButton.icon(
                      onPressed: _notificationsEnabled ? _simulatePromotion : null,
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text('Simulate Promotion Alert'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This is a demo button to simulate receiving a promotion notification',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // about app
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Loyalty Card Storage App',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A secure storage app for all your loyalty cards, with offline access and cloud sync.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '© 2023 Everyday Rewards Inc.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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